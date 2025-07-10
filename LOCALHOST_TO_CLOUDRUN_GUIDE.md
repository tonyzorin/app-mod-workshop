# 🚀 Localhost to Google Cloud Run Deployment Guide

This guide shows you **4 different ways** to deploy your PHP application from your local development environment to Google Cloud Run.

## 📊 **Deployment Methods Comparison**

| Method | Difficulty | Speed | Best For |
|--------|------------|-------|----------|
| **Cloud Console** | ⭐ Easy | 🐌 Slow | First-time users |
| **Cloud Shell** | ⭐⭐ Medium | 🚀 Fast | Quick deployments |
| **Cloud Build** | ⭐⭐ Medium | 🚀 Fast | Automated builds |
| **Local Docker** | ⭐⭐⭐ Hard | 🐌 Slow | Full control |

---

## 🌐 **Method 1: Google Cloud Console (Easiest)**

**Best for**: First-time deployment, no local setup required

### Steps:
1. **Go to Cloud Run**: https://console.cloud.google.com/run?project=kinetic-magnet-106116
2. **Click "Create Service"**
3. **Select "Deploy one revision from an existing container image"**
4. **Click "Set up Continuous Deployment"**
5. **Connect your GitHub repository**
6. **Configure build settings**:
   - Build Type: `Dockerfile`
   - Location: `/Dockerfile`
7. **Click "Save"**

### Pros:
- ✅ No local setup required
- ✅ Visual interface
- ✅ Automatic CI/CD setup

### Cons:
- ❌ Slower than command line
- ❌ Less control over build process

---

## ☁️ **Method 2: Google Cloud Shell (Recommended)**

**Best for**: Quick deployments without local Docker setup

### Steps:
1. **Open Cloud Shell**: https://console.cloud.google.com/?project=kinetic-magnet-106116
2. **Clone your repository**:
```bash
git clone https://github.com/your-username/app-mod-workshop.git
cd app-mod-workshop
```

3. **Deploy with source-to-image**:
```bash
gcloud run deploy php-amarcord \
    --source . \
    --region=us-central1 \
    --allow-unauthenticated \
    --port=80 \
    --memory=512Mi \
    --cpu=1
```

### Pros:
- ✅ No local Docker required
- ✅ Fast deployment
- ✅ Google Cloud handles the build

### Cons:
- ❌ Requires uploading code to Cloud Shell
- ❌ Limited to Google Cloud environment

---

## 🏗️ **Method 3: Cloud Build (Automated)**

**Best for**: Professional development workflow

### Prerequisites:
1. **Enable Cloud Build API**:
```bash
export PATH="/Users/anton/google-cloud-sdk/bin:$PATH"
gcloud services enable cloudbuild.googleapis.com
```

2. **Grant Cloud Build permissions**:
```bash
PROJECT_NUMBER=$(gcloud projects describe kinetic-magnet-106116 --format="value(projectNumber)")
gcloud projects add-iam-policy-binding kinetic-magnet-106116 \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/run.admin"
```

### Deploy:
```bash
# Use the simple deployment script
./deploy-simple.sh
```

Or manually:
```bash
gcloud builds submit --config cloudbuild.yaml .
```

### Pros:
- ✅ Professional CI/CD workflow
- ✅ Automated testing and deployment
- ✅ Version control integration

### Cons:
- ❌ Requires initial setup
- ❌ More complex configuration

---

## 🐳 **Method 4: Local Docker Build (Advanced)**

**Best for**: Full control over the build process

### Prerequisites:
1. **Install Docker Desktop**: https://www.docker.com/products/docker-desktop
2. **Ensure Docker is running**:
```bash
docker --version
```

3. **Create Artifact Registry repository** (via Console):
   - Go to: https://console.cloud.google.com/artifacts?project=kinetic-magnet-106116
   - Create repository: `app-mod-workshop`

### Deploy:
```bash
# Use the local deployment script
./deploy-local.sh
```

