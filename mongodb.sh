script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

#copying repo file
cp ${script_dir_path}/mongo.repo /etc/yum.repos.d/mongo.repo
validate "copying mongo repo file"

dnf install mongodb-org -y 
validate "Installing MongoDB server"

systemd_service_start mongod
validate "enabling and starting the mongod server" 

sed -i -e "s/127.0.0.1/0.0.0.0/g" "/etc/mongod.conf"
validate "changing the port binding of mongod server for allowing remote connections"

systemctl restart mongod
validate "Restarting the mongodb server"