#!/bin/bash

# Update system packages
sudo yum update -y

# Install Python and pip
sudo yum install python3 python3-pip -y

# Install Node.js and npm
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install nodejs -y

# Clone repository
git clone https://github.com/yourusername/todo-app.git
cd todo-app

# Backend setup
python3 -m venv venv
source venv/bin/activate
pip install flask flask-sqlalchemy flask-cors gunicorn
pip freeze > requirements.txt

# Frontend setup
cd frontend
npm install
npm run build

# Install Nginx as reverse proxy
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure Nginx (save as /etc/nginx/nginx.conf)
sudo tee /etc/nginx/nginx.conf <<EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server 127.0.0.1:5000;
    }

    server {
        listen 80;
        server_name yourdomain.com;

        location / {
            root /path/to/todo-app/frontend/build;
            try_files \$uri /index.html;
        }

        location /api {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF

# Start backend with Gunicorn
gunicorn --bind 127.0.0.1:5000 app:app
