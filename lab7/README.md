# Администрирование серверов

## 1. Провести анализ имеющихся на рынке программного обеспечения промышленных СУБД.
#### MySQL
Считается одной из самых распространенных СУБД. MySQL — реляционная СУБД с открытым исходным кодом, главными плюсами которой являются ее скорость и гибкость, которая обеспечена поддержкой большого количества различных типов таблиц.

Кроме того, это надежная бесплатная система с простым интерфейсом и возможностью синхронизации с другими базами данных. В совокупности эти факторы позволяют использовать MySQL как крупным корпорациям, так и небольшим компаниям.
#### Microsoft SQL Server
Как следует из названия, фирменная СУБД, разработанная Microsoft. Оптимальная для использования в операционных системах семейства Windows, однако может работать и с Linux.

Система позволяет синхронизироваться с другими программными продуктами компании Microsoft, а также обеспечивает надежную защиту данных и простой интерфейс, однако отличается высокой стоимостью лицензии и повышенным потреблением ресурсов.
#### PostgreSQL
CУБД PostgreSQL — еще одна популярная и бесплатная система. Наибольшее применение нашла для управления БД веб-сайтов и различных сервисов. Она универсальна, то есть подойдет для работы с большинством популярных платформ.

При этом PostgreSQL — объектно-реляционная СУБД, что дает ей некоторые преимущества над другими бесплатными СУБД, в большинстве являющимися реляционными.
Зайдем на полученный id контейнера
#### Oracle
Первая версия этой объектно-реляционной СУБД появилась в конце 70-х, и с тех пор зарекомендовала себя как надежная, функциональная и практичная. СУБД Oracle постоянно развивается и дорабатывается, упрощая установку и первоначальную настройку и расширяя функционал.

Однако существенным минусом данной СУБД является высокая стоимость лицензии, поэтому она используется в основном крупными компаниями и корпорациями, работающими с огромными объемами данных.

Для примера работ буду использовать PostgreSQL как наиболее мне знакомую.

