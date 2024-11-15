<div align="center"> 

![](/images/logo.png) 

##  *Momo Store aka Пельменная №2 &trade;*
*Сделано пользователем *std-030-35* он же **Алексей Дёмин***

Адрес пельменной  - https://vm.momo-store.cloud-ip.biz/

---
![My Momo Store](/images/storemomo.png "My Momo Store")  

---


## *Третий этап*
</div>

**Требования**:
>
> 🔎 Написаны Kubernetes-манифесты для публикации приложения

---
  
<br>

**Выполненная работа:**

- Был создан новый каталог kubernetes в репозитории - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/tree/main/kubernetes

![](/images/kuber-repos.png) 


---

<br>

- Добавлены bash скрипты для установки ingress контроллера, VPA, cert-manager на хост.  

<br>

```sh
### cert-manager.sh

#! /bin/bash

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 \
  --set installCRDs=true
``` 
  
  ```sh
### ingress-nginx.sh

#! /bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```  
  ```sh
### vpa.sh

#! /bin/bash

git clone https://github.com/kubernetes/autoscaler.git && \
cd autoscaler/vertical-pod-autoscaler/hack && \
./vpa-up.sh
``` 

---
<br>

- Созданы основные манифест файлы для деплоя пельменной на кластер kubernetes

**Frontend Deployment**
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
  labels:
    app: frontend
spec:
  revisionHistoryLimit: 15
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          # image: gitlab.praktikum-services.ru:5050/std-030-35/momo-store/frontend:1.0.1635969
          image: ${CI_REGISTRY_IMAGE}/frontend:${VERSION}
          imagePullPolicy: IfNotPresent
          ports:
            - name: frontend
              containerPort: 80
          volumeMounts:
            - name: nginx-config-volume
              mountPath: /etc/nginx/conf.d/nginx.conf
              subPath: nginx.conf
          resources:
            limits:
              cpu: "0.2"
              memory: 512Mi
            requests:
              cpu: "0.1"
              memory: 128Mi
      volumes:
        - name: nginx-config-volume
          configMap:
            name: nginx-conf
      imagePullSecrets:
        - name: docker-config-secret
```
---  

**Frontend Configmap**
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf
  namespace: default
data:
  nginx.conf: |
    upstream backend {
      server backend:8081;
    }
    server {

      listen 80;
      server_name localhost;
      location / {
        root   /usr/share/nginx/html;
        index  index.html;
        try_files $uri $uri/ /index.html;
      }

      location /products {
          proxy_pass http://backend;
      }

      location /categories {
          proxy_pass http://backend;
      }

      location /auth {
          proxy_pass http://backend;
      }
    }
```
<br>

--- 

- Домен был зарегистрирован на бесплатной площадке - https://www.cloudns.net/ 

![](/images/cloud11.png) 

---  


- Там же была создана А запись на нашу пельменную.  

![](/images/a-cloud.png)  

---

- Для получения бесплатного сертификата использовалась эта инструкция - https://cert-manager.io/docs/installation/helm/#prerequisites 
- И еще эта - https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-4---deploy-an-example-service

 ---

 - В результате Пельменная получила автоматически самообновляемый сертификат:

![](/images/cert.png)  

<br>  


![](/images/cert2.png) 

---


- Для **CICD** созданы переменные:

![](/images/vars.png) 


- И для автоматического деплоя был изменен gitlab-ci для Backend и Frontend

