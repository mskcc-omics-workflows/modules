import os
import yaml
from pathlib import Path
import subprocess

def test_run(yml, module):
    proc,files = hpc_run(yml, module)
    for f in files:
        if os.path.isdir(f["path"]) or os.path.isfile(f["path"]):
            status = True
    assert status


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
