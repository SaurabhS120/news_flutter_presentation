#!/bin/bash
set -e

DISTRIBUTION_GROUP="Public"
OWNER_NAME="saurabh.sonar120-gmail.com"
APP_NAME="News-App"
API_TOKEN=${{ secrets.APP_CENTER_TOKEN }}
RELEASE_FILE_LOCATION="build/app/outputs/flutter-apk/app-release.apk"
FILE_NAME="app-release.apk"

echo "=========CREATE NEW RELEASE=========="
createNewReleaseUploadResponse=$(curl -X \
POST "https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/uploads/releases" \
-H  "accept: application/json" \
-H  "X-API-Token: $API_TOKEN" \
-H  "Content-Type: application/json" \
-H "Content-Length: 0")

echo "Response JSON:"
echo "$createNewReleaseUploadResponse"

ID=$(echo "$createNewReleaseUploadResponse" | jq -r '.id')
PACKAGE_ASSET_ID=$(echo "$createNewReleaseUploadResponse" | jq -r '.package_asset_id')
URL_ENCODED_TOKEN=$(echo "$createNewReleaseUploadResponse" | jq -r '.url_encoded_token')

echo "$ID"
echo "$PACKAGE_ASSET_ID"
echo "$URL_ENCODED_TOKEN"

FILE_SIZE_BYTES=$(wc -c $RELEASE_FILE_LOCATION | awk '{print $1}')
echo "$FILE_SIZE_BYTES"
APP_TYPE='application/vnd.android.package-archive'

echo "=========UPLOAD METADATA TO GET CHUNK SIZE=========="
METADATA_URL="https://file.appcenter.ms/upload/set_metadata/$PACKAGE_ASSET_ID?file_name=$FILE_NAME&file_size=$FILE_SIZE_BYTES&token=$URL_ENCODED_TOKEN&content_type=$APP_TYPE"

metaDataResponse=$(curl -s -d POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "X-API-Token: $API_TOKEN" "$METADATA_URL")

echo "$metaDataResponse"

CHUNK_SIZE=$(echo "$metaDataResponse" | jq -r '.chunk_size')

echo "Chunk Size = $CHUNK_SIZE"

echo "=========CREATE FOLDER TEMP/SPLIT TO STORAGE LIST CHUNK FILE AFTER SPLIT=========="
if [ -d "[path]/temp" ]; then
  echo "Folder exists!"
else
  mkdir "[path]/temp"
fi

echo "=========SPLIT FILE=========="
split -b "$CHUNK_SIZE" "$RELEASE_FILE_LOCATION" "[path]/temp/split"

echo "=========UPLOAD CHUNK=========="
BLOCK_NUMBER=0

for i in /Users/mobileecom/Desktop/TestScript/temp/*
do
  if [ -f "$i" ]; then
    BLOCK_NUMBER=$(($BLOCK_NUMBER + 1))
    CONTENT_LENGTH=$(wc -c "$i" | awk '{print $1}')

    UPLOAD_CHUNK_URL="https://file.appcenter.ms/upload/upload_chunk/$PACKAGE_ASSET_ID?token=$URL_ENCODED_TOKEN&block_number=$BLOCK_NUMBER"

    curl -X POST "$UPLOAD_CHUNK_URL" \
--data-binary "@$i" \
-H "Content-Length: $CONTENT_LENGTH" \
-H "Content-Type: $APP_TYPE"
  fi
done

echo "=========FINISHED=========="
FINISHED_URL="https://file.appcenter.ms/upload/finished/$PACKAGE_ASSET_ID?token=$URL_ENCODED_TOKEN"
finishedUploadResponse=$(curl -d POST \
-H "Content-Type: application/json" \
-H "accept: application/json" \
-H "X-API-Token: $API_TOKEN" "$FINISHED_URL")
echo "$finishedUploadResponse"

echo "=========COMMIT=========="
COMMIT_URL="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/uploads/releases/$ID"
commitResponse=$(curl -H "Content-Type: application/json" \
-H "accept: application/json" \
-H "X-API-Token: $API_TOKEN" \
--data "{\"upload_status\": \"uploadFinished\",\"id\": \"$ID\"}" \
-X PATCH "$COMMIT_URL")
echo "$commitResponse"

echo "=========POLL RESULT=========="
RELEASE_STATUS_URL="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/uploads/releases/$ID"
echo "$RELEASE_STATUS_URL"


release_id=null
counter=0
max_poll_attempts=15

while [[ $release_id == null && ($counter -lt $max_poll_attempts)]]
do
    echo "$counter"
    poll_result=$(curl -X 'GET' "$RELEASE_STATUS_URL" \
-H "accept: application/json" \
-H "X-API-Token: $API_TOKEN")
    echo "$poll_result"
    release_id=$(echo "$poll_result" | jq -r '.release_distinct_id')
    echo "$release_id"
    counter=$((counter + 1))
    sleep 3
done

if [[ $release_id == null ]];
then
    echo "Failed to find release from appcenter"
    exit 1
fi

echo "=========DISTRIBUTE=========="
DISTRIBUTE_URL="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME/releases/$release_id"
echo "$DISTRIBUTE_URL"
distributeResponse=$(curl -H 'Content-Type: text/plain' \
-H 'accept: application/json' \
-H "X-API-Token: $API_TOKEN" \
--data '{"destinations": [{ "name": "'"$DISTRIBUTION_GROUP"'"}] }' \
-X PATCH "$DISTRIBUTE_URL")
echo "$distributeResponse"