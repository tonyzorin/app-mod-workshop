#!/bin/bash

# Setup Cloud Build Triggers for CI/CD Pipeline
# This script creates triggers for automatic builds on git push

PROJECT_ID="kinetic-magnet-106116"
REPO_NAME="app-mod-workshop"
GITHUB_OWNER="your-github-username"  # Change this to your GitHub username

echo "🔧 Setting up Cloud Build triggers for CI/CD..."

# Set the project
gcloud config set project $PROJECT_ID

# Create trigger for all branches (basic pipeline)
echo "📋 Creating trigger for all branches (basic pipeline)..."
gcloud builds triggers create github \
    --repo-name=$REPO_NAME \
    --repo-owner=$GITHUB_OWNER \
    --branch-pattern=".*" \
    --build-config="cloudbuild.yaml" \
    --description="Basic CI/CD pipeline for all branches" \
    --name="basic-pipeline"

# Create trigger for main branch (advanced pipeline)
echo "📋 Creating trigger for main branch (advanced pipeline)..."
gcloud builds triggers create github \
    --repo-name=$REPO_NAME \
    --repo-owner=$GITHUB_OWNER \
    --branch-pattern="^main$" \
    --build-config="cloudbuild-advanced.yaml" \
    --description="Advanced CI/CD pipeline for main branch" \
    --name="advanced-pipeline-main"

# Create trigger for dev branch (development pipeline)
echo "📋 Creating trigger for dev branch (development pipeline)..."
gcloud builds triggers create github \
    --repo-name=$REPO_NAME \
    --repo-owner=$GITHUB_OWNER \
    --branch-pattern="^dev$" \
    --build-config="cloudbuild-advanced.yaml" \
    --description="Development pipeline for dev branch" \
    --name="dev-pipeline"

# Create trigger for pull requests
echo "📋 Creating trigger for pull requests..."
gcloud builds triggers create github \
    --repo-name=$REPO_NAME \
    --repo-owner=$GITHUB_OWNER \
    --pull-request-pattern=".*" \
    --build-config="cloudbuild.yaml" \
    --description="CI pipeline for pull requests" \
    --name="pr-pipeline"

echo "✅ Cloud Build triggers created successfully!"
echo ""
echo "📋 Summary of triggers:"
echo "  1. basic-pipeline: Runs on all branches"
echo "  2. advanced-pipeline-main: Advanced pipeline for main branch"
echo "  3. dev-pipeline: Development pipeline for dev branch" 
echo "  4. pr-pipeline: CI pipeline for pull requests"
echo ""
echo "🔗 View triggers at: https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID"
echo ""
echo "📝 Next steps:"
echo "  1. Update GITHUB_OWNER in this script with your GitHub username"
echo "  2. Connect your GitHub repository to Cloud Build"
echo "  3. Push code to trigger automatic builds" 