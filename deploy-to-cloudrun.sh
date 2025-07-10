#!/bin/bash

# Google Cloud Run Deployment Script
# This script deploys the PHP app to Google Cloud Run with CI/CD setup

set -e

# Configuration
PROJECT_ID="kinetic-magnet-106116"
REGION="us-central1"
SERVICE_NAME="app-mod-workshop"
REPO_NAME="app-mod-workshop"
GITHUB_REPO="tonyzorin/app-mod-workshop"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Google Cloud Run Deployment${NC}"

# Step 1: Set up Google Cloud project
echo -e "${YELLOW}Step 1: Setting up Google Cloud project${NC}"
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

# Step 2: Enable required APIs
echo -e "${YELLOW}Step 2: Enabling required APIs${NC}"
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Step 3: Create Cloud SQL instance
echo -e "${YELLOW}Step 3: Creating Cloud SQL instance${NC}"
INSTANCE_NAME="app-mod-workshop-db"
DB_PASSWORD=$(openssl rand -base64 32)

gcloud sql instances create $INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=$REGION \
    --root-password=$DB_PASSWORD

# Create database
gcloud sql databases create image_catalog --instance=$INSTANCE_NAME

# Create database user
DB_USER="appuser"
DB_USER_PASSWORD=$(openssl rand -base64 32)
gcloud sql users create $DB_USER --instance=$INSTANCE_NAME --password=$DB_USER_PASSWORD

# Step 4: Store secrets in Secret Manager
echo -e "${YELLOW}Step 4: Storing secrets in Secret Manager${NC}"
echo -n "$DB_PASSWORD" | gcloud secrets create db-root-password --data-file=-
echo -n "$DB_USER_PASSWORD" | gcloud secrets create db-user-password --data-file=-
echo -n "$INSTANCE_NAME" | gcloud secrets create db-instance-name --data-file=-

# Step 5: Create Artifact Registry repository
echo -e "${YELLOW}Step 5: Creating Artifact Registry repository${NC}"
gcloud artifacts repositories create $REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for $SERVICE_NAME"

# Step 6: Build and push Docker image
echo -e "${YELLOW}Step 6: Building and pushing Docker image${NC}"
IMAGE_URL="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME:latest"

gcloud builds submit --tag $IMAGE_URL

# Step 7: Deploy to Cloud Run
echo -e "${YELLOW}Step 7: Deploying to Cloud Run${NC}"
INSTANCE_CONNECTION_NAME="$PROJECT_ID:$REGION:$INSTANCE_NAME"

gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_URL \
    --region $REGION \
    --allow-unauthenticated \
    --set-env-vars="DB_HOST=/cloudsql/$INSTANCE_CONNECTION_NAME" \
    --set-env-vars="DB_NAME=image_catalog" \
    --set-env-vars="DB_USER=$DB_USER" \
    --set-secrets="DB_PASSWORD=db-user-password:latest" \
    --add-cloudsql-instances=$INSTANCE_CONNECTION_NAME \
    --memory=1Gi \
    --cpu=1 \
    --max-instances=10

# Step 8: Set up Cloud Build triggers for CI/CD
echo -e "${YELLOW}Step 8: Setting up CI/CD with Cloud Build${NC}"

# Connect GitHub repository (this requires manual approval in the console)
echo -e "${RED}⚠️  Manual step required:${NC}"
echo "1. Go to https://console.cloud.google.com/cloud-build/triggers"
echo "2. Click 'Connect Repository'"
echo "3. Select GitHub and authorize"
echo "4. Select repository: $GITHUB_REPO"
echo "5. Create trigger with the following settings:"
echo "   - Name: deploy-on-push"
echo "   - Event: Push to a branch"
echo "   - Branch: ^master$"
echo "   - Configuration: Cloud Build configuration file"
echo "   - Location: /cloudbuild.yaml"

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo -e "${GREEN}✅ Deployment completed!${NC}"
echo -e "${GREEN}🌐 Service URL: $SERVICE_URL${NC}"
echo -e "${GREEN}🔐 Database Instance: $INSTANCE_CONNECTION_NAME${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Set up the Cloud Build trigger manually (see instructions above)"
echo "2. Import your database schema by connecting to Cloud SQL"
echo "3. Test the application"

# Save important information
cat > deployment-info.txt << EOF
Deployment Information
=====================
Project ID: $PROJECT_ID
Service Name: $SERVICE_NAME
Service URL: $SERVICE_URL
Database Instance: $INSTANCE_CONNECTION_NAME
Database Name: image_catalog
Database User: $DB_USER
Region: $REGION
Image URL: $IMAGE_URL

Secrets in Secret Manager:
- db-root-password
- db-user-password
- db-instance-name

Next Steps:
1. Set up Cloud Build trigger for CI/CD
2. Import database schema
3. Test the application
EOF

echo -e "${GREEN}📄 Deployment info saved to deployment-info.txt${NC}" 