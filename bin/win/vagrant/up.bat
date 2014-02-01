@echo off
cd "%~dp0\..\..\.."
vagrant up  & bin\win\utils\UpdateApacheVHosts.bat
