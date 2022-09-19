#!/bin/bash


echo "-----------------Script-02----------------- [operation-hub]"

echo "########### Creating SQS ###########"
aws sqs create-queue --queue-name cryptoOperationHubQueue --endpoint-url http://localstack:4566

echo "########### Listing SQS ###########"
aws sqs list-queues --endpoint-url http://localstack:4566

echo "########### Subscribing SQS to SNS ###########"
aws sns subscribe \
--topic-arn arn:aws:sns:sa-east-1:000000000000:cryptoAnalysisSummaryTopic \
--protocol sqs \
--notification-endpoint "http://localhost:4566/000000000000/cryptoOperationHubQueue" \
--endpoint-url http://localstack:4566

echo "########### Listing SNS Subscriptions ###########"
aws sns list-subscriptions --endpoint-url http://localstack:4566

echo "########### Creating SNS ###########"
aws sns create-topic --name cryptoOperationTriggerTopic --endpoint-url http://localstack:4566

echo "########### Listing SNS ###########"
aws sns list-topics --endpoint-url http://localstack:4566

echo "########### Create secrets manager ###########"
aws secretsmanager create-secret --name cryptoRobotOperationHubSecret --secret-string '{"host":"localhost","port":5432,"user":"postgres","password":"postgres","db_name":"crypto_robot"}' --endpoint-url http://localstack:4566

echo "########### Copy the lambda function to the S3 bucket ###########"
aws s3 cp /lambda-files/crypto-robot-operation-hub.zip s3://lambda-functions --endpoint-url http://localstack:4566

echo "########### Creating DynamoDB 'crypto_robot.clients' table ###########"
aws dynamodb create-table \
--table-name crypto_robot.clients  \
--attribute-definitions AttributeName=client_id,AttributeType=S \
--key-schema AttributeName=client_id,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
--endpoint-url=http://localstack:4566

echo "########### Inserting test client on DynamoDB 'crypto_robot.clients' table ###########"
aws dynamodb put-item \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --table-name crypto_robot.clients \
    --item '{
              "client_id": {
                "S": "aa324edf-99fa-4a95-b9c4-a588d1ccb441e"
              },
              "active": {
                "BOOL": true
              },
              "locked_until": {
                "S": "2022-09-17T12:05:07.45066-03:00"
              },
              "locked": {
                "BOOL": false
              },
              "cash_amount": {
                "N": "1000.00"
              },
              "cash_reserved": {
                "N": "0"
              },
              "crypto_amount": {
                "N": "1.000000"
              },
              "crypto_symbol": {
                "S": "BTC"
              },
              "crypto_reserved": {
                "N": "0"
              },
              "buy_on": {
                "N": "1"
              },
              "sell_on": {
                "N": "1"
              },
              "ops_timeout_seconds": {
                "N": "60"
              },
              "operation_stop_loss": {
                "N": "50"
              },
              "day_stop_loss": {
                "N": "500"
              },
              "month_stop_loss": {
                "N": "500"
              },
              "month_sell_cap": {
                "N": "25000"
              },
              "symbols": {
                "L": [
                  {
                    "S": "BTC"
                  },
                  {
                    "S": "SOL"
                  }
                ]
              },
              "monthly_summary": {
                "M": {
                  "month": {
                    "S": "08/2022"
                  },
                  "amount_sold": {
                    "N": "23000.42"
                  },
                  "amount_bought": {
                    "N": "37123.42"
                  },
                  "profit": {
                    "N": "1032.32"
                  },
                  "crypto": {
                    "L": [
                      {
                        "M": {
                          "profit": {
                            "N": "-53"
                          }
                        }
                      }
                    ]
                  }
                }
              },
              "daily_summary": {
                "M": {
                  "day": {
                    "S": "14/08/2022"
                  },
                  "amount_sold": {
                    "N": "23000.42"
                  },
                  "amount_bought": {
                    "N": "37123.42"
                  },
                  "profit": {
                    "N": "-53"
                  },
                  "crypto": {
                    "L": [
                      {
                        "M": {
                          "profit": {
                            "N": "-53"
                          }
                        }
                      }
                    ]
                  }
                }
              }
            }' \
    --return-consumed-capacity TOTAL

echo "########### Get created item from table ###########"
aws dynamodb get-item \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --table-name crypto_robot.clients \
    --key '{ "client_id": { "S": "aa324edf-99fa-4a95-b9c4-a588d1ccb441e" } }'

echo "########### Create the lambda operationHubLambda ###########"
aws lambda create-function \
  --endpoint-url http://localstack:4566 \
  --function-name operationHubLambda \
  --role arn:aws:iam::000000000000:role/admin-role \
  --code S3Bucket=lambda-functions,S3Key=crypto-robot-operation-hub.zip \
  --handler ./crypto-robot-operation-hub/operation-hub \
  --runtime go1.x \
  --description "SQS Lambda handler for test sqs." \
  --timeout 60 \
  --memory-size 128

echo "########### Map the cryptoOperationHubQueue to the operationHubLambda lambda function ###########"
aws lambda create-event-source-mapping \
  --function-name operationHubLambda \
  --batch-size 1 \
  --event-source-arn "arn:aws:sqs:sa-east-1:000000000000:cryptoOperationHubQueue" \
  --endpoint-url http://localstack:4566
