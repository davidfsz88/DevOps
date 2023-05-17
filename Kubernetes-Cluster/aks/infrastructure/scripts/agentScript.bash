curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/aksdev/.linuxbrew/bin/brew shellenv)"' >> /home/aksdev/.profile
eval "$(/home/aksdev/.linuxbrew/bin/brew shellenv)"
sudo apt-get install -y build-essential
brew install Azure/kubelogin/kubelogin
brew update
brew upgrade Azure/kubelogin/kubelogin
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl