#! /bin/bash

# Installs and uses a kubectl context which authenticates with the kubernetes cluster using IAM
# Args:
#   --aws-profile <profile> - OPTIONAL - Will always use the profile with this name (in your aws creds) for authenticating with the cluster
#                                        Otherwise, defaults to 'default' if not provided
#   --cluster <cluster_name> - OPTIONAL - Will set up the user and context for the given cluster
#                                         Otherwise will use whatever cluster is in the current context

set -euo pipefail

aws_profile="default"
role="k8-admin"

for var in "$@"; do
  case "$var" in
  --aws-profile)
    aws_profile="$2"
    ;;
  --cluster)
    cluster_name="$2"
    ;;
  --role)
    role="$2"
    ;;
  esac
  shift
done

export AWS_PROFILE="$aws_profile"

if [ ! -f ~/.kube/config ]; then
  echo "$HOME/.kube/config not found. Generating one..."
  mkdir -p ~/.kube
  kubectl config view >~/.kube/config
fi

if [ "$cluster_name" == "" ]; then
  context=$(kubectl config current-context || echo "")
  if [ "$context" == "" ]; then
    echo "No current kubernetes context. You must set the --cluster flag with the desired cluster to use (e.g. --cluster k8.sandbox.landinsight.io)"
    exit 1
  fi
  cluster_name=$(kubectl config view -o json | jq -e -r ".contexts[] | select(.name == \"$context\") | .context.cluster")
fi

echo "Getting cluster ca data from credtash..."
cluster_ca_data=$(credstash get "k8/ca-data/$cluster_name" || echo "")

if [ "$cluster_ca_data" == "" ]; then
  echo "Could not get cluster ca data from credtash. Please ensure the ca data has been added to credtash under the key $credstash_key"
  exit 1
fi

cluster_user="$cluster_name.iam"

temp_user="$(mktemp)"
temp_config="$(mktemp)"

echo "
users:
- name: $cluster_user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - $cluster_name
      - -r
      - arn:aws:iam::$(aws account-id):role/$role
      command: aws-iam-authenticator
      env:
      - name: AWS_PROFILE
        value: $aws_profile" >"$temp_user"

echo "Merging generated config with defined config using KUBECONFIG var" # https://stackoverflow.com/a/56894036
export KUBECONFIG=~/.kube/config:$temp_user
kubectl config view --raw >"$temp_config"
mv "$temp_config" ~/.kube/config
rm -Rf "$temp_config"
unset KUBECONFIG

echo "Setting additional context values..."
kubectl config set-cluster "$cluster_name" --server "https://api.$cluster_name"
kubectl config set "clusters.$cluster_name.certificate-authority-data" "$cluster_ca_data"
kubectl config set-context "$cluster_name" --user "$cluster_user" --cluster "$cluster_name"

echo "Using the newly generated context..."
kubectl config use-context "$cluster_name"
