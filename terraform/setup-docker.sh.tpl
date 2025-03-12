#!/bin/bash
sudo dnf update -y
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
docker stop my-app || true
docker rm my-app || true
docker run -d --name my-app -p 80:5000 ${docker_image_name}
echo "デプロイ成功！" > /tmp/terraform_deployed.txt