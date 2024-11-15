
<div align="center"> 

![](/images/logo.png)  

##  *Momo Store aka Пельменная №2 &trade;* 



*Сделано пользователем std-030-35 он же **Алексей Дёмин***


Адрес Пельменной  - https://vm.momo-store.cloud-ip.biz/  
Адрес Prometheus  - http://prometheus.momo-store.cloud-ip.biz/  
Адрес Grafana - http://grafana.momo-store.cloud-ip.biz/

---

> Для удобства чтения инструкция будет поделена на несколько частей, согласно пройденным этап в дипломном проекте.  
Ну и потому что делалось все в разные дни и выходные 😆   
---  
<br>

</div>
<div align="center">

❶ Этап

*Работа, которую необходимо выполнить на первом этапе:*
<br>

</div>

> 🔎 Код хранится в GitLab с использованием любого git-flow  
> 🔎 В проекте присутствует .gitlab-ci.yml, в котором описаны шаги сборки  
> 🔎 Артефакты сборки (бинарные файлы, docker-образы или др.) публикуются в систему хранения (Nexus или аналоги)  
> 🔎 Артефакты сборки версионируются  
> 🔎 Написаны Dockerfile'ы для сборки Docker-образов бэкенда и фронтенда  
> 🔎 Бэкенд: бинарный файл Go в Docker-образе  
> 🔎 Фронтенд: HTML-страница раздаётся с Nginx  
> 🔎 В GitLab CI описан шаг сборки и публикации артефактов  
> 🔎 В GitLab CI описан шаг тестирования  
> 🔎 В GitLab CI описан шаг деплоя  

<br> 

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Первая часть 🚀🚀🚀 ](./Readme/README-Stage-1.md)*  
---
</div>  

<br> <br> 

<div align="center">

*Работа, которую 🙈 **необязательно** 🙈 было выполнять между первым и вторым этапом:*  

<br>

</div>

> 🔎 Создание своей собственной ВМ в Yandex Cloud используя Terraform   
> 🔎 Установка сервера Minio на ВМ в Yandex Cloud  

<br>

<div align="center">

*Основная цель данной работы была закрепить полученные знания, и воспользрваться халявой от Яндекса :) и потратить день, чтоб разобраться во многих(не во всех уж точно) деталях создания ВМ используя Terraform, и ознакомиться с провайдером Яндекса.*
<br>
<br>

</div>

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Необязательная часть 🌝](./Readme/README-Stage-1.5.md)*  
---
</div>  
<br><br>

<div align="center">

❷ Этап

*Работа, которую необходимо выполнить на втором этапе:*
<br>

</div>

> 🔎 Kubernetes-кластер описан в виде кода, и код хранится в репозитории GitLab   
> 🔎 Конфигурация всех необходимых ресурсов описана согласно IaC    
> 🔎 Состояние Terraform'а хранится в S3  
> 🔎 Картинки, которые использует сайт, или другие небинарные файлы, необходимые для работы, хранятся в S3   
> 🔎 Секреты не хранятся в открытом виде    

<br>

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Вторая часть 🚀🚀🚀 ](./Readme/README-Stage-2.md)*  
---
</div> 

<br>

<br>

<div align="center">  

❸ Этап

*Работа, которую необходимо выполнить на третьем этапе:*
<br>

</div>

> 🔎 Написаны Kubernetes-манифесты для публикации приложения  
  
<br>

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Третья часть 🔥🔥🔥 ](./Readme/README-Stage-3.md)*  
---
</div> 

<br>

<br>

<div align="center">  

❹ Этап

*Работа, которую необходимо выполнить на четвертом этапе:*
<br>

</div>

> 🔎 Написан Helm-чарт для публикации приложения  
> 🔎 Helm-чарты публикуются и версионируются в Nexus
  
<br>

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Четвертая часть 🔥🔥🔥 ](./Readme/README-Stage-4.md)*  
---
</div> 

<br>

<br>

<div align="center">  

❺ Этап - **Финальный** 

*Работа, которую необходимо выполнить в финальном этапе:*
<br>

</div>

> 🔎 Приложение подключено к системам логирования и мониторинга  
> 🔎 Есть дашборд, в котором можно посмотреть логи и состояние приложения  
  
<br>

<div align="center"> 

---  
> ✅ Ссылка на инструкцию -  *[Пятую часть 🚀🚀🚀 ](./Readme/README-Stage-5.md)*  
---

<br><br>

 <h3>🔥🔥🔥 Спасибо всей команде Яндекса за замечательный курс!!! 🔥🔥🔥</h3>  
 
 **Уверен что мы с вами еще встретимся 😉**
 
 <br><br><br>

![](/images/end.jpg)  


---

**Ну и кстати, я был довольно экономен с ресурсами.**  

![](/images/babosiki.png) 

</div> 