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

# Step 1: Install Node.js 20
dnf module disable nodejs -y &>>$Logfile
validate $? "Disabling default Node.js module"

dnf module enable nodejs:20 -y &>>$Logfile
validate $? "Enabling Node.js 20 module"

dnf install nodejs -y &>>$Logfile
validate $? "Installing Node.js"

# Step 2: Create user if not exists
id expense &>>$Logfile
if [ $? -ne 0 ]; then
    useradd expense &>>$Logfile
    validate $? "Creating expense user"
else 
    echo -e "Expense user already created...$Y Skipping $N"
fi 

# Step 3: Create /app directory
mkdir -p /app &>>$Logfile
validate $? "Creating /app directory"

# Step 4: Download and extract backend code
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$Logfile
if [ $? -eq 0 ]; then
    validate 0 "Downloading backend code"

    rm -rf /app/* &>>$Logfile
    validate $? "Cleaning old app contents"

    unzip /tmp/backend.zip -d /app &>>$Logfile
    validate $? "Extracting backend code"
else
    validate 1 "Downloading backend code"
    echo -e "$R Skipping further steps due to download failure $N"
    exit 1
fi

# Step 5: Install Node.js dependencies
cd /app || exit 1
npm install &>>$Logfile
validate $? "Installing Node.js dependencies"

# Step 6: Create systemd service file
cat <<EOF > /etc/systemd/system/backend.service
[Unit]
Description=Node.js Backend Service
After=network.target

[Service]
User=expense
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/index.js
Restart=always
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
EOF
validate $? "Creating backend systemd service file"

# Step 7: Start and enable service
systemctl daemon-reload &>>$Logfile
validate $? "Systemd daemon reload"

systemctl start backend &>>$Logfile
validate $? "Starting backend service"

systemctl enable backend &>>$Logfile
validate $? "Enabling backend service"

# Step 8: Install MySQL client
dnf install mysql -y &>>$Logfile
validate $? "Installing MySQL client"

# Step 9: Load DB schema
mysql -h 172.31.91.208 -uroot -p"${mysql_root_password}" < /app/schema/backend.sql &>>$Logfile
validate $? "Loading DB schema"

# Step 10: Restart backend service after DB setup
systemctl restart backend &>>$Logfile
validate $? "Restarting backend service"
