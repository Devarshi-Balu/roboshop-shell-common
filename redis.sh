script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf module disable redis -y
dnf module enable redis:7 -y
validate "enabling redis-7 version"

dnf install redis -y 
validate "installing the redis"

sed -i -e "s/127.0.0.1/0.0.0.0/g" "/etc/redis/redis.conf"
validate "changing the port binding, Allowing remote connections"

sed -i -e "/protected-mode/c\protected-mode no" "/etc/redis/redis.conf"
validate "disabling the protected-mode of redis"

systemd_service_start redis
validate "Enabling and starting redis service"

caculate_total_time
