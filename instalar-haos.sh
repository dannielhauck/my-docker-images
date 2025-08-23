!#/bin/bash
set -e
set -u
set -o pipefail

echo "criando diretorio"
sudo mkdir ~/homeassistant
echo "baixando imagem"
sudo wget https://release-assets.githubusercontent.com/github-production-release-asset/115992009/d2e79d78-c8ef-44be-a693-e96af3344a84?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-08-21T13%3A18%3A18Z&rscd=attachment%3B+filename%3Dhaos_ova-16.1.vmdk.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-08-21T12%3A17%3A35Z&ske=2025-08-21T13%3A18%3A18Z&sks=b&skv=2018-11-09&sig=a0gtZQQFb%2BXrXvzIBPszBtmuW2zZ6MydocSdUU%2FHSII%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc1NTc3ODk1NSwibmJmIjoxNzU1Nzc4NjU1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.B5x3hsklhYuycMdP7B25ilCiDqeci46_EtwVPWXQj2g&response-content-disposition=attachment%3B%20filename%3Dhaos_ova-16.1.vmdk.zip&response-content-type=application%2Foctet-stream

sudo unzip haos_ova-16.1.vmdk.zip
echo "instalando vmbox"
sudo apt update && sudo apt upgrade -y
sudo apt install virtualbox -y
sudo apt install virtualbox-ext-pack -y
echo "criando vm"
VBoxManage createvm --name "HomeAssistant" --register
VBoxManage modifyvm "HomeAssistant" --memory 4096 --cpus 2 --ostype "Linux_64"
VBoxManage modifyvm "HomeAssistant" --nic1 bridged --bridgeadapter1 enp3s0
VBoxManage storagectl "HomeAssistant" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "HomeAssistant" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium haos_ova-14.0.vmdk
VBoxManage startvm "HomeAssistant" --type headless
VBoxManage modifyvm "HomeAssistant" --autostart-enabled on
echo "instalação concluída"


