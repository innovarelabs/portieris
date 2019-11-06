#!/bin/bash
REGISTRY="${1:-}"
TAG=${2:-latest}
ROLE="${3:-circleci}"

openssl genrsa -out delegation-key.pem 2048
openssl rsa -in delegation-key.pem -outform PEM -pubout -out delegation-public.pem
chmod 0400 delegation-key.pem

notary init ${REGISTRY}
notary key rotate ${REGISTRY} snapshot -r
notary publish ${REGISTRY}
notary delegation add ${REGISTRY} targets/releases --all-paths delegation-public.pem -p
notary delegation add ${REGISTRY} targets/${ROLE} --all-paths delegation-public.pem -p

echo -n ${ROLE} > ./name
cat delegation-public.pem > ./publicKey
kubectl delete secret signe-secret --ignore-not-found=true
kubectl create secret generic signe-secret --from-file=./name --from-file=./publicKey
