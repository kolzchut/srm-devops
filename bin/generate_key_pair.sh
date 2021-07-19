#!/usr/bin/env bash

openssl genrsa -out .tmpkey 2048
PRIVATE_KEY="$(openssl rsa -in .tmpkey -outform pem)"
PUBLIC_KEY="$(openssl rsa -in .tmpkey -outform pem -pubout)"
rm .tmpkey

echo | base64 -w0 > /dev/null 2>&1
if [ $? -eq 0 ]; then
  # GNU coreutils base64, '-w' supported
  BASE64SWITCH=-w0
else
  # Openssl base64, no wrapping by default
  BASE64SWITCH=-b0
fi


echo "PRIVATE_KEY_B64=$(echo "${PRIVATE_KEY}" | base64 $BASE64SWITCH)"
echo "PUBLIC_KEY_B64=$(echo "${PUBLIC_KEY}" | base64 $BASE64SWITCH)"
