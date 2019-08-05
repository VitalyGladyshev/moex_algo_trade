CREATE DATABASE IF NOT EXISTS moex_ex;

USE moex_ex;

DROP TABLE IF EXISTS current_trades;
CREATE TABLE IF NOT EXISTS current_trades(
	id_ct BIGINT,
    date_ct DATETIME,
    lass_code VARCHAR(12),
    time_ct TIME,
    price FLOAT,
    volume INT,
    operation VARCHAR(12)
);

DROP TABLE IF EXISTS securities;
CREATE TABLE IF NOT EXISTS securities(
	security_name VARCHAR(50),
    security_name_full VARCHAR(50),
    security_name_tiny VARCHAR(15),
    security_code VARCHAR(15)
    -- security_class VARCHAR(50),
    -- security_class_code VARCHAR(50),
    -- security_nominal INT
);

SELECT * FROM securities;
