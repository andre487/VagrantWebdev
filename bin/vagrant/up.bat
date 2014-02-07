@echo off
cd "%~dp0\..\.."
vagrant up  & bin\utils\UpdateApacheVHosts.bat
