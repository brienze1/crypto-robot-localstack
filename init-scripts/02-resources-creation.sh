#!bin/bash

echo "-------------------------------------Script-02"

echo "########### Creating SQS ###########"
awslocal sqs create-queue --queue-name cryptoAnalysisQueue --profile=localstack

echo "########### Creating SNS ###########"
awslocal sns create-topic --name cryptoAnalysisTopic --profile=localstack

echo "########### Listing SQS ###########"
awslocal sqs list-queues --profile=localstack

echo "########### Listing SNS ###########"
awslocal sns list-topics --profile=localstack

echo "########### Subscribing SQS to SNS ###########"
awslocal sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:cryptoAnalysisTopic --protocol sqs --notification-endpoint "http://localhost:4566/000000000000/cryptoAnalysisQueue" --profile=localstack

echo "########### Listing SNS Subscriptions ###########"
awslocal sns list-subscriptions --profile=localstack
