#!/bin/bash

userid=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
Script_Name=$(basename $0 .sh)
Logfile=/tmp/$Script_Name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

read -sp "Please Enter DB Root Password: " mysql_root_password
echo

validate() {
    if [ $1 -ne 0 ]; then 
        echo -e "$2...$R Failure $N"
        exit 1
    else
        echo -e "$2...$G Success $N"
    fi 
}

if [ $userid -ne 0 ]; then
    echo -e "$R Please run the script with root access $N"
    exit 1
else 
    echo -e "$G You are super user $N"
fi

dnf install mysql-server -y &>>$Logfile
validate $? "Installing MySQL Server"

systemctl enable mysqld &>>$Logfile
validate $? "Enabling MySQL service"

systemctl start mysqld &>>$Logfile
validate $? "Starting MySQL service"

# Check if password is already set
mysql -u root -p"${mysql_root_password}" -e 'SHOW DATABASES;' &>>$Logfile
if [ $? -ne 0 ]; then
    echo "Setting up MySQL root password..."
    mysql_secure_installation --set-root-pass "${mysql_root_password}" &>>$Logfile
    validate $? "MySQL root password setup"
else 
    echo -e "MySQL root password is already set...$Y Skipping $N"
fi
