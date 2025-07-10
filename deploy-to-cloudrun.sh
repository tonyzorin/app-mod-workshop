#!/bin/bash

# Google Cloud Run Deployment Script
# This script deploys the PHP app to Google Cloud Run with CI/CD setup

set -e

# Configuration
PROJECT_ID="kinetic-magnet-106116"
REGION="europe-west10"
SERVICE_NAME="app-mod-workshop"
REPO_NAME="app-mod-workshop"
GITHUB_REPO="tonyzorin/app-mod-workshop"
INSTANCE_NAME="appmod-phpapp"
DATABASE_NAME="image_catalog"

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

# Step 3: Create Cloud SQL instance (if it doesn't exist)
echo -e "${YELLOW}Step 3: Setting up Cloud SQL instance${NC}"
if ! gcloud sql instances describe $INSTANCE_NAME --quiet 2>/dev/null; then
    echo "Creating new Cloud SQL instance..."
    DB_PASSWORD="appmod-phpapp"
    
    gcloud sql instances create $INSTANCE_NAME \
        --database-version=MYSQL_8_0 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$DB_PASSWORD
    
    # Create database
    gcloud sql databases create $DATABASE_NAME --instance=$INSTANCE_NAME
    
    # Create database user
    DB_USER="appmod-phpapp-user"
    DB_USER_PASSWORD="appmod-phpapp"
    gcloud sql users create $DB_USER --instance=$INSTANCE_NAME --password=$DB_USER_PASSWORD
else
    echo "Cloud SQL instance $INSTANCE_NAME already exists"
    DB_PASSWORD="appmod-phpapp"
    DB_USER="appmod-phpapp-user"
    DB_USER_PASSWORD="appmod-phpapp"
fi

# Step 4: Store secrets in Secret Manager
echo -e "${YELLOW}Step 4: Storing secrets in Secret Manager${NC}"
echo -n "$DB_PASSWORD" | gcloud secrets create db-root-password --data-file=- 2>/dev/null || \
    echo -n "$DB_PASSWORD" | gcloud secrets versions add db-root-password --data-file=-
    
echo -n "$DB_USER_PASSWORD" | gcloud secrets create db-user-password --data-file=- 2>/dev/null || \
    echo -n "$DB_USER_PASSWORD" | gcloud secrets versions add db-user-password --data-file=-
    
echo -n "$INSTANCE_NAME" | gcloud secrets create db-instance-name --data-file=- 2>/dev/null || \
    echo -n "$INSTANCE_NAME" | gcloud secrets versions add db-instance-name --data-file=-

# Step 5: Create Artifact Registry repository (if it doesn't exist)
echo -e "${YELLOW}Step 5: Setting up Artifact Registry repository${NC}"
if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION --quiet 2>/dev/null; then
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker repository for $SERVICE_NAME"
else
    echo "Artifact Registry repository already exists"
fi

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
    --set-env-vars="DB_NAME=$DATABASE_NAME" \
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
echo "2. Import your database schema by running: ./import-db-schema.sh"
echo "3. Test the application"

# Save important information
cat > deployment-info.txt << EOF
Deployment Information
=====================
Project ID: $PROJECT_ID
Service Name: $SERVICE_NAME
Service URL: $SERVICE_URL
Database Instance: $INSTANCE_CONNECTION_NAME
Database Name: $DATABASE_NAME
Database User: $DB_USER
Database Password: $DB_USER_PASSWORD
Region: $REGION
Image URL: $IMAGE_URL
Container Repository: $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME

Secrets in Secret Manager:
- db-root-password
- db-user-password
- db-instance-name

Next Steps:
1. Set up Cloud Build trigger for CI/CD
2. Import database schema with: ./import-db-schema.sh
3. Test the application at: $SERVICE_URL
EOF

echo -e "${GREEN}📄 Deployment info saved to deployment-info.txt${NC}" 