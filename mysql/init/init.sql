CREATE DATABASE IF NOT EXISTS expense_app_db;
CREATE DATABASE IF NOT EXISTS keycloak_db;

CREATE USER IF NOT EXISTS 'expenseuser'@'%' IDENTIFIED BY 'expensepass';

GRANT ALL PRIVILEGES ON expense_app_db.* TO 'expenseuser'@'%';
GRANT ALL PRIVILEGES ON keycloak_db.* TO 'expenseuser'@'%';

FLUSH PRIVILEGES;