CREATE DATABASE IF NOT EXISTS moex;

USE moex;

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

SELECT * FROM current_trades;
