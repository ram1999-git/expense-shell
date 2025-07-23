#!/bin/bash

userid=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
Logfile=/tmp/$Script_Name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

validtae(){
    if [ $1 -ne 0 ]
    then 
    echo -e "$2...$R Failure $N"
    else
    echo -e "$2...$G Success $N"
    fi 
}

if [ $userid -ne 0 ]
then
echo "Please run the script with root access"
else 
echo "You are super user"

fi

dnf install mysql -y &>>$Logfile
validate $? "Installing Mysql Server"

systemctl enable mysqld &>>Logfile
validate $? "mysql server enable"

systemctl start mysqld &>>Logfile
validate $? "Mysql server started"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>Logfile
validate $? "Mysql server set the password"
