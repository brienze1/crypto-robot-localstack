#!bin/bash

echo "-------------------------------------Script-02"

echo "########### Creating SQS ###########"
awslocal sqs create-queue --queue-name testQueue --profile=localstack

echo "########### Creating SNS ###########"
awslocal sns create-topic --name testTopic --profile=localstack

echo "########### Listing SQS ###########"
awslocal sqs list-queues --profile=localstack

echo "########### Listing SNS ###########"
awslocal sns list-topics --profile=localstack

echo "########### Subscribing SQS to SNS ###########"
awslocal sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:testTopic --protocol sqs --notification-endpoint "http://localhost:4566/000000000000/testQueue" --profile=localstack

echo "########### Listing SNS Subscriptions ###########"
awslocal sns list-subscriptions --profile=localstack
