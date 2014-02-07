@echo off
cd "%~dp0\..\.."
vagrant reload & bin\utils\UpdateApacheVHosts.bat
