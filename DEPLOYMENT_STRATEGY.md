# Deployment Strategy: Dev/Prod Environments

## 🎯 **Environment Overview**

### **Development Environment**
- **Service**: `app-mod-workshop`
- **Type**: Repository deployment (GitHub integration)
- **URL**: https://app-mod-workshop-994949696307.europe-west1.run.app
- **Deployment**: Automatic on every GitHub push to `master`
- **Purpose**: Testing new features, bug fixes, development work

### **Production Environment**  
- **Service**: `app-mod-workshop-prod`
- **Type**: Container deployment (manual releases)
- **URL**: https://app-mod-workshop-prod-994949696307.europe-west1.run.app
- **Deployment**: Manual promotion from tested dev builds
- **Purpose**: Stable, production-ready application

## 🔄 **Deployment Workflow**

### **1. Development Cycle**
```bash
# Developer pushes code to GitHub
git push origin master
↓
# GitHub webhook triggers Cloud Build
# Automatic deployment to DEV environment
# URL: https://app-mod-workshop-994949696307.europe-west1.run.app
```

### **2. Production Release**
```bash
# After testing in DEV, promote to PROD
gcloud run deploy app-mod-workshop-prod \
    --image=europe-west1-docker.pkg.dev/sapient-cycling-465513-s8/cloud-run-source-deploy/app-mod-workshop/app-mod-workshop:COMMIT_SHA \
    --region=europe-west1
```

## 🛠 **Environment Configurations**

### **DEV Environment**
- **Resources**: 1 CPU, 1Gi RAM
- **Scaling**: 0-10 instances
- **Database**: Shared Cloud SQL instance
- **Monitoring**: Basic logging

### **PROD Environment**
- **Resources**: 2 CPU, 2Gi RAM  
- **Scaling**: 1-100 instances (min 1 for always-on)
- **Database**: Shared Cloud SQL instance
- **Monitoring**: Enhanced logging + alerts

## 📋 **Manual Promotion Commands**

### **Promote Latest DEV to PROD**
```bash
# Get latest successful dev image
DEV_IMAGE=$(gcloud run services describe app-mod-workshop --region=europe-west1 --format="value(spec.template.spec.template.spec.containers[0].image)")

# Deploy to production
gcloud run deploy app-mod-workshop-prod \
    --image=$DEV_IMAGE \
    --region=europe-west1 \
    --memory=2Gi \
    --cpu=2 \
    --max-instances=100 \
    --min-instances=1
```

### **Promote Specific Commit to PROD**
```bash
# Replace COMMIT_SHA with specific commit
gcloud run deploy app-mod-workshop-prod \
    --image=europe-west1-docker.pkg.dev/sapient-cycling-465513-s8/cloud-run-source-deploy/app-mod-workshop/app-mod-workshop:COMMIT_SHA \
    --region=europe-west1
```

## 🔐 **Database Configuration**

Both environments share the same Cloud SQL database:
- **Host**: `34.154.174.181`
- **Database**: `image_catalog`
- **User**: `appmod-phpapp`
- **Connection**: Direct IP (cross-project setup)

## 🎯 **Best Practices**

1. **Always test in DEV first** before promoting to PROD
2. **Use specific commit SHAs** for production deployments
3. **Monitor both environments** for performance and errors
4. **Keep production stable** - only promote tested builds
5. **Document releases** with commit messages and deployment notes

## 🚀 **Quick Access URLs**

- **DEV**: https://app-mod-workshop-994949696307.europe-west1.run.app
- **PROD**: https://app-mod-workshop-prod-994949696307.europe-west1.run.app
- **Cloud Build**: https://console.cloud.google.com/cloud-build/builds
- **Cloud Run**: https://console.cloud.google.com/run

## 📊 **Environment Status**

| Environment | Status | Last Deploy | Image Type |
|-------------|--------|-------------|------------|
| DEV | ✅ Auto | Latest commit | Repository |
| PROD | ✅ Manual | Stable release | Container | 