script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

#install nodejs module
install_nodejs

#adding roboshop system user
add_roboshop_user

#setting up the app directory
mkdir -p /app 
curl -L -o "/tmp/catalogue.zip" "https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip" 
validate "downloading the catalogue code file zip folder"

(
    set -e

    cd /app 
    unzip -o /tmp/catalogue.zip
    npm install 
    
    chown -R "roboshop:roboshop" /app
)
validate "unzip, installing packages and changing the ownership of /app"

cp "${script_dir_path}/catalogue.service" "/etc/systemd/system/catalogue.service"
validate "copying the service file for catalogue"

systemd_service_start catalogue
validate "enabling and starting the catalogue service"

cp "${script_dir_path}/mongo.repo" "/etc/yum.repos.d/mongo.repo"
validate "copying the repo file for mongodb"

dnf install mongodb-mongosh -y
validate "install mongsh client"

MongoDBHost="mongodb.rb.devarshi.live"
INDEX=$(mongosh --host "$MongoDBHost" --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")' | tail -1)

if [ "$INDEX" -lt 0 ]; then
    mongosh --host $MongoDBHost </app/db/master-data.js
    validate "Loading master data"
else
    echo -e "Master data already loaded ... $Y SKIPPING ....$N"
fi