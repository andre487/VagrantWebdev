@echo off
cd "%~dp0\..\.."
vagrant ssh -c "pg_dumpall -hlocalhost -Upostgres > /vagrant/runtime/postgresql-dump.sql" -- -T -n & pause
