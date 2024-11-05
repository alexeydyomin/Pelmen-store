#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge momo_network || true
sudo docker rm -f momo-backend || true
sudo docker run -d --name momo-backend \
     -p 8081:8081 \
     --network=momo_network \
     --restart=always \
     "${CI_REGISTRY_IMAGE}"/momo-backend:$VERSION