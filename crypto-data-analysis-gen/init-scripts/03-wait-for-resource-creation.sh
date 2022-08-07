#!/bin/bash

echo "-----------------Script-03----------------- [data-analysis-gen]"

echo "########### Waiting for awscli container finish loading ###########"
while ping -c1 awscli &>/dev/null; do
  sleep 1
done

echo "Container awscli finished creating resources"
