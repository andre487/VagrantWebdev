@echo off
cd "%~dp0\..\..\.."
vagrant reload & bin\win\utils\UpdateApacheVHosts.bat
