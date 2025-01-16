# Администрирование серверов

## 1. Создать пользовательские роли и прописать их доступ к объектам баз данных.
Для работы будем использовать PostgreSQL. Подробности работы с данной СУБД можно найти в лабораторной работе №7.
Запускаем базу данных
```shell
docker run --rm --name storage -e POSTGRES_PASSWORD=hidden -d postgres
```
Далее заходим в контейнер
```shell
docker exec -it storage bash
```
Входим в СУБД
```shell
psql --username=postgres --dbname=postgres
```
Создадим базу данных
```shell
CREATE DATABASE app;
```
Проверим что успешно создана база данных
```shell
\l
```
Видно что появилась база данных app в списке баз данных по умолчанию
```commandline
                                                    List of databases
   Name    |  Owner   | Encoding | Locale Provider |  Collate   |   Ctype    | Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+------------+------------+--------+-----------+-----------------------
 app       | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | 
 postgres  | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | 
 template0 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/postgres          +
           |          |          |                 |            |            |        |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/postgres          +
           |       
```
По умолчанию база данных принадлежит создателю. Кроме пользователя postgres в данный момент никто не иммет права доступа.
Создадим таблицу каких-то вымышленных секретных ключей.
Для разграничения доступа будем использовать следующие роли:
- admin для администрирования баз
- manager для возможности работы с целевыми полями
```shell
CREATE ROLE admin_role;
CREATE ROLE manager_role;
```
Также для ролей нужно выдать право на вход
```shell
GRANT CONNECT ON DATABASE app TO admin_role;
GRANT CONNECT ON DATABASE app TO manager_role;
```
## 2. Определить объекты базы данных только для чтения (SELECT).
Подключимся к БД
```shell
\c app;
```
```commandline
You are now connected to database "app" as user "postgres".
app=# 
```
Создаем таблицу для секретов
```shell
CREATE TABLE secrets (
    key varchar(256),
    value varchar(1024)
);
```
Добавляем 3 записи
```shell
INSERT INTO secrets (key, value) VALUES
('email', 'info@mail.ru'),
('password', 'somesecrethashedpassword'),
('code', '111222333');
```
Проверим данные
```shell
SELECT * FROM secrets;
```
```commandline
   key    |          value           
----------+--------------------------
 email    | info@mail.ru
 password | somesecrethashedpassword
 code     | 111222333
(3 rows)
```
Разрешим роле admin_role читать данные из таблицы secrets.
```shell
GRANT SELECT ON TABLE secrets TO admin_role;
```
## 3. Определить изменяемые объекты базы данных (INSERT, UPDATE, DELETE) и частоту их корректировки.
Для примера изменяемого объекта создадим таблицу продукция
```shell
CREATE TABLE products (
    name varchar(256),
    count smallint
);
```
И разрешим роли manager иметь право добавлять и удалять позиции в этой таблице
```shell
GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE products TO manager_role;
```
## 3. Создать пользователей и сделать их членами указанных ролей.
Создадим админа
```shell
CREATE USER admin WITH PASSWORD 'hidden';
GRANT admin_role TO admin;
```
Выходим пользователем postgres и заходим пользователем admin
```shell
exit 
psql --username=admin --dbname=app
```
```commandline
psql (17.2 (Debian 17.2-1.pgdg120+1))
Type "help" for help.

app=> 
```
Попробуем прочитать целевую таблицу secrets
```shell
SELECT * FROM secrets;
```
```commandline
app=> SELECT * FROM secrets;
   key    |          value           
----------+--------------------------
 email    | info@mail.ru
 password | somesecrethashedpassword
 code     | 111222333
(3 rows)
```
Успешно получили данные, теперь попробуем проникнуть в таблицу продукции
```shell
SELECT * FROM products;
```
И получаем ожидаемый отказ доступа
```commandline
ERROR:  permission denied for table products
```
Проделаем похожее для пользователя manager
Создадим пользователя manager и наделим его правами менеджерского состава
```shell
CREATE USER manager WITH PASSWORD 'hidden';
GRANT manager_role TO manager;
```
Выходим пользователем postgres и заходим пользователем manager
```shell
exit 
psql --username=manager --dbname=app
```
```commandline
psql (17.2 (Debian 17.2-1.pgdg120+1))
Type "help" for help.

app=> 
```
Попробуем прочитать секретные данные
```shell
SELECT * FROM secrets;
```
И получаем ожидаемый отказ доступа
```commandline
ERROR:  permission denied for table secrets
```
Теперь обратимся к таблице продукции
```shell
SELECT * FROM products;
```
Обращаемся успешно, но данных там ожидаемо нет
```commandline
 name | count 
------+-------
(0 rows)
```
Добавим новые записи в таблицу продукции
```shell
INSERT INTO products (name, count) VALUES
('iphone', 20),
('macbook', 10);
```
Выполним запрос выборки заново
```shell
SELECT * FROM products;
```
Получаем созданные ранее позиции
```commandline
  name   | count 
---------+-------
 iphone  |    20
 macbook |    10
(2 rows)
```
## Заключение
В примерах выше было показано как разграничить уровни доступа с помощью ролей.
Задав роль, можно эти права расширять на новых пользователей. Также при изменении политики роли будет достаточно сделать правку в роле и все участники этой роли изменят свои полномочия.
Также приложил файлик shema.sql для наглядности sql запросов.