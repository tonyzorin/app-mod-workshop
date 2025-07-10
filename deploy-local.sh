#!/bin/bash

# Local Deployment Script: Localhost → Google Cloud Run
# This script builds and deploys your PHP app from your local machine

set -e  # Exit on any error

# Configuration
PROJECT_ID="kinetic-magnet-106116"
REGION="us-central1"
SERVICE_NAME="php-amarcord"
REPOSITORY="app-mod-workshop"
IMAGE_TAG="latest"

echo "🚀 Deploying PHP Amarcord from localhost to Google Cloud Run..."
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo ""

# Step 1: Set up environment
echo "🔧 Setting up environment..."
export PATH="/Users/anton/google-cloud-sdk/bin:$PATH"
gcloud config set project $PROJECT_ID

# Step 2: Configure Docker authentication
echo "🔑 Configuring Docker authentication..."
gcloud auth configure-docker $REGION-docker.pkg.dev

# Step 3: Build Docker image locally
echo "🔨 Building Docker image locally..."
IMAGE_URL="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$SERVICE_NAME:$IMAGE_TAG"
docker build -t $IMAGE_URL .

# Step 4: Push image to Artifact Registry
echo "📤 Pushing image to Artifact Registry..."
docker push $IMAGE_URL

# Step 5: Deploy to Cloud Run
echo "🚢 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=$IMAGE_URL \
    --region=$REGION \
    --platform=managed \
    --allow-unauthenticated \
    --port=80 \
    --memory=512Mi \
    --cpu=1 \
    --max-instances=10 \
    --set-env-vars="ENVIRONMENT=production"

# Step 6: Get the service URL
echo ""
echo "✅ Deployment completed!"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")
echo "🌐 Your app is now live at: $SERVICE_URL"
echo ""
echo "🧪 Test your deployment:"
echo "  curl $SERVICE_URL"
echo "  curl $SERVICE_URL/login.php"
echo ""
echo "📊 Monitor your app:"
echo "  https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME?project=$PROJECT_ID" 