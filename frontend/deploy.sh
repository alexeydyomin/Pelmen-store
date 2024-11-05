#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge momo_network || true
sudo docker rm -f momo-frontend || true
sudo docker run --rm -d --name momo-frontend \
     -p 80:80 \
     --network=momo_network \
     --restart=always \
     "${CI_REGISTRY_IMAGE}"/momo-frontend:$VERSION