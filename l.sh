#!/bin/bash
set -e

# ==========================
# VARIÁVEIS
# ==========================
VM_NAME="HomeAssistant"
HA_VERSION="14.2" # versão do HA OS
HA_VDI="haos_ova-${HA_VERSION}.vdi"
HA_URL="https://github.com/home-assistant/operating-system/releases/download/${HA_VERSION}/haos_ova-${HA_VERSION}.vdi.zip"

# ==========================
# INSTALAR VIRTUALBOX
# ==========================
echo "[1/5] Instalando VirtualBox..."
if ! command -v VBoxManage &> /dev/null; then
    sudo apt update
    # aceitar licença automaticamente
    echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
    sudo apt install -y virtualbox virtualbox-ext-pack unzip wget
else
    echo "VirtualBox já instalado, pulando..."
fi

# ==========================
# BAIXAR IMAGEM HA OS
# ==========================
echo "[2/5] Baixando imagem Home Assistant OS..."
if [ ! -f "${HA_VDI}" ]; then
    wget -q "${HA_URL}" -O haos.zip
    unzip haos.zip
    rm haos.zip
else
    echo "Imagem ${HA_VDI} já existe, pulando..."
fi

# ==========================
# CRIAR VM
# ==========================
echo "[3/5] Criando VM no VirtualBox..."
if ! VBoxManage list vms | grep -q "\"${VM_NAME}\""; then
    VBoxManage createvm --name "${VM_NAME}" --ostype "Linux_64" --register

    VBoxManage modifyvm "${VM_NAME}" --memory 4096 --cpus 2 --boot1 disk --nic1 bridged --audio none

    VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${HA_VDI}"
else
    echo "VM ${VM_NAME} já existe, pulando..."
fi

# ==========================
# INICIAR VM
# ==========================
echo "[4/5] Iniciando VM em modo headless..."
if ! VBoxManage list runningvms | grep -q "\"${VM_NAME}\""; then
    VBoxManage startvm "${VM_NAME}" --type headless
else
    echo "VM ${VM_NAME} já está rodando, pulando..."
fi

# ==========================
# FINAL
# ==========================
echo "[5/5] Concluído!"
echo "Acesse o Home Assistant em: http://homeassistant.local:8123 (ou pelo IP da VM na rede)"