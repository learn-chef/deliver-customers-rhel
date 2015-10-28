CREATE TABLE customers(
  id CHAR (32) NOT NULL,
  PRIMARY KEY(id),
  first_name VARCHAR(64),
  last_name VARCHAR(64),
  email VARCHAR(64),
  latitude DECIMAL(8,6),
  longitude DECIMAL(9,6)
);
