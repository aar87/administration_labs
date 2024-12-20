# Администрирование серверов

## 1. Провести настройку маршрутизации
Для создания воспользуемся Docker`ом и LTS версией Ubuntu.
```shell
docker container run -d -p 8080:8080 -it --name ubuntu --rm ubuntu:22.04
```
Проверим запущенный контейнер
```shell
docker ps
```
```commandline
CONTAINER ID   IMAGE          COMMAND       CREATED              STATUS              PORTS                                       NAMES
028d8cd1ee00   ubuntu:22.04   "/bin/bash"   About a minute ago   Up About a minute   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   ubuntu
```
Как видно мы направляем локальную сеть (0.0.0.0) для порта 8080 внутрь контейнера.
Проверим это. Установим nginx, более подробно можно увидеть процесс в лабораторной работе № 2.
Единственную манипуляцию дополнительно сделаю в default nginx конфиге - сменю порт с 80 по 8080.
Теперь можно сделать запрос и увидеть что nginx отвечает.
```shell
curl 0.0.0.0:8080
```
```commandline
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Зайдем в контейнер и правило для nginx
```shell
vim /etc/nginx/sites-available/default
```
Запишем ограничение доступа
```commandline
server {
        listen 8080 default_server;
        listen [::]:8080 default_server;

        deny all;
....
```
Перезагрузим nginx
```shell
nginx -s reload
```
Выйдем из контейнера и попробуем сделать запрос
```shell
curl 0.0.0.0:8080
```
```commandline
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
```
Ожидаемо получили отказ
## 2. Провести настройку средств удаленного доступа
Для настройки удаленных доступов довольно сложно настраивать контейнер. В это случае нужно установить все средства
доступа, администрирование и прочее. Будет проще арендовать VPS на сутки и получить готовый серер для манипуляций.
Для примера я выбрал провайдера Jino и купил сервер Ubuntu 22.04.
С помощью предоставленного root пользователя авторизуемся на сервер.
```shell
ssh -p 49384 root@545431d24bea.vps.myjino.ru
```
Использовать root пользователя в администрирование не рекомендуется, поэтому создадим пользователя.
```shell
adduser manager
```
```commandline
root@545431d24bea:~# adduser manager
Adding user `manager' ...
Adding new group `manager' (1000) ...
Adding new user `manager' (1000) with group `manager' ...
Creating home directory `/home/manager' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for manager
Enter the new value, or press ENTER for the default
        Full Name []: 
        Room Number []: 
        Work Phone []: 
        Home Phone []: 
        Other []: 
Is the information correct? [Y/n] y
```
В интерактивном режиме задали необходимые данные и самое главное - это пароль доступа.
Посмотреть пользователей можно в разделе home.
```shell
ls -la /home/
```
```commandline
drwxr-xr-x  3 root    root    4096 Dec 20 17:28 .
drwxr-xr-x 18 root    root    4096 Dec 20 17:23 ..
drwxr-x---  2 manager manager 4096 Dec 20 17:28 manager
```
Выйдем root пользователем и попробуем войти manager.
Порт и домен используем тот же, меняется только имя пользователя.
```shell
ssh -p 49384 manager@545431d24bea.vps.myjino.ru
```
```commandline
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.2.0 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

manager@545431d24bea:~$ 
```
Сначала запрошен был пароль, а далее приветствие. Также видно что в командной строке прописан manager.
## 3. Настроить параметры политики безопасности
Текущий способ настройки доступа является не безопасным.
Пароль такого типа как правило не очень большой и имеется шанс на его потерю или подбор.
Для более безопасного доступа будем использовать криптографию публичного/приватного ключей.
На локальном компльютере создадим ключи.
```shell
ssh-keygen
```
```commandline
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/antonraevsky.ssh/id_rsa): 
Created directory '/Users/antonraevsky.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /Users/antonraevsky.ssh/id_rsa
Your public key has been saved in /Users/antonraevsky.ssh/id_rsa.pub
The key fingerprint is:
SHA256:/rDythtOFyWR6cus9iXUbUjVcSFG8j0kmeRPGiE2tr0 antonraevsky@Mac-mini-Anton
The key's randomart image is:
+---[RSA 3072]----+
|          .OoB+=+|
|          =.X+* o|
|         ...o= + |
|          .= o* .|
|        Soo.oEo. |
|       . .+. .   |
|        =.o .    |
|      .o+* o     |
|       =*+o      |
+----[SHA256]-----+
```
Из примечательного выше мы получили RSA по умолчанию и я задал пустым пароль.
Далее скопируем приватный ключ и создадим связь с удаленным сервером.
```shell
ssh-copy-id -p 49384 manager@545431d24bea.vps.myjino.ru
```
```commandline
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/Users/antonraevsky/.ssh/id_dsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
manager@545431d24bea.vps.myjino.ru's password: 

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh -p 49384 'manager@545431d24bea.vps.myjino.ru'"
```
В процессе выполнения был запрошен пароль, а далее нам сообщили об успешном добавлении ключа.
Также сразу предложили нам проверить авторизаци, что и сделаем
```shell
ssh -p 49384 'manager@545431d24bea.vps.myjino.ru'
```
Пароль также был запрошен и мы смогли авторизоваться. Теперь имея доступ с помощью ключей, можно настроить правила.
Для этого войдем root пользователем и сделаем настройки
```shell

```
```commandline
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
#PermitEmptyPasswords no
```
Перезагрузим сервис sshd
```shell
service sshd reload
```
Выходим пользователем root и заходим manager
```shell
ssh -p 49384 'manager@545431d24bea.vps.myjino.ru'
```
```commandline
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.2.0 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

manager@545431d24bea:~$ 
```
Теперь мы можем входить без пароля, используя только приватный ключ.
## Заключение
Можно конечно сделать гораздо больше ограничений, в том числе запретить вход для root пользователя.
Также важно учесть что мы создали пользователя manager и не наделили его правами sudo.
С одной стороны это безопасно, с другой мы не сможем скачать что-либо пользователем manager.
