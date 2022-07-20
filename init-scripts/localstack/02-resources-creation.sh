#!bin/bash

echo "-----------------Script-02----------------- [localstack]"

echo "########### Creating SQS ###########"
aws sqs create-queue --queue-name cryptoAnalysisQueue --endpoint-url http://localhost:4566

echo "########### Creating SNS ###########"
aws sns create-topic --name cryptoAnalysisTopic --endpoint-url http://localhost:4566

echo "########### Listing SQS ###########"
aws sqs list-queues --endpoint-url http://localhost:4566

echo "########### Listing SNS ###########"
aws sns list-topics --endpoint-url http://localhost:4566

echo "########### Subscribing SQS to SNS ###########"
aws sns subscribe --topic-arn arn:aws:sns:sa-east-1:000000000000:cryptoAnalysisTopic --protocol sqs --notification-endpoint "http://localhost:4566/000000000000/cryptoAnalysisQueue" --endpoint-url http://localhost:4566

echo "########### Listing SNS Subscriptions ###########"
aws sns list-subscriptions --endpoint-url http://localhost:4566

echo "########### Make S3 bucket for lambdas ###########"
aws s3 mb s3://lambda-functions --endpoint-url http://localhost:4566

echo "########### Create Admin IAM Role ###########"
aws iam create-role --role-name admin-role --path / --assume-role-policy-document file:./admin-policy.json --endpoint-url http://localstack:4566