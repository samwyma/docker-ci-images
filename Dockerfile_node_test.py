import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host(request):
    image = "landtech/ci-node"

    subprocess.check_call(
        ["docker", "build", "-t", image, "-f", "Dockerfile_node", "."]
    )
    docker_id = (
        subprocess.check_output(
            [
                "docker",
                "run",
                "--rm",
                "--detach",
                "--entrypoint=/usr/bin/tail",  # keep the container running while we test it
                "--tty",
                image,
            ]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + docker_id)

    # teardown
    subprocess.check_call(["docker", "rm", "-f", docker_id])


@pytest.mark.parametrize(
    "package",
    [
        ("bash"),
        ("coreutils"),
        ("curl"),
        ("docker"),
        ("grep"),
        ("jq"),
        ("make"),
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
    # run a version command with an alias, fails return code 2
    assert host.run("aws account-id --version").rc == 0


def test_docker(host):
    assert host.run("docker --version").rc == 0


def test_bats(host):
    assert host.run("bats --version").rc == 0


def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "awscli" in packages
    assert "credstash" in packages
    assert "docker-compose" in packages


def test_node(host):
    assert host.run("node --version").rc == 0

