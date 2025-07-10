#!/bin/bash

# Deployment script for PHP app to Google Cloud Run
# Make sure to enable required APIs first in Google Cloud Console

PROJECT_ID="kinetic-magnet-106116"
REGION="us-central1"
SERVICE_NAME="app-mod-workshop"
REPOSITORY_NAME="app-mod-workshop"

echo "🚀 Starting deployment to Google Cloud Run..."

# Set project
gcloud config set project $PROJECT_ID

# Configure Docker to use gcloud as a credential helper
gcloud auth configure-docker $REGION-docker.pkg.dev

# Create Artifact Registry repository (if it doesn't exist)
echo "📦 Creating Artifact Registry repository..."
gcloud artifacts repositories create $REPOSITORY_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for app-mod-workshop" || echo "Repository might already exist"

# Build and push Docker image
echo "🔨 Building Docker image..."
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:latest .

echo "📤 Pushing Docker image to Artifact Registry..."
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:latest

# Deploy to Cloud Run
echo "🚢 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$SERVICE_NAME:latest \
    --region=$REGION \
    --platform=managed \
    --allow-unauthenticated \
    --port=80 \
    --memory=512Mi \
    --cpu=1 \
    --max-instances=10 \
    --set-env-vars="DB_HOST=localhost,DB_NAME=image_catalog,DB_USER=root,DB_PASSWORD=password"

echo "✅ Deployment complete!"
echo "🌐 Your app should be available at:"
gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)" 