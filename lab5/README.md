# Администрирование серверов

## 1. Настроить службу каталогов Active Directory по параметрам.
Для создания воспользуемся Docker`ом и LTS версией Ubuntu.
```shell
docker container run -d -it --name ubuntu --rm ubuntu:24.04
```
```commandline
e7c114028326d228777e664ab95a680100e99709ba1047243053a42f9040985b
```
Зайдем на полученный id контейнера
```shell
docker exec -it e7c114028326d228777e664ab95a680100e99709ba1047243053a42f9040985b bash
```
Добавим директорию для документов и сразу перейдем в нее
```shell
mkdir group_documents
cd group_documents
```
Создадим директорию для секретных ключей
```shell
mkdir secret_keys
```
А также создадим директорию для товаров
```shell
mkdir products
```
Просмотрим полученные директории
```commandline
drwxr-xr-x 4 root root 4096 Jan 14 05:09 .
drwxr-xr-x 1 root root 4096 Jan 14 05:08 ..
drwxr-xr-x 2 root root 4096 Jan 14 05:09 products
drwxr-xr-x 2 root root 4096 Jan 14 05:08 secret_keys
```
Теперь максимально ограничим доступы для пользователей и групп
```shell
chmod -R 700 secret_keys/
chmod -R 700 products/
```
Проверим доступы
```shell
ls -la
```
```commandline
drwxr-xr-x 4 root root   4096 Jan 14 05:09 .
drwxr-xr-x 1 root root   4096 Jan 14 05:08 ..
drwx------ 2 root root   4096 Jan 14 05:09 products
drwx------ 2 root root   4096 Jan 14 06:01 secret_keys
```
Теперь доступ к директория может осуществить только root пользователь и sudoers

## 2. Настроить механизмы групповой политики по параметрам
Добавим пользователей.

Сначала группу для менеджерского состава:
```shell
groupadd managers
```
Далее группу для администраторов
```shell
useradd admin1
useradd manager1
```
Переключимся на пользователя и попробуем перейти в одну из директорий
```shell
su admin1
cd /group_documents/products
```
И ожидаемо получаем отказ доступа
```commandline
sh: 2: cd: can't cd to /group_documents/products
```
Выходим из пользователя admin1
```shell
exit
```
Создаем две группы
```shell
groupadd managers
groupadd admins
```
Добавляем пользователей в группы
```shell
usermod -a -G admins admin1
usermod -a -G managers manager1
```
Пользователи в группах, остается добавить групповые права к директориям.
Но сначала нужно назначить группы к директориям с помощью chown
```shell
cd /group_documents
chown root:admins secret_keys
chown root:managers products
ls -la
```
```commandline
drwxr-xr-x 4 root root     4096 Jan 14 05:09 .
drwxr-xr-x 1 root root     4096 Jan 14 05:08 ..
drwx------ 2 root managers 4096 Jan 14 05:09 products
drwx------ 2 root admins   4096 Jan 14 06:01 secret_keys
```
Видно что групповые права для products назначены группе managers, а для secret_keys для admins.
Теперь разрешим группам чтение, запись и выполнение (без выполнения нельзя войти в директорию)
```shell
chmod g+rwx products
chmod g+rwx secret_keys
ls -la
```
```commandline
drwxr-xr-x 4 root root     4096 Jan 14 05:09 .
drwxr-xr-x 1 root root     4096 Jan 14 05:08 ..
drwxrw---- 2 root managers 4096 Jan 14 05:09 products
drwxrw---- 2 root admins   4096 Jan 14 06:01 secret_keys
```
```commandline
drwxr-xr-x   2 admin1 root 4096 Dec 18 15:24 secret_for_admin_1
drwxr-xr-x   2 admin2 root 4096 Dec 18 15:24 secret_for_admin_2
```
Переключимся на пользователя admin1 и проверим доступ
```shell
su admin1
whoami
```
```commandline
admin1
```
Попробуем зайти в папку, владельцем которой является группа admins и попробуем создать файл
```shell
cd secret_keys && touch key.txt
```
```commandline
drwxrwx--- 2 root   admins 4096 Jan 14 06:27 .
drwxr-xr-x 4 root   root   4096 Jan 14 05:09 ..
-rw-rw-r-- 1 admin1 admin1    0 Jan 14 06:27 key.txt
```
Успешно создали файл. Теперь попробуем сделать тоже самое для папки другой группы
```shell
cd ../products && touch product.txt
```
Ожидаемо получили отказ
```commandline
sh: 5: cd: can't cd to ../products
```
Согласно правил доступа, мы не смогли перейти в директорию другой группы и создать там файл.
Для примера переключимся на manager1 и проделаем похожее
```shell
exit
su manager1
cd /group_documents/products && touch product.txt
ls -la
```
Ожидаемо успешно создали файл
```commandline
drwxrwx--- 2 root     managers 4096 Jan 14 06:33 .
drwxr-xr-x 4 root     root     4096 Jan 14 05:09 ..
-rw-rw-r-- 1 manager1 manager1    0 Jan 14 06:33 product.txt
```
Но если попробуем прочитать key.txt из группы admins, то ничего не получится
```shell
cat /group_documents/secret_keys/key.txt
```
```commandline
cat: /group_documents/secret_keys/key.txt: Permission denied
```
Данный способ позволяет настроить политики группового доступа и при добавлении нового пользователя добавить его в необходимые группы.
Например создадим пользователя, которые имеет группы admins и products одновременно
```shell
exit
useradd god
usermod -a -G admins god
usermod -a -G managers god
su god
```
Теперь можем данным пользователем получить доступ к secret_keys
```shell
ls -la /group_documents/secret_keys
```
```commandline
drwxrwx--- 2 root   admins 4096 Jan 14 06:27 .
drwxr-xr-x 4 root   root   4096 Jan 14 05:09 ..
-rw-rw-r-- 1 admin1 admin1    0 Jan 14 06:27 key.txt
```
А также можем получить доступ к products
```shell
ls -la /group_documents/products
```
```commandline
drwxrwx--- 2 root     managers 4096 Jan 14 06:33 .
drwxr-xr-x 4 root     root     4096 Jan 14 05:09 ..
-rw-rw-r-- 1 manager1 manager1    0 Jan 14 06:33 product.txt
```
## Заключение
В примерах выше было показано как создать группы. Группы отличное решения для органичения доступа для частого использования.
Настройки могут быть достаточно сложны и гибки, но при правильной настройке позволит очень быстро выдать необходимые доступы новому пользователю.
В ОС Ubuntu все сущности это файлы, а значит можно настравить любые правила именно по файлам.