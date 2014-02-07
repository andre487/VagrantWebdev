@echo off
cd "%~dp0\..\.."
vagrant ssh -c "/vagrant/bin/internal/flush-memcache" -- -T -n & pause
