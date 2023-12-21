#!/bin/bash
yum update -y
yum install -y python3

cat <<'EOF' > /usr/local/bin/startup-script.sh
#!/bin/bash
export AWS_DEFAULT_REGION='us-east-1'
export AUDIT_PASSWORD=$(aws ssm get-parameter --name "audit_secret" --with-decryption --query "Parameter.Value" --output text)
aws s3 cp s3://rest-app-bucket-01/main.py .
aws s3 cp s3://rest-app-bucket-01/db_load.py .
aws s3 cp s3://rest-app-bucket-01/restlist.json .
aws s3 cp s3://rest-app-bucket-01/requirements.txt .
pip3 install -r requirements.txt
echo "loading db first time..."
python3 db_load.py
echo "starting main app..."
python3 main.py
EOF

chmod +x /usr/local/bin/startup-script.sh

cat <<'EOF' > /etc/systemd/system/restapp.service
[Unit]
Description=Rest Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/startup-script.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable restapp.service
systemctl start restapp.service