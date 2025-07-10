# Google Cloud Run Deployment Guide

## Prerequisites

1. **Google Cloud Project**: `kinetic-magnet-106116`
2. **Service Account**: `cloud-run-deployer@kinetic-magnet-106116.iam.gserviceaccount.com`
3. **Service Account Key**: `kinetic-magnet-106116-a67ab7f680c1.json`

## Step 1: Enable Required APIs (Manual)

Go to Google Cloud Console and enable these APIs:

1. **Service Usage API**: https://console.cloud.google.com/apis/library/serviceusage.googleapis.com?project=kinetic-magnet-106116
2. **Cloud Resource Manager API**: https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com?project=kinetic-magnet-106116
3. **Cloud Run Admin API**: https://console.cloud.google.com/apis/library/run.googleapis.com?project=kinetic-magnet-106116
4. **Cloud Build API**: https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=kinetic-magnet-106116
5. **Artifact Registry API**: https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com?project=kinetic-magnet-106116

## Step 2: Update Service Account Permissions

1. Go to IAM: https://console.cloud.google.com/iam-admin/iam?project=kinetic-magnet-106116
2. Find your service account: `cloud-run-deployer@kinetic-magnet-106116.iam.gserviceaccount.com`
3. Add these roles:
   - **Service Usage Admin**
   - **Cloud Run Admin**
   - **Cloud Build Editor**
   - **Artifact Registry Writer**
   - **Storage Admin**

## Step 3: Run Deployment Script

Once APIs are enabled and permissions are set:

```bash
./deploy.sh
```

## Alternative: Manual Deployment Steps

If the script fails, run these commands manually:

```bash
# 1. Set project
gcloud config set project kinetic-magnet-106116

# 2. Configure Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# 3. Create Artifact Registry repository
gcloud artifacts repositories create app-mod-workshop \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository for app-mod-workshop"

# 4. Build Docker image
docker build -t us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/app-mod-workshop:latest .

# 5. Push to registry
docker push us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/app-mod-workshop:latest

# 6. Deploy to Cloud Run
gcloud run deploy app-mod-workshop \
    --image=us-central1-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop/app-mod-workshop:latest \
    --region=us-central1 \
    --platform=managed \
    --allow-unauthenticated \
    --port=80 \
    --memory=512Mi \
    --cpu=1 \
    --max-instances=10
```

## Step 4: Test Your Deployment

After deployment, you'll get a URL like:
```
https://app-mod-workshop-[hash]-uc.a.run.app
```

Test the application:
- **Login**: admin / admin123
- **Upload images**
- **View gallery**

## Architecture Overview

- **Frontend**: PHP 5.6 with Apache
- **Database**: SQLite (for demo) or MySQL (for production)
- **Container**: Docker with PHP 5.6-apache base image
- **Platform**: Google Cloud Run (serverless containers)
- **Registry**: Google Artifact Registry

## Files Created

- `Dockerfile` - Container definition
- `deploy.sh` - Deployment script
- `config.php` - Updated database configuration
- `.dockerignore` - Docker build optimization

## Troubleshooting

1. **Permission Errors**: Ensure all APIs are enabled and service account has correct roles
2. **Docker Build Fails**: Check if Docker is running
3. **Push Fails**: Verify Artifact Registry repository exists
4. **App Doesn't Start**: Check Cloud Run logs in console

## Production Considerations

For production deployment:
1. Set up Cloud SQL MySQL instance
2. Configure environment variables for database connection
3. Set up proper authentication
4. Enable HTTPS
5. Configure monitoring and logging 