SSH=$(curl -m 70 -X POST https://us-central1-apache-beam-testing.cloudfunctions.net/retrieveSecret -H "Authorization:bearer $(gcloud auth print-identity-token)" -H "Content-Type:application/json" -d '{ "secretName": "'SSH_DEPLOY_KEY'"}' | jq -r '.secret')
mkdir --parents "$HOME/.ssh"
DEPLOY_KEY_FILE="$HOME/.ssh/deploy_key"
echo "$SSH" > "$DEPLOY_KEY_FILE"
chmod 600 "$DEPLOY_KEY_FILE"
SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
GITHUB_SERVER="github.com"
ssh-keyscan -H "$GITHUB_SERVER" > "$SSH_KNOWN_HOSTS_FILE"
DESTINATION_REPOSITORY_USERNAME="MarcoRob"
DESTINATION_REPOSITORY_NAME="beam-site"
export GIT_SSH_COMMAND="ssh -i "$DEPLOY_KEY_FILE" -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE"
GIT_CMD_REPOSITORY="git@$GITHUB_SERVER:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"
echo ====== Change to beam-site repository ======
git config user.name $DESTINATION_REPOSITORY_USERNAME
git config user.email actions@"self-hosted".local
git add --all
git commit -m "Update beam-site for release" -m "Content generated from commit"
git push -f $GIT_CMD_REPOSITORY origin master
