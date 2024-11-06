##  *Momo Store aka Пельменная №2 &trade;*
*Сделано пользователем *std-030-35@praktikum-services.ru* он же **Алексей Дёмин***

---
![My Momo Store](/images/storemomo.png "My Momo Store")  
___


## *Первый этап - Погнали :)*

**Требования**:
>
> * Код хранится в GitLab с использованием любого git-flow  
> * В проекте присутствует .gitlab-ci.yml, в котором описаны шаги сборки
> * Артефакты сборки (бинарные файлы, docker-образы или др.) публикуются в систему хранения (Nexus или аналоги)
> * Артефакты сборки версионируются
> * Написаны Dockerfile'ы для сборки Docker-образов бэкенда и фронтенда
> * Бэкенд: бинарный файл Go в Docker-образе
> * Фронтенд: HTML-страница раздаётся с Nginx
> * В GitLab CI описан шаг сборки и публикации артефактов
> * В GitLab CI описан шаг тестирования
> * В GitLab CI описан шаг деплоя

___
  


**Выполненная работа:**

- Был создан новый репозиторий - https://gitlab.praktikum-services.ru/std-030-35/momo-store  

![My Momo Store](/images/repos.png "My Momo Store")  

- Был создан главный **gitlab-ci.yml**, который находится в корне репозитория.

```yaml
stages:
  - module-pipelines

frontend:
  stage: module-pipelines
  trigger:
    include:
      - "/frontend/.gitlab-ci.yml"
    strategy: depend
  only:
    changes:
      - frontend/**/*

backend:
  stage: module-pipelines
  trigger:
    include:
      - "/backend/.gitlab-ci.yml"
    strategy: depend
  only:
    changes:
      - backend/**/*

```  
  
- Артифакты сборки мы публикуем в **Container Registry** - https://gitlab.praktikum-services.ru/std-030-35/momo-store/container_registry 

- Созданы Dockerfile для обоих сервисов Пельменной.

##  *Backend* 🐳
Сильно помогла инструкция - https://docs.docker.com/guides/golang/build-images/  

```yaml
# Stage 1: Сборка backend - получаем бинарный файл.
FROM golang:1.20 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o api ./cmd/api

# Stage 2: Запускаем полученный файл.
FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=builder /app/api .

EXPOSE 8081

CMD ["./api"]
```  
##  *Frontend* 🐳


```yaml
# Stage 1: Build the frontend
FROM node:16.20.0-alpine3.18 AS builder
WORKDIR /usr/src/app
COPY . .
# VUE_APP_BASE_URL=http://std-030-78.praktikum-services.tech/  - заменить на свою dns запись
ENV VUE_APP_BASE_URL=http://std-030-78.praktikum-services.tech/
ENV NODE_ENV=test
ENV VUE_APP_API_URL=http://std-030-78.praktikum-services.tech:8081
RUN npm install
# NODE_ENV=production - меняем чтоб не было в пути http://std-030-78.praktikum-services.tech:8081/momo-store/
RUN npm run build

# Stage 2: Serve the frontend with Nginx
FROM nginx:stable-alpine3.17-slim
WORKDIR /app
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
```
---
- В результате сборки контейнеров мы получаем работающую пельменную, и дальше двигаемся в сторону автоматизации.  
Пишем для каждого сервиса, Backend/Frontend свои **momo-store/frontend/.gitlab-ci.yml** и **momo-store/backend/.gitlab-ci.yml**

> Frontend - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/blob/main/frontend/.gitlab-ci.yml?ref_type=heads  
> Backend - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/blob/main/backend/.gitlab-ci.yml?ref_type=heads

- Для сборки Docker контейнеров используется **Docker-in-Docker** а именно образ **gcr.io/kaniko-project/executor**
  
Сборка и публикация 
```YAML
variables:
  VERSION: 1.0.${CI_PIPELINE_ID}  # Переменную используем для версионированя наших сборок

stages:
  - build    # Сорка docker образа
  - release  # Выгрузка готового образа в Container Registry
  - deploy   # Деплой docker контейнеров на хост

build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}/backend"
      --dockerfile "${CI_PROJECT_DIR}/backend/Dockerfile"   # Передаем наш Dockerfile 
      --destination "${CI_REGISTRY_IMAGE}/momo-backend:$CI_COMMIT_SHA"
      --build-arg VERSION=$VERSION
      --cache=true

release:
  variables:
    GIT_STRATEGY: none
  image:
    name: gcr.io/go-containerregistry/crane:debug
    entrypoint: [""]
  cache: []
  stage: release
  before_script:
    - crane auth login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - crane tag $CI_REGISTRY_IMAGE/momo-backend:$CI_COMMIT_SHA $VERSION  

# Стадия деплоя готовых docker контейнеров на наш хост
deploy:
  stage: deploy
  image: alpine:3.18
  before_script:
    - apk add openssh-client bash gettext
    - eval $(ssh-agent -s)
    - echo "${SSH_PRIVATE_KEY}" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
    - ssh-keygen -R ${DEV_HOST}
    - ssh -o StrictHostKeyChecking=no ${DEV_USER}@${DEV_HOST} "mkdir -p /tmp/${CI_PROJECT_DIR}/backend/"
    - envsubst < ./backend/deploy.sh|ssh ${DEV_USER}@${DEV_HOST}
  script:
    - echo "Deployment step is complete"

```

- При этом мы используем скрипт deploy.sh который для backend выглядит так:  
```bash
#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge momo_network || true  # Создаем отдельную сеть для нашей Пельменной
sudo docker rm -f momo-backend || true
sudo docker run -d --name momo-backend \
     -p 8081:8081 \
     --network=momo_network \
     --restart=always \
     "${CI_REGISTRY_IMAGE}"/momo-backend:$VERSION
```
---
- **В результате нам удалось выполнить все поставленные на первый этап задачи.** 👌💪 😎

✅  Код хранится в GitLab с использованием любого git-flow  
✅ В проекте присутствует .gitlab-ci.yml, в котором описаны шаги сборки  
✅ Артефакты сборки (бинарные файлы, docker-образы или др.) публикуются в систему хранения (Nexus или аналоги)  
✅  Артефакты сборки версионируются  
✅   Написаны Dockerfile'ы для сборки Docker-образов бэкенда и фронтенда  
✅   Бэкенд: бинарный файл Go в Docker-образе  
✅  Фронтенд: HTML-страница раздаётся с Nginx  
✅ В GitLab CI описан шаг сборки и публикации артефактов  
✅ В GitLab CI описан шаг тестирования  
✅ В GitLab CI описан шаг деплоя
  
---
 


 
