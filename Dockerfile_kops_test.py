import os
import pytest
import subprocess
import testinfra
import json


@pytest.fixture(scope="session")
def host(request):
    with open("version.json") as file:
        version = json.load(file)["kops"]

    subprocess.check_call(
        [
            "docker",
            "build",
            "--build-arg=VERSION=" + version,
            "-t",
            "landtech/ci-kops",
            "-f",
            "Dockerfile_kops",
            ".",
        ]
    )
    container = (
        subprocess.check_output(
            ["docker", "run", "--rm", "--detach", "--tty", "landtech/ci-kops"]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + container)

    subprocess.check_call(["docker", "rm", "-f", container])


def test_kops_exists(host):
    assert host.run("command -v kops").succeeded


def test_kops_version(host):
    assert host.check_output("kops version --short") == "1.15.2"
