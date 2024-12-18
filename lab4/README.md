# Администрирование серверов

## 1. Провести администрирование дисковых ресурсов
Для создания воспользуемся Docker`ом и LTS версией Ubuntu.
```shell
docker container run -d -it --name ubuntu --rm ubuntu:24.04
```
```commandline
4b4a6b398e9dd34f22c6bad143b153f45e92d13b11713d07cc88f5658e1a492c
```
Зайдем на полученный id контейнера
```shell
docker exec -it 4b4a6b398e9dd34f22c6bad143b153f45e92d13b11713d07cc88f5658e1a492c bash
```
Проверим доступные дисковые ресурсы
```shell
df -h
```
```commandline
Filesystem      Size  Used Avail Use% Mounted on
overlay          59G   34G   22G  61% /
tmpfs            64M     0   64M   0% /dev
tmpfs           994M     0  994M   0% /sys/fs/cgroup
shm              64M     0   64M   0% /dev/shm
/dev/vda1        59G   34G   22G  61% /etc/hosts
tmpfs           994M     0  994M   0% /proc/acpi
tmpfs           994M     0  994M   0% /sys/firmware
```
## 2. Задать параметры доступа
В ubuntu, как и в других unix подобных системах доступ осуществляется на уровне пользователя или группы.
Команды для выдачи доступов могут использоваться:
1) chown -> право владения и использования
2) chmod -> органичения на различные типы операций (read,write,delete)
Для примера доступов создадим двух пользователей
```shell
useradd admin1
useradd admin2
```
Создадим папки, для ограничения доступов
```shell
mkdir /secret_for_admin_1
mkdir /secret_for_admin_2
```
Проверим доступ
```shell
ls -la | grep secret_for
```
```commandline
drwxr-xr-x   2 root root 4096 Dec 18 15:24 secret_for_admin_1
drwxr-xr-x   2 root root 4096 Dec 18 15:24 secret_for_admin_2
```
Видны уровни доступа, а таже записи root root означают владельцев данных папок. Изменим владельцев
```shell
chown -R admin1 secret_for_admin_1
chown -R admin2 secret_for_admin_2
```
Проверим как это выглядит теперь
```shell
ls -la | grep secret_for
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
Попробуем зайти в папку, владельцем которой является admin1 и попробуем создать файл
```shell
cd secret_for_admin_1 && touch some.txt
```
```commandline
-rw-rw-r-- 1 admin1 admin1    0 Dec 18 15:30 some.txt
```
Успешно создали файл. Теперь попробуем сделать тоже самое для папки пользователя admin2
```shell
cd secret_for_admin_2 && touch some.txt
```
```commandline
touch: cannot touch 'some.txt': Permission denied
```
Согласно правил доступа, мы не смогли создать файл в чужой папке.
Изменим уровень доступа для любого действия в папке secret_for_user_2
```shell
exit
chmod 777 -R secret_for_admin_2
ls -la | grep secret_for
```
```commandline
drwxr-xr-x   2 admin1 root 4096 Dec 18 15:30 secret_for_admin_1
drwxrwxrwx   2 admin2 root 4096 Dec 18 15:24 secret_for_admin_2
```
И тут сразу видно что w , тоесть write стало доступно для этой папки.
Войдем пользователем admin1 снова и создадим файл в папке secret_for_admin_2
```shell
su admin1
cd secret_for_admin_2
touch some.txt
ls -la
```
```commandline
-rw-rw-r-- 1 admin1 admin1    0 Dec 18 15:36 some.txt
```
## Заключение
В примерах выше было показано как создать пользователя, переключится на него и настроить уровни доступа.
Как правило начальный пользователь root существует для делегирования прав и доступов для других пользователей.
Например admin это как правило root на "минималках". Администратор настраивает других пользователей и раздает доступы.
Причем пользователю admin выдаются права на sudo, что означает выполнить что-то как суперпользователь (root).