## 2. Настроить параметры PostgreSQL
Для настройки PostgreSQL будем использовать Docker.
Запустим образ postgres в режиме detach, а также сразу добавим пароль 'hidden' - это обязательный параметр для доступа
```shell
docker run --rm --name storage -e POSTGRES_PASSWORD=hidden -d postgres
docker ps
```
Увидем что база данных успешно запущена
```commandline
CONTAINER ID   IMAGE      COMMAND                  CREATED              STATUS              PORTS      NAMES
0c75708475ff   postgres   "docker-entrypoint.s…"   About a minute ago   Up About a minute   5432/tcp   storage
```
Проверим логи созданного контейнера с базой данных
```shell
docker logs storage
```
Увидем логи примерно следующего вида
```commandline
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok


Success. You can now start the database server using:
initdb: warning: enabling "trust" authentication for local connections

You can change this by editing pg_hba.conf or using the option -A, or
    pg_ctl -D /var/lib/postgresql/data -l logfile start
--auth-local and --auth-host, the next time you run initdb.

waiting for server to start....2025-01-15 13:46:47.226 UTC [47] LOG:  starting PostgreSQL 13.3 (Debian 13.3-1.pgdg100+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 8.3.0-6) 8.3.0, 64-bit
2025-01-15 13:46:47.228 UTC [47] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2025-01-15 13:46:47.236 UTC [48] LOG:  database system was shut down at 2025-01-15 13:46:46 UTC
2025-01-15 13:46:47.243 UTC [47] LOG:  database system is ready to accept connections
 done
server started

/usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*

2025-01-15 13:46:47.455 UTC [47] LOG:  received fast shutdown request
waiting for server to shut down....2025-01-15 13:46:47.456 UTC [47] LOG:  aborting any active transactions
2025-01-15 13:46:47.460 UTC [47] LOG:  background worker "logical replication launcher" (PID 54) exited with exit code 1
2025-01-15 13:46:47.460 UTC [49] LOG:  shutting down
2025-01-15 13:46:47.472 UTC [47] LOG:  database system is shut down
 done
server stopped

PostgreSQL init process complete; ready for start up.

2025-01-15 13:46:47.578 UTC [1] LOG:  starting PostgreSQL 13.3 (Debian 13.3-1.pgdg100+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 8.3.0-6) 8.3.0, 64-bit
2025-01-15 13:46:47.578 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2025-01-15 13:46:47.582 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2025-01-15 13:46:47.586 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2025-01-15 13:46:47.590 UTC [66] LOG:  database system was shut down at 2025-01-15 13:46:47 UTC
2025-01-15 13:46:47.594 UTC [1] LOG:  database system is ready to accept connections
```
Из интересного выше, видно что были следующие установки:
- UTF8
- English как основной язык
- Max connections 100
- listening on IPv4 address "0.0.0.0", port 5432
База запущена и доступна по локальному 5432
Подключимся к контейнеру
```shell
docker exec -it storage bash
```
Войдем в базу данных
```shell
psql --username=postgres --dbname=postgres
```
```commandline
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

postgres=# 
```
Мы успешно авторизовались в базу данных.
Для примера конфигурации, переделаем несколько настроек.
Добавим возможность подключения сразу к базе данных, без отдельного входа в контейнер.
Это будет реализовано с помощью выдачи наружу порта 5000 (для примера).
Также сменим стандартного пользователя postgres на admin.
Выходим из контейнера и останавливаем его
```shell
exit
docker stop storage
```
Запускаем storage с новыми параметрами:
- -p 5000:5432 будет открывать порт контейнера 5000 в БД внутри контейнера на порт 5432
- -e отвечает за параметры environment настроек пользователя и пароля
```shell
docker run --rm --name storage -p 5000:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=hidden -d postgres
```
Теперь можно войти в БД сразу из локальной машины
Важное примечение, это будет доступно только, если на локлаьной машине установлена СУБД PostgreSQL.
Если не установлено, то можно выполнить вход как указано выше - через контейнер.
```shell
psql -h localhost -p 5000 -U admin
```
Успешно авторизовались на -h (хост) -p (порт) используя пользователя -U.
```commandline
Password for user admin: 
psql (14.8 (Homebrew), server 13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

admin=# 
```
Из интересного видно что СУБД версии 14.8 (на локальной машине), а на сервере 13.3.
Как правило поддерживается совместимость "вверх" и новая версия СУБД дает в основном преимущества быстродействия или поддержку новых типов данных.
Использование наоборот, т.е. СУБД более станой версии для сервера более новой, не рекомендуется, т.к. может не поддерживать новый функционал.

## 3. Настроить группы связанных серверов по заданию преподавателя.
Используя Docker, довольно легко добавить дополнительные сервера БД.
Создадим 3 контейнера с запущенными СУБД.
```shell
docker run --rm --name storage0 -p 5000:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=hidden -d postgres
docker run --rm --name storage1 -p 5001:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=hidden -d postgres
docker run --rm --name storage2 -p 5002:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=hidden -d postgres
```
Проверим
```shell
docker ps
```
```commandline
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS         PORTS                                       NAMES
276efbf9265d   postgres   "docker-entrypoint.s…"   3 seconds ago    Up 1 second    0.0.0.0:5002->5432/tcp, :::5002->5432/tcp   storage2
473cf77f217f   postgres   "docker-entrypoint.s…"   7 seconds ago    Up 5 seconds   0.0.0.0:5001->5432/tcp, :::5001->5432/tcp   storage1
e1979a438cf6   postgres   "docker-entrypoint.s…"   10 seconds ago   Up 9 seconds   0.0.0.0:5000->5432/tcp, :::5000->5432/tcp   storage0
```
В результате мы имеем 3 работающие базы данных PostgreSQL.
Различаются только портами, а также именами контейнера.
Для примера войдем storage1
```shell
psql -h localhost -p 5001 -U admin
```
```commandline
Password for user admin: 
psql (14.8 (Homebrew), server 13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

admin=# 
```

## Заключение
В примерах выше было показано как создать базу данных PostgreSQL.
Также рассмотрены примеры организации доступа с помощью пароля и логина специфичного пользователя.
PostgreSQL очень удобна для быстрого старта, а также показывает хорошую продуктивность в работе с большими данными.