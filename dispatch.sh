script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf install golang -y
validate "installing golang package" 

#adding roboshop system user
add_roboshop_user

mkdir -p /app 

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip 
validate "downloading the code file zip folder for the dispatch application"

(
    set -e

    cd /app
    unzip -o /tmp/dispatch.zip

    [ -f go.mod ] || go mod init dispatch

    go mod tidy
    go build

    chown -R roboshop:roboshop /app
)
validate "unzip, installing packages and changing the ownership of /app"


cp "${script_dir_path}/dispatch.service" "/etc/systemd/system/dispatch.service" 
validate "copying the dispatch service file" 

systemd_service_start dispatch
validate "enabling and starting the dispatch service"

caculate_total_time