```yaml
### Backend

# Стадия актуальна для деплоя пельменной в kubernetes
deploy:
  stage: deploy
  image: alpine/k8s:1.28.14
  environment:
    name: Kubernetes/backend
    url: http://vm.momo-store.cloud-ip.biz
  only:
    changes:
      - kubernetes/backend/**/*
      - backend/**/*
  before_script:
    - apk add gettext
    - curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    - ln -s /root/yandex-cloud/bin/yc /usr/bin/yc
    - pwd
    - ls -la
    - yc config profile create momo-alex
    - yc config set token ${TOKEN} --profile momo-alex
    - yc config set folder-id ${FOLDER_ID} --profile momo-alex
    - yc config set cloud-id ${CLOUD_ID} --profile momo-alex
  script:
    - mkdir -p .kube
    - echo "$KUBECONFIG_BASE64"
    - echo "$KUBECONFIG_BASE64" | base64 -d > .kube/config
    - export KUBECONFIG=.kube/config
    - ls -la .kube/config
    - cat .kube/config
    - printenv
    - echo ${VERSION}
    - echo ${CI_REGISTRY_IMAGE}
    - kubectl config set-context --current --namespace=default
    - kubectl apply -f kubernetes/backend/secrets.yaml
    - envsubst < kubernetes/backend/deployment.yaml | kubectl apply -f -
    - kubectl apply -f kubernetes/backend/service.yaml
    - kubectl apply -f kubernetes/backend/vpa.yaml
  after_script:
    - rm -f .kube/config
  ```  
<br>

  ```yaml
### Frontend

# Стадия актуальна для деплоя пельменной в kubernetes
deploy:
  stage: deploy
  image: alpine/k8s:1.28.14
  environment:
    name: Kubernetes/frontend
    url: http://vm.momo-store.cloud-ip.biz
  only:
    changes:
      - kubernetes/frontend/**/*
      - frontend/**/*
  before_script:
    - curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    - ln -s /root/yandex-cloud/bin/yc /usr/bin/yc
    - pwd
    - ls -la
    - yc config profile create momo-alex
    - yc config set token ${TOKEN} --profile momo-alex
    - yc config set folder-id ${FOLDER_ID} --profile momo-alex
    - yc config set cloud-id ${CLOUD_ID} --profile momo-alex
  script:
    - mkdir -p .kube
    - echo "$KUBECONFIG_BASE64"
    - echo "$KUBECONFIG_BASE64" | base64 -d > .kube/config
    - export KUBECONFIG=.kube/config
    - ls -la .kube/config
    - cat .kube/config
    - kubectl config set-context --current --namespace=default
    - kubectl apply -f  kubernetes/frontend/configmap.yaml
    - kubectl apply -f kubernetes/frontend/secrets.yaml
    - envsubst < kubernetes/frontend/deployment.yaml | kubectl apply -f -
    - kubectl apply -f kubernetes/frontend/service.yaml
    - kubectl apply -f kubernetes/frontend/ingress.yaml
  after_script:
    - rm -f ~/.kube/config
  ```

  ---

  <br>

- Результат сборки:

![](/images/cicd.png) 

![](/images/pipeline.png) 

---  

<br>

![](/images/cicd-job.png) 

![](/images/cicd-job2.png) 

---

<br>

Полезные ссылки:  
> - [ Аутентификация от имени пользователя ](https://yandex.cloud/ru/docs/cli/operations/authentication/user)
> - [ OAuth-токен ](https://yandex.cloud/ru/docs/iam/concepts/authorization/oauth-token)
> - [ www.cloudns.net](https://www.cloudns.net/)
> - [ Начало работы с интерфейсом командной строки ](https://yandex.cloud/ru/docs/cli/quickstart)
> - [ cert-manager ](https://cert-manager.io/docs/installation/helm/#prerequisites)

<br>

---

- Основная сложность была с пониманием как Frontend должен обращаться к Backend, не сразу понял что надо создавать configmap,и пытался реализовать все в ingress, а еще запутали ссылки на Backend которые изначально были в Dockerfile для frontend.  
- Ну и с certmanager тоже не сразу все очевидно стало, хотя там все очень просто оказалось.

---
<br>





- В результате мне удалось выполнить все поставленные на третий этап задачи. 👌💪 😎  

<br>

>
> ✅ Написаны Kubernetes-манифесты для публикации приложения  

<br>

---

<br>

- Финальный результат: 



![](/images/final-3.png) 

