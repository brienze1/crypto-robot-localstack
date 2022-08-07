#!/bin/bash

echo "-----------------Script-02----------------- [data-digest]"

echo "########### Creating SQS ###########"
aws sqs create-queue --queue-name cryptoAnalysisQueue --endpoint-url http://localstack:4566

echo "########### Listing SQS ###########"
aws sqs list-queues --endpoint-url http://localstack:4566

echo "########### Subscribing SQS to SNS ###########"
aws sns subscribe \
--topic-arn arn:aws:sns:sa-east-1:000000000000:cryptoAnalysisTopic \
--protocol sqs \
--notification-endpoint "http://localhost:4566/000000000000/cryptoAnalysisQueue" \
--endpoint-url http://localstack:4566

echo "########### Listing SNS Subscriptions ###########"
aws sns list-subscriptions --endpoint-url http://localstack:4566

echo "########### Creating SNS ###########"
aws sns create-topic --name cryptoAnalysisSummaryTopic --endpoint-url http://localstack:4566

echo "########### Listing SNS ###########"
aws sns list-topics --endpoint-url http://localstack:4566

echo "########### Copy the lambda function to the S3 bucket ###########"
aws s3 cp /lambda-files/crypto-robot-data-digest.zip s3://lambda-functions --endpoint-url http://localstack:4566

echo "########### Create the lambda dataDigestLambda ###########"
aws lambda create-function \
  --endpoint-url http://localstack:4566 \
  --function-name dataDigestLambda \
  --role arn:aws:iam::000000000000:role/admin-role \
  --code S3Bucket=lambda-functions,S3Key=crypto-robot-data-digest.zip \
  --handler ./dist/main/delivery/handler/Handler.execute \
  --runtime nodejs16.x \
  --description "SQS Lambda handler for test sqs." \
  --timeout 60 \
  --memory-size 128

echo "########### Map the cryptoAnalysisQueue to the dataDigestLambda lambda function ###########"
aws lambda create-event-source-mapping \
  --function-name dataDigestLambda \
  --batch-size 1 \
  --event-source-arn "arn:aws:sqs:sa-east-1:000000000000:cryptoAnalysisQueue" \
  --endpoint-url http://localstack:4566

echo "########### Creating DynamoDB 'crypto_robot.analyzed_data' table ###########"
aws dynamodb create-table \
--table-name crypto_robot.analyzed_data  \
--attribute-definitions AttributeName=interval,AttributeType=S \
--key-schema AttributeName=interval,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
--endpoint-url=http://localstack:4566