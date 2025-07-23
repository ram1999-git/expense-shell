#!/bin/bash

userid=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
Logfile=/tmp/$Script_Name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please Enter DB Password:"
read -s mysql_root_passeord

validate() {
    if [ $1 -ne 0 ]; then 
        echo -e "$2...$R Failure $N"
    else
        echo -e "$2...$G Success $N"
    fi 
}

if [ $userid -ne 0 ]; then
    echo "Please run the script with root access"
    exit 1
else 
    echo "You are super user"
fi

# Define MySQL root password if not already exported
mysql_root_password=${mysql_root_password:-"ExpenseApp@1"}

dnf install mysql-server -y &>>$Logfile
validate $? "Installing Mysql Server"

systemctl enable mysqld &>>$Logfile
validate $? "mysql server enable"

systemctl start mysqld &>>$Logfile
validate $? "Mysql server started"

# Try connecting with password, check if already set
mysql -u root -p"${mysql_root_password}" -e 'show databases;' &>>$Logfile
if [ $? -ne 0 ]; then
    mysql_secure_installation --set-root-pass "${mysql_root_password}" &>>$Logfile
    validate $? "Mysql root password setup"
else 
    echo -e "Mysql root password is already set...$Y Skipping $N"
fi
