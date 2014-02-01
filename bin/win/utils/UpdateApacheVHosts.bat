@echo off
cd "%~dp0\..\..\.."
vagrant ssh -c "sudo /vagrant/bin/internal/update-apache-vhosts" -- -T -n
