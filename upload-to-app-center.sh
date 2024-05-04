#!/bin/bash

# Exit script on any error
set -e

# Configuration variables (replace with your details)
APP_OWNER=""
APP_NAME=""
API_TOKEN=""
APK_PATH=""

# Function to display usage and exit
function usage() {
  echo "Usage: $0 -o owner -a app_name -t api_token -f apk_path"
  echo "-o: AppCenter owner name"
  echo "-a: App name in AppCenter"
  echo "-t: AppCenter API Token"
  echo "-f: Path to the APK file"
  exit 1
}

# Parse command-line arguments
while getopts ":o:a:t:f:" opt; do
  case $opt in
    o) APP_OWNER="$OPTARG" ;;
    a) APP_NAME="$OPTARG" ;;
    t) API_TOKEN="$OPTARG" ;;
    f) APK_PATH="$OPTARG" ;;
    \?) usage ;;
  esac
done

# Check if required arguments are provided
if [[ -z "$APP_OWNER" || -z "$APP_NAME" || -z "$API_TOKEN" || -z "$APK_PATH" ]]; then
  usage
fi

# Validate APK file existence
if [[ ! -f "$APK_PATH" ]]; then
  echo "Error: APK file not found: $APK_PATH"
  exit 1
fi

# Build upload URL
UPLOAD_URL="https://api.appcenter.ms/v0.1/apps/$APP_OWNER/$APP_NAME/uploads"

# Upload the APK
curl -X POST \
  -H "Content-Type: application/octet-stream" \
  -H "X-API-Token: $API_TOKEN" \
  -T "$APK_PATH" \
  "$UPLOAD_URL"

echo "APK uploaded successfully!"
