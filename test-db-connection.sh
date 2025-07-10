#!/bin/bash

# Test Database Connection Script
# This script tests the connection to the Cloud SQL instance

set -e

PROJECT_ID="kinetic-magnet-106116"
INSTANCE_NAME="appmod-phpapp"
DATABASE_NAME="image_catalog"
DB_USER="appmod-phpapp-user"
DB_PASSWORD="appmod-phpapp"
DB_IP="34.154.174.181"

echo "🔍 Testing Cloud SQL connection..."

# Test 1: Check if instance is accessible via gcloud
echo "1. Checking Cloud SQL instance status..."
gcloud sql instances describe $INSTANCE_NAME --format="table(name,state,region,ipAddresses[0].ipAddress)"

# Test 2: List databases
echo "2. Listing databases..."
gcloud sql databases list --instance=$INSTANCE_NAME --format="table(name)"

# Test 3: Check if our database exists
echo "3. Checking if image_catalog database exists..."
if gcloud sql databases describe $DATABASE_NAME --instance=$INSTANCE_NAME --quiet 2>/dev/null; then
    echo "✅ Database '$DATABASE_NAME' exists"
else
    echo "❌ Database '$DATABASE_NAME' not found"
    echo "Creating database..."
    gcloud sql databases create $DATABASE_NAME --instance=$INSTANCE_NAME
    echo "✅ Database '$DATABASE_NAME' created"
fi

# Test 4: Check if user exists
echo "4. Checking if database user exists..."
if gcloud sql users list --instance=$INSTANCE_NAME --filter="name=$DB_USER" --format="value(name)" | grep -q "$DB_USER"; then
    echo "✅ User '$DB_USER' exists"
else
    echo "❌ User '$DB_USER' not found"
    echo "Creating user..."
    gcloud sql users create $DB_USER --instance=$INSTANCE_NAME --password=$DB_PASSWORD
    echo "✅ User '$DB_USER' created"
fi

# Test 5: Test connection using gcloud
echo "5. Testing connection via gcloud..."
if gcloud sql connect $INSTANCE_NAME --user=$DB_USER --quiet --command="SELECT 'Connection successful!' as status;" 2>/dev/null; then
    echo "✅ Connection via gcloud successful"
else
    echo "⚠️ Connection via gcloud failed (this might be due to authentication)"
fi

echo ""
echo "🎯 Connection Details:"
echo "Instance: $INSTANCE_NAME"
echo "Region: europe-west8"
echo "IP Address: $DB_IP"
echo "Port: 3306"
echo "Database: $DATABASE_NAME"
echo "User: $DB_USER"
echo "Password: $DB_PASSWORD"
echo ""
echo "📝 Manual connection command:"
echo "mysql -h $DB_IP -P 3306 -u $DB_USER -p$DB_PASSWORD $DATABASE_NAME"
echo ""
echo "🔗 Cloud SQL connection string for Cloud Run:"
echo "DB_HOST=/cloudsql/$PROJECT_ID:europe-west8:$INSTANCE_NAME"
echo "DB_NAME=$DATABASE_NAME"
echo "DB_USER=$DB_USER"
echo "DB_PASSWORD=$DB_PASSWORD" 