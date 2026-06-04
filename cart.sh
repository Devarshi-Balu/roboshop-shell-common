script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

#installing nodejs 
install_nodejs

#adding roboshop system user
add_roboshop_user

mkdir -p /app

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
validate "downloading the cart code files"

(
    set -e 

    cd /app 
    unzip -o /tmp/cart.zip

    npm i 
    chown -R "roboshop:roboshop" /app
)
validate "unzip, installing packages and changing the ownership of /app"

cp "${script_dir_path}/cart.service" "/etc/systemd/system/cart.service" 
validate "copying the cart service file" 

systemd_service_start cart
validate "enabling and starting the cart service"

caculate_total_time