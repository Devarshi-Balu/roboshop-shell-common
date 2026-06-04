script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

install_nodejs

#adding roboshop system user
add_roboshop_user

#setting up the app directory
mkdir -p /app 
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
validate "downloading the user code files zip folder"

(
    set -e

    cd /app 
    unzip -o /tmp/user.zip
    npm install 
    
    chown -R "roboshop:roboshop" /app
)
validate "unzip, installing packages and changing the ownership of /app"

cp "${script_dir_path}/user.service" "/etc/systemd/system/user.service"
validate "copying the user service file"

systemd_service_start user
validate "enabling and starting the user service"

caculate_total_time