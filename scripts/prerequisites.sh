#!/usr/bin/env bash

# Variables
python_version="3.13.9"

echo -e "\n⚙️ Mise à jour des paquets système..."
echo "=================================================="
sudo apt update
sudo apt upgrade -y

echo -e "\n⚙️ Installation de pyenv..."
echo "=================================================="

curl -fsSL https://pyenv.run | bash
pyenv --version

echo -e "\n⚙️ Installation des prérequis pour Python..."
echo "=================================================="

python3_libs=(
  build-essential
  ca-certificates
  curl
  gcc
  libbz2-dev
  libffi-dev
  libgdbm-dev
  liblzma-dev
  libncursesw5-dev
  libnss3-dev
  libreadline-dev
  libsqlite3-dev
  libssl-dev
  make
  tk-dev
  uuid-dev
  xz-utils
  wget
  zlib1g-dev
)
sudo apt install -y "${python3_libs[@]}"

echo -e "\n⚙️ Installation de Python ${python_version} (latest) via pyenv..."
echo "=================================================="
pyenv install "${python_version}" --skip-existing
pyenv global "${python_version}"
python --version
pip --version

echo -e "\n⚙️ Installation d'Ansible via pip..."
echo "=================================================="
python -m pip install --user ansible

echo -e "\n⚙️ Installation d'Ansible Lint via pip..."
echo "=================================================="
python -m pip install --user ansible-lint

echo -e "\n⚙️ Nettoyage des paquets inutilisés..."
echo "=================================================="
sudo apt autoremove -y
