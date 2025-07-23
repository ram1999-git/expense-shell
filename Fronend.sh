#!/bin/bash

userid=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
Script_Name=$(basename $0 .sh)
Logfile=/tmp/$Script_Name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

read -sp "Enter MySQL Root Password: " mysql_root_password
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

# Step 1: Install nginx
dnf install nginx -y &>>$Logfile
validate $? "Installing nginx"

# Step 2: Start and enable nginx
systemctl enable nginx &>>$Logfile
systemctl start nginx &>>$Logfile
validate $? "Starting nginx"

# Step 3: Cleanup old frontend files
rm -rf /usr/share/nginx/html/* &>>$Logfile
validate $? "Removing old HTML files"

# Step 4: Download and extract frontend
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$Logfile
validate $? "Downloading frontend code"

unzip /tmp/frontend.zip -d /usr/share/nginx/html/ &>>$Logfile
validate $? "Extracting frontend code"

# Step 5: Create nginx reverse proxy config
cat <<EOF > /etc/nginx/default.d/expense.conf
location /api/ {
    proxy_pass http://localhost:8080/;
    proxy_http_version 1.1;
}

location /health {
    stub_status on;
    access_log off;
}
EOF
validate $? "Creating nginx reverse proxy config"

# Step 6: Restart nginx
systemctl restart nginx &>>$Logfile
validate $? "Restarting nginx"
