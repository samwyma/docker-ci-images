import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host(request):
    subprocess.check_call(
        ["docker", "build", "-t", "landtech/ci-eb", "-f", "Dockerfile_eb", "."]
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
                "landtech/ci-eb",
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


def test_awscli_alias(host):
    assert host.file("/root/.aws/cli/alias").exists
    # run a version command with an alias, fails return code 2
    assert host.run("aws account-id --version").rc == 0


def test_pip_packages(host):
    packages = host.pip_package.get_packages()
    assert "awscli" in packages
    assert "awsebcli" in packages
    assert "credstash" in packages
    assert "docker-compose" in packages


def test_awsebcli(host):
    assert host.run("eb --version").rc == 0

