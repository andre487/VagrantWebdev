# -*- coding: UTF-8 -*-
import os
import re

APACHE_HOST = "/etc/apache2/sites-available/default"

with open(APACHE_HOST) as conf_file:
	apacheConfig = conf_file.read()