Or manually:
```bash
# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build image
docker build -t us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/php-amarcord:latest .

# Push image
docker push us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/php-amarcord:latest

# Deploy to Cloud Run
gcloud run deploy php-amarcord \
    --image=us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/php-amarcord:latest \
    --region=us-central1 \
    --allow-unauthenticated \
    --port=80
```

### Pros:
- ✅ Full control over build process
- ✅ Can test Docker image locally
- ✅ Works offline (build phase)

### Cons:
- ❌ Requires Docker Desktop
- ❌ Slower build times
- ❌ More complex setup

---

## 🎯 **Quick Start (Choose Your Method)**

### **For Beginners**: Use Cloud Console
1. Go to https://console.cloud.google.com/run?project=kinetic-magnet-106116
2. Click "Create Service" → "Continuous Deployment"
3. Connect your GitHub repository

### **For Quick Testing**: Use Cloud Shell
1. Open Cloud Shell: https://shell.cloud.google.com/?project=kinetic-magnet-106116
2. Run:
```bash
git clone https://github.com/gdgpescara/app-mod-workshop.git
cd app-mod-workshop
gcloud run deploy php-amarcord --source . --region=us-central1 --allow-unauthenticated
```

### **For Development**: Use Cloud Build
1. Enable APIs and permissions (see Method 3)
2. Run: `./deploy-simple.sh`

---

## 🐛 **Troubleshooting**

### **Permission Denied Errors**
```bash
# Grant necessary permissions to your service account
gcloud projects add-iam-policy-binding kinetic-magnet-106116 \
    --member="serviceAccount:cloud-run-deployer@kinetic-magnet-106116.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding kinetic-magnet-106116 \
    --member="serviceAccount:cloud-run-deployer@kinetic-magnet-106116.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.admin"
```

### **Docker Build Fails**
```bash
# Check Docker is running
docker --version

# Test Docker build locally
docker build -t test-image .
```

### **gcloud Command Not Found**
```bash
# Add Google Cloud SDK to PATH
export PATH="/Users/anton/google-cloud-sdk/bin:$PATH"

# Or install gcloud CLI
curl https://sdk.cloud.google.com | bash
```

### **Service URL Not Working**
- Wait 1-2 minutes for deployment to complete
- Check Cloud Run logs in the console
- Verify the service is receiving traffic

---

## 📈 **Development Workflow**

### **Local Development**:
```bash
# Test locally with Docker
docker build -t php-amarcord .
docker run -p 8080:80 php-amarcord
# Test at: http://localhost:8080
```

### **Deploy to DEV**:
```bash
./deploy-simple.sh
```

### **Deploy to PROD**:
```bash
# Push to main branch (triggers automatic deployment)
git push origin main
```

---

## 🌐 **Expected URLs After Deployment**

After successful deployment, your app will be available at:

- **DEV Environment**: `https://php-amarcord-dev-[hash]-uc.a.run.app`
- **PROD Environment**: `https://php-amarcord-[hash]-uc.a.run.app`

### **Test Your Deployment**:
```bash
# Health check
curl https://your-service-url.run.app

# Login page
curl https://your-service-url.run.app/login.php

# Upload functionality
curl https://your-service-url.run.app/upload.php
```

---

## 🎉 **Success Checklist**

- [ ] ✅ Service deployed successfully
- [ ] ✅ Application accessible via HTTPS URL
- [ ] ✅ Login page working (admin/admin123)
- [ ] ✅ File upload functionality working
- [ ] ✅ Database (SQLite) initialized with default users
- [ ] ✅ No critical errors in Cloud Run logs

---

## 📚 **Next Steps**

1. **Set up CI/CD**: Follow the CI/CD guide for automated deployments
2. **Add Cloud SQL**: Upgrade from SQLite to Cloud SQL for production
3. **Custom Domain**: Configure a custom domain for your app
4. **Monitoring**: Set up Cloud Monitoring and alerting
5. **Security**: Add authentication and HTTPS redirects

**🎯 Choose the method that best fits your experience level and requirements!** 