script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf install mysql-server -y
validate "installing mysql server"

systemd_service_start mysqld
validate "enabling and starting the mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1
validate "setting the root password for the mysql server"

caculate_total_time
