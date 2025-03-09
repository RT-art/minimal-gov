#!/bin/bash
set -e

echo "パッケージリストを更新しています..."
sudo dnf update -y  # apt を dnf に変更、-y オプションを追加

echo "Dockerをインストールしています..."
sudo dnf install docker -y  # apt を dnf に変更、docker.io -> docker に変更

echo "Dockerサービスを起動しています..."
sudo systemctl start docker

echo "Dockerサービスを自動起動設定にしています..."
sudo systemctl enable docker

echo "Dockerのインストールと設定が完了しました。"