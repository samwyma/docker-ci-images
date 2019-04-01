#! /bin/bash

# Installs and uses a kubectl context which authenticates with the kubernetes cluster using IAM
# Args:
#   --aws-profile <profile> - OPTIONAL - Will always use the profile with this name (in your aws creds) for authenticating with the cluster
#                                        Otherwise, will use whatever profile is set in the current shell (or 'default' if none)
#   --cluster <cluster_name> - OPTIONAL - Will set up the user and context for the given cluster
#                                         Otherwise will use whatever cluster is in the current context

set -e

for var in "$@"
do
  case "$var" in
    --aws-profile)
      selected_aws_profile="$2"
      ;;
    --cluster)
      cluster_name="$2"
      ;;
  esac
  shift
done

if [ ! -f ~/.kube/config ]; then
  echo "~/.kube/config not found. Generating a new one"
  mkdir -p ~/.kube
  kubectl config view > ~/.kube/config
fi

if [ "$selected_aws_profile" == "" ]; then 
  env=null
else 
  env='
  [{
    "name": "AWS_PROFILE",
    "value": "'"$selected_aws_profile"'"
  }]
  '
  export AWS_PROFILE="$selected_aws_profile"
fi

if [ "$cluster_name" == "" ]; then
  context=$(kubectl config current-context || echo "")
  if [ "$context" == "" ]; then
    echo "No current kubernetes context. You must set the --cluster flag with the desired cluster to use (e.g. --cluster k8.sandbox.landinsight.io)"
    exit 1;
  fi
  cluster_name=$(kubectl config view -o json | jq -r ".contexts[] | select(.name == \"$context\") | .context.cluster")
fi

aws_account_id=$(aws sts get-caller-identity --output text --query 'Account')

credstash_key="k8/ca-data/$cluster_name"
echo "Getting cluster ca data from credtash under key $credstash_key"
cluster_ca_data=$(credstash get "$credstash_key" || echo "")

if [ "$cluster_ca_data" == "" ]; then
  echo "Could not get cluster ca data from credtash. Please ensure the ca data has been added to credtash under the key $credstash_key"
  exit 1
fi

user_name="$cluster_name.iam"

# Add (upsert) user
new_user='
{
  "name": "'"$user_name"'",
  "user": {
    "exec": {
      "command": "aws-iam-authenticator",
      "args": [
        "token",
        "-i",
        "'"$cluster_name"'",
        "-r",
        "arn:aws:iam::'"$aws_account_id"':role/k8-admin"
      ],
      "env": '"$env"',
      "apiVersion": "client.authentication.k8s.io/v1alpha1"
    }
  }
}
'
temp_config="/tmp/$(uuidgen)"
cp ~/.kube/config /tmp/old_kube_config.yaml
cat ~/.kube/config | yq . \
  | jq 'del(.users[] | select(.name == "'"$user_name"'")) | .users[.users | length] |= . + '"$new_user"'' \
  | yq -y . > "$temp_config"
mv "$temp_config" ~/.kube/config

# Add context
context_name="$user_name"
kubectl config set-cluster "$cluster_name" --server "https://api.$cluster_name"
kubectl config set "clusters.$cluster_name.certificate-authority-data" "$cluster_ca_data"
kubectl config set-context "$context_name" --user "$user_name" --cluster "$cluster_name"

# Use this context
kubectl config use-context "$context_name"