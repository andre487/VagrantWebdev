@echo off
cd "%~dp0\..\.."
vagrant resume  & bin\utils\UpdateApacheVHosts.bat
