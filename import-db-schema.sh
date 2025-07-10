#!/bin/bash

# Database Schema Import Script for Cloud SQL
# This script imports the database schema and seed data to Cloud SQL

set -e

PROJECT_ID="kinetic-magnet-106116"
INSTANCE_NAME="appmod-phpapp"
DATABASE_NAME="image_catalog"
BUCKET_NAME="${PROJECT_ID}-sql-imports"

echo "🗄️  Importing database schema to Cloud SQL..."

# Create storage bucket for SQL files
echo "Creating storage bucket..."
gsutil mb gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already exists"

# Upload SQL files to Cloud Storage
echo "Uploading SQL files to Cloud Storage..."
gsutil cp db/01_schema.sql gs://$BUCKET_NAME/
gsutil cp db/02_seed.sql gs://$BUCKET_NAME/

# Import schema
echo "Importing database schema..."
gcloud sql import sql $INSTANCE_NAME gs://$BUCKET_NAME/01_schema.sql --database=$DATABASE_NAME

# Import seed data
echo "Importing seed data..."
gcloud sql import sql $INSTANCE_NAME gs://$BUCKET_NAME/02_seed.sql --database=$DATABASE_NAME

echo "✅ Database schema and seed data imported successfully!"

# Clean up
echo "Cleaning up temporary files..."
gsutil rm gs://$BUCKET_NAME/01_schema.sql
gsutil rm gs://$BUCKET_NAME/02_seed.sql
gsutil rb gs://$BUCKET_NAME

echo "🎉 Database import completed!" 