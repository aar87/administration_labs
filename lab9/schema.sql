CREATE TABLE secrets (
    key varchar(256),
    value varchar(1024)
);

INSERT INTO secrets (key, value) VALUES
('email', 'info@mail.ru'),
('password', 'somesecrethashedpassword'),
('code', '111222333');

CREATE TABLE products (
    name varchar(256),
    count smallint
);

INSERT INTO products (name, count) VALUES
('iphone', 20),
('macbook', 10);