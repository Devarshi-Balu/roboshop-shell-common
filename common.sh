#log_files variables
script_name="$(basename "$0" .sh)"
script_dir_path="$(realpath "$(dirname "$0")")"
logs_dir="${script_dir_path}/logs"
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="${logs_dir}/${script_name}_${timestamp}.log"

mkdir -p $logs_dir
exec > >(tee -a $log_file) 2>&1

#color varibles
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

user_id=$(id -u)

if [[ $user_id -ne 0 ]]; then 
    echo "Please run the script as root user"; 
    exit 1; 
fi

#function for validating the commands executions with exit status  
function validate(){
    if [[ "$?" -ne 0 ]]; then 
        echo -e "$1 ... $R Failure $N";
        exit 1;
    else 
        echo -e "$1 ... $G Success $N";
    fi
}

function add_roboshop_user(){
    #adding roboshop system user
    id roboshop 
    if [[ "$?" -ne 0 ]]; then 
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate "adding roboshop system user"
    else 
        echo -e "user 'roboshop' already exists ... $Y SKIPPING $N"
    fi 
}

function install_nodejs(){
    dnf module disable nodejs -y
    validate "disbaling the nodejs module"

    dnf module enable nodejs:20 -y 
    validate "enabling nodejs:20 version"

    dnf install nodejs -y 
    validate "installing nodejs"
}

function systemd_service_start(){
    local service="$1"

    systemctl daemon-reload
    validate "loading the service"

    systemctl enable $service 
    systemctl start $service
    validate "enabling and starting the $service service"
}