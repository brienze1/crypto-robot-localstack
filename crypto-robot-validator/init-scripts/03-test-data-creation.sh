#!/bin/bash

echo "-----------------Script-03----------------- [validator]"

echo "########### Inserting test client credentials on DynamoDB 'crypto_robot.credentials' table ###########"
aws dynamodb put-item \
  --endpoint-url=http://localstack:4566 \
  --table-name crypto_robot.credentials \
  --item '{
              "client_id": {
                "S": "aa324edf-99fa-4a95-b9c4-a588d1ccb441e"
              },
              "api_key": {
                "S": "febf7e0f-7ef2-4da8-9afe-7f9f3721d9c6"
              },
              "api_secret": {
                "S": "a7aca6d4f67519fbb4dc65b159b4e9526b069a2cb5f515d4690bce05ba81e6e5967f477e0ce3affa7c80843f3efed1cee9b0c062"
              }
            }' \
  --return-consumed-capacity TOTAL

echo "########### Get created item from table ###########"
aws dynamodb get-item \
  --endpoint-url=http://localstack:4566 \
  --table-name crypto_robot.credentials \
  --key '{ "client_id": { "S": "aa324edf-99fa-4a95-b9c4-a588d1ccb441e" } }'
