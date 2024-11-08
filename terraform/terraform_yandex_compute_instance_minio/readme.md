
<div align="center"> 

![](/images/logo.png)  

##  *Momo Store aka Пельменная №2 &trade;* 



*Сделано пользователем *std-030-35@praktikum-services.ru* он же **Алексей Дёмин***










тобы быстро установить Ansible на Ubuntu, выполните следующие шаги:

Обновите список пакетов:

bash
Копировать код
sudo apt update
Установите необходимые пакеты для добавления репозиториев:

bash
Копировать код
sudo apt install software-properties-common
Добавьте репозиторий Ansible:

bash
Копировать код
sudo add-apt-repository ppa:ansible/ansible
Обновите список пакетов:

bash
Копировать код
sudo apt update
Установите Ansible:

bash
Копировать код
sudo apt install ansible
Проверьте установку:

bash
Копировать код
ansible --version
Эти шаги установят последнюю стабильную версию Ansible из официального репозитория PPA.