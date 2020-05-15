import os
import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host(request):
    subprocess.check_call(
        [
            "docker",
            "build",
            "--build-arg=VERSION=" + os.environ["version"],
            "-t",
            "landtech/ci-eb",
            "-f",
            "Dockerfile_eb",
            ".",
        ]
    )
    container = (
        subprocess.check_output(
            ["docker", "run", "--rm", "--detach", "--tty", "landtech/ci-eb"]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + container)

    subprocess.check_call(["docker", "rm", "-f", container])


@pytest.mark.parametrize(
    "package",
    [
        ("bash"),
        ("coreutils"),
        ("curl"),
        ("docker"),
        ("grep"),
        ("jq"),
        ("lsof"),
        ("make"),
        ("netcat-openbsd"),
        ("ncurses"),
        ("rsync"),
        ("tar"),
        ("wget"),
        ("zip"),
        ("util-linux"),
    ],
)
def test_installed_dependencies(host, package):
    assert host.package(package).is_installed


def test_awscli_alias(host):
    assert host.file("/root/.aws/cli/alias").exists
    # run a version command with an alias, a fail will return code 2
    assert host.run("aws account-id --version").succeeded


def test_docker(host):
    assert host.run("docker --version").succeeded


def test_bats(host):
    assert host.run("bats --version").succeeded


def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "awscli" in packages
    assert "awsebcli" in packages
    assert "credstash" in packages
    assert "docker-compose" in packages
    assert "pipenv" in packages
    assert "yq" in packages


def test_awsebcli(host):
    assert host.run("eb --version").succeeded


def test_awsebcli_version(host):
    assert host.run(f"eb --version | grep ' {os.environ['version']} '").succeeded


def test_semver_exists(host):
    assert host.run("semver.sh --help").succeeded


def test_deployment_exists(host):
    assert host.run("command -v deployment").succeeded
    assert host.run("timeout --help").succeeded
    assert host.run("command -v nc").succeeded


def test_entrypoint_is_bash(host):
    assert host.check_output("echo $SHELL") == "/bin/bash"
