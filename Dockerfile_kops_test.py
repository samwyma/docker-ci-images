import os
import pytest
import subprocess
import testinfra
import json

with open("version.json") as file:
    version = json.load(file)["kops"]


@pytest.fixture(scope="session")
def host(request):
    subprocess.check_call(
        [
            "docker",
            "build",
            "--build-arg=VERSION=" + version,
            "-t",
            "samwyma/ci-kops",
            "-f",
            "Dockerfile_kops",
            ".",
        ]
    )
    container = (
        subprocess.check_output(
            ["docker", "run", "--rm", "--detach", "--tty", "samwyma/ci-kops"]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + container)

    subprocess.check_call(["docker", "rm", "-f", container])


def test_kops_exists(host):
    assert host.run("command -v kops").succeeded


def test_kops_version(host):
    assert "v" + host.check_output("kops version --short") == version
