script_dir_path="$(realpath "$(dirname "$0")")"
source "${script_dir_path}/common.sh"

dnf install maven -y
validate "installing maven package"

#adding roboshop system user
add_roboshop_user

mkdir -p /app 

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
validate "downloading the shipping code files"

(
    set -e 

    cd /app 
    unzip -o /tmp/shipping.zip

    mvn clean package 
    mv target/shipping-1.0.jar shipping.jar 

    chown -R "roboshop:roboshop" /app
)
validate "unzip, installing packages and changing the ownership of /app"

cp "${script_dir_path}/shipping.service" "/etc/systemd/system/shipping.service" 
validate "copying the shipping service file" 

systemd_service_start shipping
validate "enabling and starting the shipping service"

#installing the mysql client packages
dnf install mysql -y 
validate "installing mysql package"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then
    mysql -h mysql.rb.devarshi.live -uroot -pRoboShop@1 < /app/db/schema.sql
    validate "adding schema to the db" 

    mysql -h mysql.rb.devarshi.live -uroot -pRoboShop@1 < /app/db/app-user.sql 
    validate "adding app user data to the db" 

    mysql -h mysql.rb.devarshi.live -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate "adding master data to the db"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi