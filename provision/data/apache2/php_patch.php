<?php
if (!empty($_SERVER['SCRIPT_NAME']) && !empty($_SERVER['SCRIPT_FILENAME']))
    $_SERVER['DOCUMENT_ROOT'] = str_replace($_SERVER['SCRIPT_NAME'], '', $_SERVER['SCRIPT_FILENAME']);
