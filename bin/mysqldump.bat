@echo off
cd "%~dp0\.."
vagrant ssh -c "mysqldump -uroot -ppassword --all-databases --set-charset --complete-insert > /vagrant/runtime/mysql-dump.sql" -- -T -n & pause
