@echo off
cd "%~dp0\..\.."
vagrant ssh -c "sudo /usr/bin/indexer --rotate --all --config /etc/sphinxsearch/sphinx.conf" -- -T -n & pause
