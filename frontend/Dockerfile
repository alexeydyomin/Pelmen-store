# Stage 1: Build the frontend
FROM node:16.20.0-alpine3.18 AS builder
WORKDIR /usr/src/app
COPY . .

# # VUE_APP_BASE_URL=http://std-030-78.praktikum-services.tech/  - заменить на свою dns запись
# ENV VUE_APP_BASE_URL=https://vm.momo-store.cloud-ip.biz/
ENV NODE_ENV=test
# ENV VUE_APP_API_URL=https://vm.momo-store.cloud-ip.biz:8081




RUN npm install

# NODE_ENV=production - меняем чтоб не было в пути http://std-030-78.praktikum-services.tech:8081/momo-store/
RUN npm run build


# Stage 2: Serve the frontend with Nginx
FROM nginx:stable-alpine3.17-slim
WORKDIR /app
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
# COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
