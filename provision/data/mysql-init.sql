UPDATE mysql.user SET Password=PASSWORD('password') WHERE User='root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
