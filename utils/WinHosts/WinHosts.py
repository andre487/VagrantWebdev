# -*- coding: UTF-8 -*-
import os, re, time, shutil, webbrowser, tempfile, sys


WWW_DIR = r'D:\htdocs'
SERVER_IP = '192.168.2.10'


def main():
	if sys.platform == "win32":
		windows_dir = os.environ.get('SystemRoot', r'C:\Windows')
		hosts_path = windows_dir + r'\system32\drivers\etc\hosts'
	else:
		hosts_path = r'/etc/hosts'

	hosts = []
	for name in os.listdir(WWW_DIR):
		if os.path.isdir(os.path.join(WWW_DIR, name)):
			hosts.append(name)
			
	tmp_file_path = tempfile.mkstemp('.txt')[1]
	with open(hosts_path, 'r') as hosts_file:
		hosts_content = hosts_file.read()
		our_section = "\r\n\r\n#\r\n#Vagrant hosts begin\r\n#\r\n"
		for host in hosts:
			our_section += SERVER_IP + ' '*4 + host + '.loc\r\n'
		our_section += "#\r\n#Vagrant hosts end\r\n#\r\n"
		
		hosts_content = re.sub('#\n#Vagrant hosts begin\n#\n.+\n#\n#Vagrant hosts end\n#\n', '', hosts_content, re.DOTALL)
		hosts_content = hosts_content.strip()
		hosts_content += our_section
		open(tmp_file_path, 'w').write(hosts_content)

	try:
		shutil.move(tmp_file_path, hosts_path)
	except IOError as e:
		print "Can't write hosts file: {0}\r\nLook what you need in the file {1}".format(str(e), tmp_file_path)
		webbrowser.open(tmp_file_path)


if __name__ == '__main__':
	try:
		main()
		print "Success!"
	except BaseException as e:
		print "Error!"
		print str(e)
	raw_input("Press Enter...")
