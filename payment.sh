script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf install python3 gcc python3-devel -y
validate "installing the python package"

#adding roboshop system user
add_roboshop_user

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
validate "downloading the shipping code files"

(
    set -e 

    cd /app 
    unzip -o /tmp/payment.zip

    pip3 install -r requirements.txt
    chown -R "roboshop:roboshop" /app
)
validate "unzip, installing packages and changing the ownership of /app"

cp "${script_dir_path}/payment.service" "/etc/systemd/system/payment.service"
validate "copying the payment service file"

systemd_service_start payment
validate "enabling and starting the service"

caculate_total_time