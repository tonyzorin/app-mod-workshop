# Deployment Configuration Summary

## 🎯 Your Specific Settings

### Database Configuration
- **Instance Name**: `appmod-phpapp`
- **Database Name**: `image_catalog`
- **Database User**: `appmod-phpapp-user`
- **Database Password**: `appmod-phpapp`
- **Region**: `europe-west8`
- **Public IP**: `34.154.174.181`
- **Port**: `3306`

### Container Registry
- **Repository**: `europe-west8-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop`

### Google Cloud Project
- **Project ID**: `kinetic-magnet-106116`
- **Region**: `europe-west8`
- **Service Name**: `app-mod-workshop`

## 🚀 Quick Deployment Commands

```bash
# 1. Authenticate with Google Cloud
gcloud auth login
gcloud config set project kinetic-magnet-106116
gcloud config set run/region europe-west8

# 2. Deploy everything
./deploy-to-cloudrun.sh

# 3. Import database schema
./import-db-schema.sh

# 4. Get service URL
gcloud run services describe app-mod-workshop --region=europe-west8 --format="value(status.url)"
```

## 🔧 CI/CD Setup

1. Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
2. Connect GitHub repository: `tonyzorin/app-mod-workshop`
3. Create trigger:
   - **Name**: `deploy-on-push`
   - **Branch**: `^master$`
   - **Configuration**: `/cloudbuild.yaml`

## 📊 Expected Resources

After deployment, you'll have:
- ✅ Cloud SQL instance: `appmod-phpapp` (already exists)
- ✅ Cloud Run service: `app-mod-workshop`
- ✅ Artifact Registry: `europe-west8-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop`
- ✅ Secret Manager secrets: `db-root-password`, `db-user-password`, `db-instance-name`

## 🔗 Connection String

Your app connects to Cloud SQL using:
```
DB_HOST=/cloudsql/kinetic-magnet-106116:europe-west8:appmod-phpapp
DB_NAME=image_catalog
DB_USER=appmod-phpapp-user
DB_PASSWORD=(from Secret Manager)
```

## 🗄️ Direct Database Connection

For manual database access:
```bash
# Using gcloud (recommended)
gcloud sql connect appmod-phpapp --user=appmod-phpapp-user

# Using mysql client directly
mysql -h 34.154.174.181 -P 3306 -u appmod-phpapp-user -p image_catalog
# Password: appmod-phpapp
```

## 💰 Estimated Costs

- **Cloud Run**: ~$0-5/month (pay per request)
- **Cloud SQL**: ~$7-10/month (current instance)
- **Artifact Registry**: ~$0.10/month (storage)
- **Secret Manager**: ~$0.06/month
- **Total**: ~$7-15/month for development usage

## 🎉 What Happens on Git Push

1. GitHub webhook triggers Cloud Build
2. Builds Docker image from your code
3. Pushes to `europe-west8-docker.pkg.dev/kinetic-magnet-106116/app-mod-workshop`
4. Deploys to Cloud Run service `app-mod-workshop`
5. Connects to Cloud SQL `appmod-phpapp` at `34.154.174.181`
6. Your app is live! 🚀

## 🔍 Current Database Status

Connection Name: `kinetic-magnet-106116:europe-west8:appmod-phpapp`
- ✅ Public IP connectivity enabled
- ✅ IP Address: `34.154.174.181`
- ✅ Port: `3306`
- ⚠️ Private IP connectivity disabled (using public IP) 