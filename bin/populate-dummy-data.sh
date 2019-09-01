#!/bin/sh
# Populate your K8s install with dummy WordPress data

RESTORE='\033[0m'
YELLOW='\033[00;33m'
GREEN='\033[00;32m'

function msg {
  printf "$1"$RESTORE
}

# PART ONE - WP CLI SEED
msg $GREEN"\nWarning: this will wipe your local WP database. Do you want to run WP database reset? y/n\n"
read -r requested_action

if [[ "$requested_action" = "y" ]]; then

POD1=$(kubectl get pods -o=jsonpath='{.items[1].metadata.name}')

kubectl exec -ti $POD1 -- wp --allow-root db reset --yes
kubectl exec -ti $POD1 -- wp --allow-root core install --url=127.0.0.1:30180 --title="intranet" --admin_user=admin --admin_password=password --admin_email=admin@example.com --skip-email
kubectl exec -ti $POD1 -- wp --allow-root option update timezone_string "Europe/London"
kubectl exec -ti $POD1 -- wp --allow-root rewrite structure "/%postname%/"
kubectl exec -ti $POD1 -- wp --allow-root theme list
kubectl exec -ti $POD1 -- wp --allow-root theme activate clarity
kubectl exec -ti $POD1 -- wp --allow-root plugin activate --all

PAGE_ID=$(wp post create --post_type=page --post_title="Knowledge article page" --post_name="knowledge-article-page" --post_status=publish --post_content="Page dummy content" --porcelain)
PAGE2_ID=$(wp post create --post_type=page --post_title="Knowledge article page two" --post_name="knowledge-article-page-two" --post_status=publish --porcelain)

kubectl exec -ti $POD1 -- wp --allow-root post create --post_type=post --post_title="Knowledge article post" --post_name="knowledge-article-post" --post_status=publish --post_content="Post dummy content."
kubectl exec -ti $POD1 -- wp --allow-root menu create "Lefthand main menu"
kubectl exec -ti $POD1 -- wp --allow-root menu location assign "Lefthand main menu" primary_navigation
kubectl exec -ti $POD1 -- wp --allow-root menu item add-post "Lefthand main menu" $PAGE_ID
kubectl exec -ti $POD1 -- wp --allow-root menu item add-post "Lefthand main menu" $PAGE2_ID

msg $GREEN"\nDone.\n"

else

msg $YELLOW"\nDB import aborted. Bye!\n\n"

fi