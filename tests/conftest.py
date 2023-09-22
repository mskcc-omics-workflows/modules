from pathlib import Path
import pytest
import git

repository_url = "https://github.com/nf-core/modules.git"
remote_name = "nf-core-repo"
subfolder_path = "modules/nf-core"

def pytest_sessionstart(session):
    # Open the local Git repository
    local_repository_path = Path(__file__).parent.parent.resolve()
    repo = git.Repo(local_repository_path)

    # Add the remote origin
    has_remote = False
    for remote in repo.remotes:
        if remote.name == "nf-core-repo":
            has_remote = True
    if not has_remote:
        repository_url = "https://github.com/nf-core/modules.git"
        remote = repo.create_remote(remote_name, repository_url, track="master")
    remote.fetch()
    master_branch = repo.create_head("master", remote.refs.master)

    # Print the remote URLs to verify
    for remote in repo.remotes:
        print(f"Remote '{remote.name}': {remote.url}")

    # Add subfolder
    repo.git.read_tree("--prefix=" + subfolder_path, "-u", f"{remote_name}/master:{subfolder_path}")


def pytest_sessionfinish(session, exitstatus): 
    local_repository_path = Path(__file__).parent.parent.resolve()
    repo = git.Repo(local_repository_path)
    repo.git.rm(subfolder_path, r=True,f=True,q=True)
    repo.delete_remote(remote_name)

