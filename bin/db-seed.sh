#!/bin/sh

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

# Get pod name and seed inital db with default values
POD1=$(kubectl get pods -o=jsonpath='{.items[1].metadata.name}')

kubectl exec -ti $POD1 -- wp --allow-root db reset --yes
kubectl exec -ti $POD1 -- wp --allow-root core install --url=127.0.0.1:30180 --title="intranet" --admin_user=admin --admin_password=password --admin_email=admin@example.com --skip-email
kubectl exec -ti $POD1 -- wp --allow-root option update timezone_string "Europe/London"
kubectl exec -ti $POD1 -- wp --allow-root rewrite structure "/%postname%/"

msg $GREEN"\nDone.\n"

else

msg $YELLOW"\nDB import aborted. Bye!\n\n"

fi

# PART TWO - MYSQL DB IMPORT IF REQUIRED
msg $GREEN"\nLoad MYSQL database? (make sure you have a SQL file in db-dump/ folder) y/n\n"

read -r requested_action02

if [[ "$requested_action02" = "y" ]]; then

printf "\nLoading database, this may take some time...\n"

POD2=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}')
DBFILE=(db-dump/*.sql)

else
    msg $YELLOW"\nDatabase dump aborted.\n\n"
fi

if [ -f ${DBFILE} ]; then
    kubectl exec -i $POD2 -- mysql --user=db_wordpress_user --password=db_root wordpress < $DBFILE
else
    msg $YELLOW"\nNo database file found in db-dump directory.\n\n"
fi

POD1=$(kubectl get pods -o=jsonpath='{.items[1].metadata.name}')
# Clean up and format after everything
kubectl exec -ti $POD1 -- wp --allow-root core update-db
kubectl exec -ti $POD1 -- wp --allow-root theme list
kubectl exec -ti $POD1 -- wp --allow-root theme activate clarity

exit 0