@echo off
cd "%~dp0\..\.."
vagrant ssh -c "sudo cp /var/lib/redis/dump.rdb /vagrant/runtime/redis-dump.rdb" -- -T -n & pause
