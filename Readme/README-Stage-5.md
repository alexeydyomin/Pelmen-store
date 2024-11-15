<div align="center"> 

![](/images/logo.png) 

##  *Momo Store aka Пельменная №2 &trade;*
*Сделано пользователем *std-030-35* он же **Алексей Дёмин***

Адрес Пельменной  - https://vm.momo-store.cloud-ip.biz/  
Адрес Prometheus  - http://prometheus.momo-store.cloud-ip.biz/  
Адрес Grafana - http://grafana.momo-store.cloud-ip.biz/

---
![My Momo Store](/images/storemomo.png "My Momo Store")  

---


## *Пятый - Финальный этап*
</div>

**Требования**:
> 🔎 Приложение подключено к системам логирования и мониторинга  
> 🔎 Есть дашборд, в котором можно посмотреть логи и состояние приложения  

---
  
<br>

**Выполненная работа:**

- Был создан новый каталог prometheus в репозитории - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/tree/main/kubernetes/Helm/prometheus  
- И Grafana -  https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/tree/main/kubernetes/Helm/grafana  



![](/images/prometheus.png) 


---

<br>

- Добавлены все необходимые yaml файлы.  

<br>

```yaml
### clusterrolebinding.yaml

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: default-view
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
  - kind: ServiceAccount
    name: default
    namespace: {{ .Release.Namespace }}

``` 
  
  ```yaml
### ingress.yaml

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus
  namespace: {{ .Release.Namespace }}
  labels:
    app: prometheus
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: "prometheus.momo-store.cloud-ip.biz"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus
                port:
                  number: 9090

``` 
---  
<br>  

- Результат деплоя **Prometheus**

![](/images/target.png) 

---  

<br>  

- В **ClouDNS** были созданы дополнительные адреса:

![](/images/dns-1.png) 



---  
<br>  

- Результат деплоя **Grafana**, Prometheus Добавлен в Datasource

![](/images/grafana.png) 


---  
<br>  

- Создан простой (уж извините) dashboard для мониторинга Пельменной:

![](/images/grafana-1.png) 

---  
<br>  

- В результате мне удалось выполнить все поставленные на четвертый этап задачи. 👌💪 😎  

<br>

>
> ✅ Приложение подключено к системам логирования и мониторинга  
> ✅ Есть дашборд, в котором можно посмотреть логи и состояние приложения 

<br>

---
