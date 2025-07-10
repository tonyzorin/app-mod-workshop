#!/bin/bash

# Simple Cloud Build Deployment Script
# This uses Cloud Build to build and deploy, avoiding local Docker issues

set -e

PROJECT_ID="kinetic-magnet-106116"
REGION="us-central1"
SERVICE_NAME="php-amarcord"

echo "🚀 Deploying PHP Amarcord using Cloud Build..."
echo "Project: $PROJECT_ID"
echo ""

# Set up environment
export PATH="/Users/anton/google-cloud-sdk/bin:$PATH"
gcloud config set project $PROJECT_ID

# Submit build to Cloud Build
echo "☁️ Submitting build to Cloud Build..."
gcloud builds submit --config cloudbuild.yaml .

echo ""
echo "✅ Build submitted to Cloud Build!"
echo "📊 Monitor the build at: https://console.cloud.google.com/cloud-build/builds?project=$PROJECT_ID"
echo ""
echo "Once the build completes, your app will be available at:"
echo "🌐 https://$SERVICE_NAME-dev-[hash]-uc.a.run.app (DEV environment)"
echo "🌐 https://$SERVICE_NAME-[hash]-uc.a.run.app (PROD environment)" 