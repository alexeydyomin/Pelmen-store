# Stage 1: Build the frontend
FROM node:16.20.0-alpine3.18 AS builder
WORKDIR /usr/src/app
COPY . .

# VUE_APP_BASE_URL=http://std-030-78.praktikum-services.tech/  - заменить на свою dns запись
ENV VUE_APP_BASE_URL=http://std-030-78.praktikum-services.tech/

RUN npm install

# NODE_ENV=production - меняем чтоб не было в пути http://std-030-78.praktikum-services.tech:8081/momo-store/
RUN NODE_ENV=test VUE_APP_API_URL=http://std-030-78.praktikum-services.tech:8081 npm run build


# Stage 2: Serve the frontend with Nginx
FROM nginxproxy/nginx-proxy:1.3.1-alpine
WORKDIR /app
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
