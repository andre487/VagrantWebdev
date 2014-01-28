from distutils.core import setup
import os
import py2exe


current_dir = os.path.dirname(os.path.realpath(__file__))
manifest = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="requireAdministrator" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>
  <dependency>
    <dependentAssembly>
      <assemblyIdentity
        type="win32"
        name="Microsoft.VC90.CRT"
        version="9.0.21022.8"
        processorArchitecture="*"
        publicKeyToken="1fc8b3b9a1e18e3b" />
    </dependentAssembly>
  </dependency>
</assembly>
"""

setup(
    name="PatchHosts Utility",
    description="Utility to patch hosts file for .loc zone",
    author="Andre",
    version="1.1",
    console=[
        {
            "script": current_dir + "/PatchHosts.py",
            "other_resources": [(24, 1, manifest)],
        }
    ],
    zipfile=None,
    options={
        "py2exe": {
            "bundle_files": 1,
            "compressed": True,
            "optimize": 2,
            "excludes": ["_ssl", "pyreadline", "difflib", "doctest", "locale", "optparse", "pickle", "calendar"],
            "dll_excludes": ["msvcr71.dll", "w9xpopen.exe"],
            "dist_dir": os.path.abspath(current_dir + "/../../bin"),
        }
    },
)
