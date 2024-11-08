<div align="center"> 

![](/images/terraform.png) 

##  *Создание своей собственной ВМ в Yandex Cloud*
*Сделано пользователем *std-030-35@praktikum-services.ru* он же **Алексей Дёмин***

</div>

**Требования**:

> 🔎 Создание своей собственной ВМ в Yandex Cloud используя Terraform   
> 🔎 Установка сервера Minio на ВМ в Yandex Cloud  

<br>




**Выполненная работа:**

- Был создан новый каталог terraform в репозитории - https://gitlab.praktikum-services.ru/std-030-35/momo-store/terraform

![My Momo Store](/images/repos.png "My Momo Store")  
<br>
- Был создан главный **gitlab-ci.yml**, который находится в корне репозитория.

```yml
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
<br>

- Артифакты сборки мы публикуем в **Container Registry** - https://gitlab.praktikum-services.ru/std-030-35/momo-store/container_registry 

- Созданы Dockerfile для обоих сервисов Пельменной.

##  *Backend* 🐳
Сильно помогла инструкция - https://docs.docker.com/guides/golang/build-images/  

```yml
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
<br>

##  *Frontend* 🐳


```yml
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
<br>

- В результате сборки контейнеров мы получаем работающую пельменную, и дальше двигаемся в сторону автоматизации.  
Пишем для каждого сервиса, Backend/Frontend свои **momo-store/frontend/.gitlab-ci.yml** и **momo-store/backend/.gitlab-ci.yml**  
<br>

> Frontend - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/blob/main/frontend/.gitlab-ci.yml?ref_type=heads  
> Backend - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/blob/main/backend/.gitlab-ci.yml?ref_type=heads

<br>
