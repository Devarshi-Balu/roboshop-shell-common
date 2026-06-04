script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf module disable nginx -y
validate "disabling nginx module"

dnf module enable nginx:1.24 -y
validate "enabling nginx 1.24 version"

dnf install nginx -y 
validate "installing nginx package"

systemd_service_start nginx
validate "enabling and starting nginx"

rm -rf /usr/share/nginx/html/*
validate "removing existing html file in /usr/share/nginx/html/*.html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
validate "downloading the frontend code files zip folder"

(
    set -e 
    cd /usr/share/nginx/html 
    unzip -o /tmp/frontend.zip
)
validate "unzipping the code files"

cp "${script_dir_path}/nginx.conf" "/etc/nginx/nginx.conf"
validate "copying the nginx config file"

systemctl restart nginx 
validate "restarting nginx module"

caculate_total_time
