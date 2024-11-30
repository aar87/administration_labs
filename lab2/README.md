# Администрирование серверов

## 1. Настроить консоль управления для удаленного администрирования
Для создания воспользуемся Docker`ом. Для разнообразия возьмем последнюю LTS версию Ubuntu.
```shell
docker container run -d -it --name ubuntu --rm ubuntu:24.04
```
В процессе подключения будет скачивание образа ubuntu:24.04.
Размен образа совсем увеличен всего на 2 мегабайта.
```shell
docker images
```
```commandline
REPOSITORY     TAG                            IMAGE ID       CREATED         SIZE
ubuntu         24.04                          fec8bfd95b54   6 weeks ago     78.1MB
ubuntu         22.04                          97271d29cb79   2 months ago    77.9MB
```
Запустим контейнер
```shell
docker container run -d -p 8080:8080 -it --name ubuntu --rm ubuntu:22.04
```
Далее можно получить доступ к консле управления ID или Name можно войти в запущенный контейнер.
```shell
docker exec -it ubuntu bash
```
```commandline
root@5f6ba7f75739:/#  
```
## 2. Настроить терминальные службы для удаленного администрирования
В первом пункте мы произвели вход в терминал.
Для примера можем вывести важнейшую службу systemctl (service более легковесная замена для образа докер).
Чтобы было что-то запущено для включения и выключения установим сервис nginx.
```shell
apt install nginx
```
Проверка
```shell
nginx -t
```
```commandline
root@5f6ba7f75739:/# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
Проверим с помолью утилиты service статус nginx
```shell
service nginx status
```
```commandline
root@5f6ba7f75739:/# service nginx status
 * nginx is not running
```
Сервис не запущен, сделаем это
```shell
service nginx start
```
```commandline
root@5f6ba7f75739:/# service nginx start 
 * Starting nginx nginx 
```
Сервис запущен и для проверки можно использовать знакомый из первой лабораторной инструмент CURL.
```shell
curl http://localhost
```
```commandline
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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
Ожидаемо получили стандартный ответ nginx. По умолчанию используется порт 80.
Для проверки сервисной службы отключем nginx
```shell
service nginx stop
```
```commandline
 * Stopping nginx nginx                                                                                                                                                                                                    [ OK ] 
root@5f6ba7f75739:/# 
```
Выполним запрос CURL к локальному хосту
```shell
curl http://localhost
```
```commandline
curl: (7) Failed to connect to localhost port 80 after 0 ms: Couldn't connect to server
```
## 3. Настроить средства администрирования службы каталога домена
Проприетарная реализация от компании Microsoft службы каталогов – совокупности программных сервисов и баз данных для иерархического представления информационных ресурсов в сети (компьютеров, принтеров, сетевых дисков и пр.) и настройки доступа к ним.
В Unix системах все настраивается для пользователя. Личный каталог и доступ к нему. С помощью групп можно делить права доступа. \
Добавим нового пользователя в запущенный контейнер.
```shell
useradd admin
```
Просмотрим доступные папки, с учетом прав доступа
```shell
ls -la
```
```commandline
drwxr-xr-x   1 root root 4096 Nov 30 19:11 .
drwxr-xr-x   1 root root 4096 Nov 30 19:11 ..
-rwxr-xr-x   1 root root    0 Nov 30 18:51 .dockerenv
lrwxrwxrwx   1 root root    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Mar 31  2024 bin.usr-is-merged
drwxr-xr-x   2 root root 4096 Apr 22  2024 boot
drwxr-xr-x   5 root root  360 Nov 30 18:51 dev
drwxr-xr-x   1 root root 4096 Nov 30 19:28 etc
drwxr-xr-x   3 root root 4096 Oct 16 10:00 home
lrwxrwxrwx   1 root root    7 Apr 22  2024 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Apr 22  2024 lib64 -> usr/lib64
drwxr-xr-x   2 root root 4096 Oct 16 09:53 media
drwxr-xr-x   2 root root 4096 Oct 16 09:53 mnt
drwxr-xr-x   2 root root 4096 Oct 16 09:53 opt
dr-xr-xr-x 177 root root    0 Nov 30 18:51 proc
drwx------   1 root root 4096 Nov 30 19:29 root
drwxr-xr-x   1 root root 4096 Nov 30 19:17 run
lrwxrwxrwx   1 root root    8 Apr 22  2024 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Mar 31  2024 sbin.usr-is-merged
drwxr-xr-x   2 root root 4096 Oct 16 09:53 srv
dr-xr-xr-x  13 root root    0 Nov 30 19:02 sys
drwxrwxrwt   1 root root 4096 Nov 30 19:15 tmp
drwxr-xr-x   1 root root 4096 Oct 16 09:53 usr
drwxr-xr-x   1 root root 4096 Nov 30 19:11 var
```
По выводу видно что все принадлежит суперпользователю root.
Добавим прав для пользователя admin папки media
```shell
chown -R admin media
```
```commandline
root@5f6ba7f75739:/# ls -la
total 76
drwxr-xr-x   1 root  root 4096 Nov 30 19:11 .
drwxr-xr-x   1 root  root 4096 Nov 30 19:11 ..
-rwxr-xr-x   1 root  root    0 Nov 30 18:51 .dockerenv
lrwxrwxrwx   1 root  root    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x   2 root  root 4096 Mar 31  2024 bin.usr-is-merged
drwxr-xr-x   2 root  root 4096 Apr 22  2024 boot
drwxr-xr-x   5 root  root  360 Nov 30 18:51 dev
drwxr-xr-x   1 root  root 4096 Nov 30 19:28 etc
drwxr-xr-x   3 root  root 4096 Oct 16 10:00 home
lrwxrwxrwx   1 root  root    7 Apr 22  2024 lib -> usr/lib
lrwxrwxrwx   1 root  root    9 Apr 22  2024 lib64 -> usr/lib64
drwxr-xr-x   1 admin root 4096 Oct 16 09:53 media
drwxr-xr-x   2 root  root 4096 Oct 16 09:53 mnt
drwxr-xr-x   2 root  root 4096 Oct 16 09:53 opt
dr-xr-xr-x 178 root  root    0 Nov 30 18:51 proc
drwx------   1 root  root 4096 Nov 30 19:29 root
drwxr-xr-x   1 root  root 4096 Nov 30 19:17 run
lrwxrwxrwx   1 root  root    8 Apr 22  2024 sbin -> usr/sbin
drwxr-xr-x   2 root  root 4096 Mar 31  2024 sbin.usr-is-merged
drwxr-xr-x   2 root  root 4096 Oct 16 09:53 srv
dr-xr-xr-x  13 root  root    0 Nov 30 19:02 sys
drwxrwxrwt   1 root  root 4096 Nov 30 19:15 tmp
drwxr-xr-x   1 root  root 4096 Oct 16 09:53 usr
drwxr-xr-x   1 root  root 4096 Nov 30 19:11 var
```
## Заключение
Версия 24.04 образа ubuntu занимает не на много больше, но наверняка привнесло важные правки, особенно в части безопасности.
Во время упражнения также хотел создать пользователя admin и продемонстрировать доступ и ограничение к ресурсам, но в докер есть сложности.
Управление доступами в unix довольно удобны и легко просматриваются из терминала.
