import os
import pytest
import subprocess
import testinfra
import json

with open("version.json") as file:
    versions = json.load(file)
    kubectl_version = versions["kubectl"]
    helm_version = versions["helm"]
    aws_iam_auth_version = versions["aws_iam_authenticator"]
    argo_version = versions["argo"]
    tilt_version = versions["tilt"]
    render_version = versions["render"]


@pytest.fixture(scope="session")
def host(request):
    subprocess.check_call(
        [
            "docker",
            "build",
            "--build-arg=KUBECTL_VERSION=" + kubectl_version,
            "--build-arg=HELM_VERSION=" + helm_version,
            "--build-arg=AWS_IAM_AUTHENTICATOR_VERSION=" + aws_iam_auth_version,
            "--build-arg=ARGO_VERSION=" + argo_version,
            "--build-arg=TILT_VERSION=" + tilt_version,
            "--build-arg=RENDER_VERSION=" + render_version,
            "-t",
            "landtech/ci-kubernetes",
            "-f",
            "Dockerfile_kubernetes",
            ".",
        ]
    )
    container = (
        subprocess.check_output(
            ["docker", "run", "--rm", "--detach", "--tty", "landtech/ci-kubernetes"]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + container)

    subprocess.check_call(["docker", "rm", "-f", container])


def test_promtool_exists(host):
    assert host.run("command -v promtool").succeeded


def test_tilt_exists(host):
    assert host.run("command -v tilt").succeeded

def test_helm_can_access_stable(host):
    assert host.run("helm search repo stable").succeeded

def test_helm_can_access_bitnami(host):
    assert host.run("helm search repo bitnami").succeeded