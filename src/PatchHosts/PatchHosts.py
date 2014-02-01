#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import re
import webbrowser
import sys
import shutil
import tempfile
import ConfigParser


eol = os.linesep
if hasattr(sys, "frozen") and sys.frozen in ("windows_exe", "console_exe"):
    current_dir = os.path.dirname(sys.executable)
else:
    current_dir = os.path.dirname(os.path.realpath(__file__))
params_paths = (
    os.path.abspath(current_dir + "/../params.ini"),
    os.path.abspath(current_dir + "/../../../params.ini"),
)


def main():
    hosts_path = check_files()
    params = get_params()
    hosts = get_virtual_hosts_names(params)
    hosts_content = get_hosts_file_content(hosts_path, hosts, params)

    fd, tmp_file_path = tempfile.mkstemp(".txt")
    os.close(fd)
    open(tmp_file_path, "w").write(hosts_content)

    try:
        shutil.move(tmp_file_path, hosts_path)
    except IOError as e:
        print "Can't write hosts file: {0}{2}Look what you need in the file {1}".format(e, tmp_file_path, eol)
        webbrowser.open(tmp_file_path)
        raw_input("Press Enter to exit...")


def check_files():
    if sys.platform == "win32":
        windows_dir = os.environ.get("SystemRoot", r"C:\Windows")
        hosts_path = windows_dir + r"\system32\drivers\etc\hosts"
    else:
        hosts_path = "/etc/hosts"

    if not os.path.isfile(hosts_path):
        raise RuntimeError("Hosts file not found")
    if not os.access(hosts_path, os.R_OK):
        raise RuntimeError("Hosts file is not readable")

    return hosts_path


def get_params():
    params_path = None
    for params_path in params_paths:
        if os.path.exists(params_path):
            break
    if not (params_path and os.access(params_path, os.R_OK)):
        raise RuntimeError("Error while access params file")

    parser = ConfigParser.ConfigParser()
    parser.read(params_path)

    params = {
        "vhosts_section_id": parser.get("host_params", "vhosts_section_id"),
        "server_ip": parser.get("guest_params", "server_ip"),
    }
    if sys.platform == "win32":
        params["www_dir"] = parser.get("host_params", "www_dir.win32")
    else:
        params["www_dir"] = parser.get("host_params", "www_dir.unix")

    return params


def get_virtual_hosts_names(params):
    hosts = []
    for name in os.listdir(params["www_dir"]):
        if os.path.isdir(os.path.join(params["www_dir"], name)):
            hosts.append(name)
    return hosts


def get_hosts_file_content(hosts_path, hosts, params):
    hosts_content = open(hosts_path, "r").read()
    our_pattern = r"#(\r?\n)+#{id}\s+begin.+?#{id}\s+end(\r?\n)+#".format(id=params["vhosts_section_id"])
    hosts_content = re.sub(our_pattern, "", hosts_content, flags=re.DOTALL)
    hosts_content = hosts_content.strip()

    our_section = "{0}{0}#{0}#{id} begin{0}#{0}".format(eol, id=params["vhosts_section_id"])
    for host in hosts:
        our_section += "{0}\t{1}.loc{2}".format(params["server_ip"], host, eol)
        our_section += "{0}\t{1}.loc{2}".format(params["server_ip"], "www." + host, eol)
    our_section += "#{0}#{id} end{0}#{0}".format(eol, id=params["vhosts_section_id"])
    hosts_content += our_section

    return hosts_content


if __name__ == "__main__":
    try:
        main()
    except BaseException as e:
        print "Error!"
        print str(e)
        raw_input("Press Enter to exit...")
