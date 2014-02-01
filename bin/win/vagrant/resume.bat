@echo off
cd "%~dp0\..\..\.."
vagrant resume  & bin\win\utils\UpdateApacheVHosts.bat
