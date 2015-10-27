CREATE TABLE customers(
  id CHAR (32) NOT NULL,
  PRIMARY KEY(id),
  first_name VARCHAR(64),
  last_name VARCHAR(64),
  email VARCHAR(64)
);

INSERT INTO customers ( id, first_name, last_name, email ) VALUES ( uuid(), 'Jane', 'Smith', 'jane.smith@example.com' );
INSERT INTO customers ( id, first_name, last_name, email ) VALUES ( uuid(), 'Dave', 'Richards', 'dave.richards@example.com' );
