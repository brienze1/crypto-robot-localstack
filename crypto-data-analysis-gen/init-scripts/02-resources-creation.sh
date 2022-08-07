#!/bin/bash

echo "-----------------Script-03----------------- [data-digest]"

echo "########### Creating SNS ###########"
aws sns create-topic --name cryptoAnalysisTopic --endpoint-url http://localstack:4566

echo "########### Listing SNS ###########"
aws sns list-topics --endpoint-url http://localstack:4566