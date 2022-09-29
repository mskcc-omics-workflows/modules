import os
import yaml
from pathlib import Path
import subprocess

def test_run(yml, module):
    if not yml:
        return
    proc,files = hpc_run(yml, module)
    status_list = []
    for f in files:
        if os.path.isdir(f["path"]) or os.path.isfile(f["path"]):
            status_list.append(True)
        else:
            status_list.append(False)
    assert False not in status_list


def hpc_run(yaml_file, module_name):
    f = Path(yaml_file)
    raw = yaml.safe_load(f.open())
    files = []
    for item in raw:
        if item["name"] == f"hpc_{module_name}":
            cmd = item["command"]
            if "files" in item:
                files = item["files"]
    import subprocess
    proc = subprocess.run(cmd, shell=True)
    return (proc, files)
