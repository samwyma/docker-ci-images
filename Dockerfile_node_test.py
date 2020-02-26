import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host(request):
    image = "landtech/ci-node"

    subprocess.check_call(
        ["docker", "build", "--no-cache", "-t", image, "-f", "Dockerfile_node", "."]
    )
    container = (
        subprocess.check_output(["docker", "run", "--rm", "--detach", "--tty", image])
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
        ("tar"),
        ("wget"),
        ("zip"),
        ("util-linux"),
    ],
)
def test_installed_dependencies(host, package):
    assert host.package(package).is_installed


@pytest.mark.parametrize(
    "package",
    [
        ("libressl-dev"),
        ("libc-dev"),
        ("libffi-dev"),
        ("gcc"),
        ("make"),
        ("python3-dev"),
    ],
)
def test_build_dependencies(host, package):
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
    assert "credstash" in packages
    assert "docker-compose" in packages
    assert "pipenv" in packages


def test_pipenv_works(host):
    host.run(
        "echo '"
        "[[source]]\n"
        'name = "pypi"\n'
        'url = "https://pypi.org/simple"\n'
        "verify_ssl = true' > Pipfile"
    )

    assert host.run("pipenv install").succeeded


def test_node(host):
    assert host.run("node --version").succeeded


def test_semver_exists(host):
    assert host.run("semver.sh --help").succeeded


def test_deployment_exists(host):
    assert host.run("command -v deployment").succeeded
    assert host.run("timeout --help").succeeded
    assert host.run("nc --help").succeeded


def test_entrypoint_is_bash(host):
    assert host.check_output("echo $SHELL") == "/bin/bash"
