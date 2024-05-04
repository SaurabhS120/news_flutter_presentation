#!/bin/bash

# Your App Center API token
APP_CENTER_TOKEN=$1

# Your App Center owner name
OWNER_NAME="Saurabh.sonar120@gmail.com"

# Your App Center app name
APP_NAME="News-App"

# Path to your APK file
APK_FILE_PATH="build/app/outputs/flutter-apk/app-release.apk"


# App Center upload API endpoint
UPLOAD_START_ENDPOINT="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/uploads/apk"
UPLOAD_CONTINUE_ENDPOINT="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/uploads/uploads/$UPLOAD_ID"

# Start the upload
response=$(curl -X POST \
    -H "Content-Type: application/json" \
    -H "X-API-Token: $APP_CENTER_TOKEN" \
    $UPLOAD_START_ENDPOINT)

# Extract upload ID from response
UPLOAD_ID=$(echo $response | jq -r '.upload_id')

# Upload the APK file in parts
response=$(curl -X POST \
    -F "file=@$APK_FILE_PATH" \
    -H "Content-Type: application/octet-stream" \
    -H "X-API-Token: $APP_CENTER_TOKEN" \
    $UPLOAD_CONTINUE_ENDPOINT)

# Print response
echo $response
