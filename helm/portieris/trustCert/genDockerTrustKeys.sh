#!/bin/bash
REGISTRY="${1:-<image-tag>}"
TAG=${2:-latest}
ROLE="${3:-circleci}"

openssl genrsa -out key.pem 2048
openssl rsa -in key.pem -outform PEM -pubout -out public.pem
chmod 0400 key.pem

docker trust key load key.pem --name ${ROLE}
docker trust signer add --key public.pem ${ROLE} ${REGISTRY}
docker trust sign ${REGISTRY}:${TAG}

echo -n ${ROLE} > ./name
cat public.pem > ./publicKey
