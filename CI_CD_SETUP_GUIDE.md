# CI/CD Setup Guide: Google Cloud Build vs GitLab CI

This guide shows you how to set up automated CI/CD pipelines for your PHP application using Google Cloud Build (recommended) or GitLab CI.

## 🏗️ **Google Cloud Build Setup (Recommended)**

Google Cloud Build is the native CI/CD solution for Google Cloud, similar to GitLab CI but integrated with Google Cloud services.

### **Files Created:**

1. **`cloudbuild.yaml`** - Basic CI/CD pipeline
2. **`cloudbuild-advanced.yaml`** - Advanced pipeline with multiple environments
3. **`setup-triggers.sh`** - Script to create build triggers
4. **`.gitlab-ci.yml`** - GitLab CI equivalent (for comparison)

### **Pipeline Architecture:**

```
Git Push → Cloud Build Trigger → Build Docker → Security Scan → Push to Registry → Deploy to Cloud Run
```

### **Environment Strategy:**

- **DEV**: All branches deploy here for testing
- **STAGING**: Only `main` branch, for pre-production testing
- **PRODUCTION**: Only `main` branch, with manual approval

### **Step 1: Enable Cloud Build API**

```bash
gcloud services enable cloudbuild.googleapis.com
```

### **Step 2: Grant Cloud Build Permissions**

```bash
# Get the Cloud Build service account
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/iam.serviceAccountUser"
```

### **Step 3: Connect Your Repository**

#### **Option A: GitHub Repository**

1. Go to [Cloud Build Console](https://console.cloud.google.com/cloud-build/triggers)
2. Click "Connect Repository"
3. Select "GitHub (Cloud Build GitHub App)"
4. Authenticate and select your repository
5. Create triggers using the UI or run `setup-triggers.sh`

#### **Option B: Cloud Source Repositories**

```bash
# Clone your repo to Cloud Source Repositories
gcloud source repos create app-mod-workshop
git remote add google https://source.developers.google.com/p/$PROJECT_ID/r/app-mod-workshop
git push google main
```

### **Step 4: Create Build Triggers**

Update and run the setup script:

```bash
# Edit setup-triggers.sh and update GITHUB_OWNER
./setup-triggers.sh
```

Or create manually:

```bash
# Basic trigger for all branches
gcloud builds triggers create github \
    --repo-name=app-mod-workshop \
    --repo-owner=your-username \
    --branch-pattern=".*" \
    --build-config="cloudbuild.yaml"

# Advanced trigger for main branch
gcloud builds triggers create github \
    --repo-name=app-mod-workshop \
    --repo-owner=your-username \
    --branch-pattern="^main$" \
    --build-config="cloudbuild-advanced.yaml"
```

### **Step 5: Test Your Pipeline**

```bash
# Make a change and push
echo "# Test change" >> README.md
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

## 🦊 **GitLab CI Setup (Alternative)**

If you're using GitLab instead of GitHub, use the `.gitlab-ci.yml` file.

### **Step 1: Set GitLab Variables**

In your GitLab project, go to Settings → CI/CD → Variables and add:

- `GCP_SERVICE_KEY`: Base64 encoded service account key
- `PROJECT_ID`: Your Google Cloud project ID

### **Step 2: Enable GitLab CI**

The `.gitlab-ci.yml` file will automatically trigger builds on push.

## 📊 **Pipeline Comparison**

| Feature | Google Cloud Build | GitLab CI |
|---------|-------------------|-----------|
| **Native Integration** | ✅ Full GCP integration | ⚠️ Requires setup |
| **Cost** | Pay per build minute | Free tier available |
| **Ease of Setup** | ✅ Simple for GCP | ⚠️ More configuration |
| **Advanced Features** | ✅ Security scanning | ✅ Rich ecosystem |
| **Multi-cloud** | ⚠️ GCP focused | ✅ Cloud agnostic |

## 🚀 **Pipeline Features**

### **Basic Pipeline (`cloudbuild.yaml`):**
1. **Build** Docker image
2. **Push** to Artifact Registry
3. **Deploy** to Cloud Run DEV
4. **Test** basic functionality
5. **Deploy** to Cloud Run PROD (main branch only)

### **Advanced Pipeline (`cloudbuild-advanced.yaml`):**
1. **Build** Docker image with multiple tags
2. **Security Scan** container vulnerabilities
3. **Push** to Artifact Registry
4. **Deploy DEV** (all branches)
5. **Integration Tests** automated testing
6. **Deploy STAGING** (main branch only)
7. **Performance Tests** load testing
8. **Deploy PRODUCTION** (main branch only)
9. **Notifications** deployment status

## 🔧 **Customization Options**

### **Branch-based Deployments:**

```yaml
# Deploy different branches to different environments
substitutions:
  _ENV: ${BRANCH_NAME}  # dev, staging, main

# In deploy step:
--set-env-vars=ENVIRONMENT=${_ENV}
```

### **Manual Approval for Production:**

```yaml
# Add manual approval step
- name: 'gcr.io/cloud-builders/gcloud'
  id: 'manual-approval'
  entrypoint: 'bash'
  args:
    - '-c'
    - 'echo "Waiting for manual approval..." && sleep 3600'
  waitFor: ['deploy-staging']
```

### **Slack/Email Notifications:**

```yaml
# Add notification step
- name: 'gcr.io/cloud-builders/curl'
  args:
    - '-X'
    - 'POST'
    - '-H'
    - 'Content-type: application/json'
    - '--data'
    - '{"text":"Deployment completed: ${BUILD_ID}"}'
    - '${_SLACK_WEBHOOK_URL}'
```

## 🐛 **Troubleshooting**

### **Common Issues:**

1. **Permission Denied**: Ensure Cloud Build service account has necessary roles
2. **Build Timeout**: Increase timeout in `options.timeout`
3. **Docker Build Fails**: Check Dockerfile syntax and dependencies
4. **Deploy Fails**: Verify Cloud Run API is enabled and regions match

### **Debug Commands:**

```bash
# View build logs
gcloud builds log $BUILD_ID

# Test trigger manually
gcloud builds triggers run $TRIGGER_NAME --branch=main

# Check service account permissions
gcloud projects get-iam-policy $PROJECT_ID
```

## 📈 **Best Practices**

1. **Use Multi-stage Builds** to optimize Docker images
2. **Implement Proper Testing** at each stage
3. **Use Environment Variables** for configuration
4. **Enable Security Scanning** for vulnerabilities
5. **Monitor Build Performance** and optimize as needed
6. **Use Branch Protection** rules in your repository
7. **Implement Rollback Strategy** for failed deployments

## 🎯 **Next Steps**

1. **Set up monitoring** with Cloud Monitoring
2. **Add database migrations** to your pipeline
3. **Implement blue-green deployments** for zero downtime
4. **Add performance testing** with load testing tools
5. **Set up alerting** for failed deployments
6. **Implement infrastructure as code** with Terraform

## 📚 **Learning Resources**

- [Google Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Run CI/CD Best Practices](https://cloud.google.com/run/docs/continuous-deployment)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) 