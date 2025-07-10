# Google Cloud Run Deployment Guide

This guide walks you through deploying the PHP App Modernization Workshop to Google Cloud Run with automatic CI/CD from GitHub.

## Prerequisites

1. **Google Cloud CLI installed** (gcloud)
2. **Docker installed** for local testing
3. **GitHub repository** set up at `tonyzorin/app-mod-workshop`
4. **Google Cloud project** with billing enabled

## Quick Start

### 1. Install Google Cloud CLI

```bash
# On macOS with Homebrew
brew install --cask google-cloud-sdk

# Or use the install script
curl https://sdk.cloud.google.com | bash
```

### 2. Authenticate and Set Project

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project kinetic-magnet-106116

# Set default region
gcloud config set run/region us-central1
```

### 3. Run the Deployment Script

```bash
# Make sure the script is executable
chmod +x deploy-to-cloudrun.sh

# Run the deployment
./deploy-to-cloudrun.sh
```

This script will:
- ✅ Enable required Google Cloud APIs
- ✅ Create Cloud SQL MySQL instance
- ✅ Set up Secret Manager for database credentials
- ✅ Create Artifact Registry repository
- ✅ Build and deploy Docker image to Cloud Run
- ✅ Configure environment variables and secrets

## Manual Steps

### 1. Set Up CI/CD Trigger

After running the deployment script, you need to manually set up the Cloud Build trigger:

1. Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
2. Click **"Connect Repository"**
3. Select **GitHub** and authorize the connection
4. Select your repository: `tonyzorin/app-mod-workshop`
5. Create a trigger with these settings:
   - **Name**: `deploy-on-push`
   - **Event**: Push to a branch
   - **Branch**: `^master$`
   - **Configuration**: Cloud Build configuration file
   - **Location**: `/cloudbuild.yaml`

### 2. Import Database Schema

```bash
# Make the script executable
chmod +x import-db-schema.sh

# Import database schema and seed data
./import-db-schema.sh
```

### 3. Test the Deployment

After deployment, you'll get a Cloud Run URL. Test it:

```bash
# Get the service URL
gcloud run services describe app-mod-workshop --region=us-central1 --format="value(status.url)"

# Test the application
curl -I https://your-service-url.a.run.app
```

## Architecture

```
GitHub → Cloud Build → Artifact Registry → Cloud Run
                                              ↓
                                         Cloud SQL
                                              ↓
                                      Secret Manager
```

### Components:

- **Cloud Run**: Serverless container platform hosting the PHP app
- **Cloud SQL**: Managed MySQL database
- **Secret Manager**: Secure storage for database credentials
- **Artifact Registry**: Container image storage
- **Cloud Build**: CI/CD pipeline triggered by GitHub commits

## Environment Variables

The application uses these environment variables in Cloud Run:

- `DB_HOST`: `/cloudsql/PROJECT_ID:REGION:INSTANCE_NAME`
- `DB_NAME`: `image_catalog`
- `DB_USER`: `appuser`
- `DB_PASSWORD`: Retrieved from Secret Manager

## Security Features

- ✅ Database credentials stored in Secret Manager
- ✅ Cloud SQL private IP connection
- ✅ IAM-based access control
- ✅ HTTPS-only traffic
- ✅ Container image vulnerability scanning

## Monitoring and Logging

- **Cloud Run Logs**: View application logs in Cloud Console
- **Cloud SQL Monitoring**: Database performance metrics
- **Build History**: CI/CD pipeline execution logs

## Cost Optimization

- **Cloud Run**: Pay per request, scales to zero
- **Cloud SQL**: f1-micro instance for development
- **Artifact Registry**: Only pay for storage used
- **Secret Manager**: Minimal cost for secret storage

## Troubleshooting

### Common Issues:

1. **Database Connection Failed**
   - Check Cloud SQL instance is running
   - Verify Secret Manager permissions
   - Ensure Cloud SQL connector is properly configured

2. **Build Failures**
   - Check Cloud Build logs
   - Verify Dockerfile syntax
   - Ensure all dependencies are available

3. **Deployment Issues**
   - Check Cloud Run service logs
   - Verify environment variables
   - Ensure proper IAM permissions

### Useful Commands:

```bash
# View Cloud Run logs
gcloud run services logs tail app-mod-workshop --region=us-central1

# Check Cloud SQL status
gcloud sql instances describe app-mod-workshop-db

# View build history
gcloud builds list --limit=10

# Connect to Cloud SQL for debugging
gcloud sql connect app-mod-workshop-db --user=root
```

## Next Steps

1. **Set up monitoring** with Cloud Monitoring
2. **Configure custom domain** for your application
3. **Set up staging environment** for testing
4. **Implement database backups** and disaster recovery
5. **Add performance monitoring** with Cloud Trace

## Support

For issues with this deployment:
1. Check the troubleshooting section above
2. Review Cloud Build and Cloud Run logs
3. Consult Google Cloud documentation
4. Open an issue in the GitHub repository

---

**Total Setup Time**: ~15-20 minutes
**Monthly Cost**: ~$10-20 for development workloads 