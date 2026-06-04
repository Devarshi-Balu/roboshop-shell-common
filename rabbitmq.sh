script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

cp "${script_dir_path}/rabbitmq.repo" "/etc/yum.repos.d/rabbitmq.repo"
validate "adding rabbitmq repo"

dnf install rabbitmq-server -y
validate "installing Rabbitmq server"

systemd_service_start rabbitmq-server
validate "enabling and starting rabbitmq server" 

rabbitmqctl list_users | grep -w roboshop || rabbitmqctl add_user roboshop roboshop123 
validate "adding roboshop user to the rabbitmq server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate "setting roboshop user permissions in rabbitmq server"

caculate_total_time
