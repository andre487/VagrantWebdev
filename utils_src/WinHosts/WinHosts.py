# -*- coding: UTF-8 -*-
import os, re, time, shutil, webbrowser, tempfile, sys


WWW_DIR = r"D:\htdocs"
SERVER_IP = "192.168.2.10"


def main():
	if sys.platform != "win32":
		raise RuntimeError("This utility needs Win32 to work")
	windows_dir = os.environ.get("SystemRoot", r"C:\Windows")
	hosts_path = windows_dir + r"\system32\drivers\etc\hosts"

	hosts = []
	for name in os.listdir(WWW_DIR):
		if os.path.isdir(os.path.join(WWW_DIR, name)):
			hosts.append(name)
			
	hosts_content = open(hosts_path, "r").read()
	our_pattern = r"#\r\n#Vagrant hosts begin.+?#Vagrant hosts end\r?\n#"
	hosts_content = re.sub(our_pattern, "", hosts_content, flags=(re.DOTALL | re.MULTILINE))
	hosts_content = hosts_content.strip()
	
	our_section = "\r\n\r\n#\r\n#Vagrant hosts begin\r\n#\r\n"
	for host in hosts:
		our_section +=  "{0}\t{1}.loc\r\n".format(SERVER_IP, host)
	our_section += "#\r\n#Vagrant hosts end\r\n#\r\n"
	hosts_content += our_section

	tmp_file, tmp_file_path = tempfile.mkstemp(".txt")
	os.close(tmp_file)
	open(tmp_file_path, "w").write(hosts_content)

	try:
		shutil.move(tmp_file_path, hosts_path)
	except IOError as e:
		print "Can't write hosts file: {0}\r\nLook what you need in the file {1}".format(str(e), tmp_file_path)
		webbrowser.open(tmp_file_path)
		raw_input("Press Enter...")


if __name__ == "__main__":
	try:
		main()
	except BaseException as e:
		print "Error!"
		print str(e)
		raw_input("Press Enter...")
