#!/bin/bash

# Clear terminal for clean dashboard view
clear

# ==========================================
# 🌟 PREMIUM COLOR CODES & FX
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# FUNCTION: TYPING EFFECT ANIMATION
type_effect() {
    local text="$1"
    local delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# FUNCTION: LOADING BAR ANIMATION
loading_bar() {
    local title="$1"
    echo -ne "${YELLOW}⏳ $title ${NC}[          ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[===       ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[======     ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[=========  ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[==========]"
    echo -e " ${GREEN}DONE!${NC}"
}

# AUTOMATED ROOT/SUDO PRIVILEGE CHECK
if [ "$(id -u)" -eq 0 ]; then
    SUDO_CMD=""
else
    SUDO_CMD="sudo"
fi

# ==========================================
# MAIN INTERACTIVE LIST MENU
# ==========================================
show_menu() {
    clear
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}          [👹 DXD LABS PREMIUM VPS DASHBOARD 👹]          ${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}                ┌─────────────────────────┐               ${NC}"
    echo -e "${WHITE}                │   ${RED}█▀▀█ █──█ █▄─▄█ █▀▀█${WHITE}  │  <[SUKUNA V2] ${NC}"
    echo -e "${WHITE}                │   ${RED}█▄▄█ █▄▄█ █ █ █ █▄▄█${WHITE}  │               ${NC}"
    echo -e "${WHITE}                └─────────────────────────┘               ${NC}"
    echo -e "${PURPLE}                   (█)─(█)     (█)─(█)                   ${NC}"
    echo -e "${PURPLE}                  █████████   █████████                  ${NC}"
    echo -e "${RED}                 ███████████████████████                 ${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo -e "${CYAN}  ____  _____ _   _ ____     ____    _    __  __ ___ _   _  ____ ${NC}"
    echo -e "${CYAN} |  _ \| ____| | | |  _ \   / ___|  / \  |  \/  |_ _| \ | |/ ___|${NC}"
    echo -e "${CYAN} | | | |  _| | | | | |_) | | |  _  / _ \ | |\/| || ||  \| | |  _ ${NC}"
    echo -e "${CYAN} | |_| | |___| |_| |  __/  | |_| |/ ___ \| |  | || || |\  | |_| |${NC}"
    echo -e "${CYAN} |____/|_____|\___/|_|      \____/_/   \_\_|  |_|___|_| \_|\____|${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""
    echo -e "${YELLOW}👉 CHOOSE OPERATING SYSTEM & TERMINAL ACCESS:${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Create & Boot ${GREEN}Ubuntu Linux 22.04${NC} VPS Instance"
    echo -e "  ${CYAN}[2]${NC} Create & Boot ${BLUE}Windows 11 Pro${NC} Virtual Environment"
    echo -e "  ${CYAN}[3]${NC} Restart Existing Active Instance"
    echo -e "  ${CYAN}[4]${NC} Wipe Environment & Clean Caches"
    echo -e "  ${CYAN}[5]${NC} Exit Dashboard"
    echo ""
    echo -e "${RED}==========================================================${NC}"
    echo -ne "${WHITE}🔹 Enter Choice [1-5]: ${NC}"
    read CHOICE
    
    case $CHOICE in
        1) create_ubuntu ;;
        2) create_windows ;;
        3) restart_vps ;;
        4) clean_vps ;;
        5) exit 0 ;;
        *) echo -e "${RED}❌ Invalid Choice! Please select 1-5.${NC}"; sleep 2; show_menu ;;
    esac
}

# BASIC INPUTS COLLECTOR FUNCTION
get_specs() {
    echo -ne "${BLUE}🔹 Enter RAM Size in GB (e.g., 4, 8, 16, 32): ${NC}"
    read RAM_GB
    echo -ne "${BLUE}🔹 Enter CPU Cores (e.g., 2, 4, 8): ${NC}"
    read CPU_CORES
    
    echo ""
    echo -e "${YELLOW}⏳ Preparing QEMU Core Elements... Please wait.${NC}"
    $SUDO_CMD apt-get update -y > /dev/null 2>&1
    $SUDO_CMD apt-get install -y qemu-system-x86 qemu-utils wget cloud-image-utils > /dev/null 2>&1
}

# OPTION 1: UBUNTU VPS ARCHITECTURE
create_ubuntu() {
    clear
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${WHITE}🐧 UBUNTU LINUX ENVIRONMENT SPECIFICATIONS${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    get_specs
    
    echo -ne "${BLUE}🔹 Enter Disk Space to ADD in GB (e.g., 20): ${NC}"
    read DISK_ADD
    echo -ne "${BLUE}🔹 Create Username: ${NC}"
    read USER_NAME
    USER_NAME=${USER_NAME:-ubuntu}
    echo -ne "${BLUE}🔹 Create Password: ${NC}"
    read USER_PASS
    USER_PASS=${USER_PASS:-1234}

    if [ ! -f "ubuntu22.qcow2" ]; then
        echo -e "${YELLOW}📥 Downloading Ubuntu 22.04 Server Cloud Image...${NC}"
        wget -q --show-progress https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O ubuntu22.qcow2
    fi

    loading_bar "Generating Cloud-Init Matrix"
    cat <<EOF > user-data
#cloud-config
ssh_pwauth: True
chpasswd:
  list: |
    ${USER_NAME}:${USER_PASS}
  expire: False
EOF
    cloud-localds seed.img user-data > /dev/null 2>&1
    qemu-img resize ubuntu22.qcow2 +${DISK_ADD}G > /dev/null 2>&1
    
    # Save system mode
    echo "OS_MODE=ubuntu" > .vps_env
    echo "RAM_GB=$RAM_GB" >> .vps_env
    echo "CPU_CORES=$CPU_CORES" >> .vps_env
    echo "USER_NAME=$USER_NAME" >> .vps_env
    echo "USER_PASS=$USER_PASS" >> .vps_env
    
    boot_ubuntu
}

boot_ubuntu() {
    clear
    echo -e "${GREEN}==========================================================${NC}"
    type_effect "👹 UBUNTU MATRIX ONLINE! LINUX SERVER BOOTING!" 0.03
    echo -e "${GREEN}==========================================================${NC}"
    echo ""
    echo -e "${WHITE}👤 Username : ${CYAN}${USER_NAME:-ubuntu}${NC}"
    echo -e "${WHITE}🔑 Password : ${CYAN}${USER_PASS:-1234}${NC}"
    echo -e "${WHITE}⚙️  Resources: ${CYAN}${RAM_GB:-8}GB RAM | ${CPU_CORES:-4} Cores${NC}"
    echo -e "${WHITE}🚀 SSH Connection Port: ${CYAN}2223${NC}"
    echo -e "${WHITE}👉 Login Command       : ${YELLOW}ssh ${USER_NAME:-ubuntu}@localhost -p 2223${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo ""
    
    qemu-system-x86_64 \
        -m ${RAM_GB:-8}G \
        -smp ${CPU_CORES:-4} \
        -hda ubuntu22.qcow2 \
        -drive file=seed.img,format=raw \
        -nographic \
        -net nic \
        -net user,hostfwd=tcp::2223-:22
}

# OPTION 2: WINDOWS 11 WORKSTATION ARCHITECTURE
create_windows() {
    clear
    echo -e "${BLUE}==========================================================${NC}"
    echo -e "${WHITE}🪟 WINDOWS 11 ENVIRONMENT SPECIFICATIONS${NC}"
    echo -e "${BLUE}==========================================================${NC}"
    get_specs
    
    if [ ! -f "windows11.qcow2" ]; then
        echo -e "${YELLOW}💽 Initializing Virtual Disk for Windows 11...${NC}"
        qemu-img create -f qcow2 windows11.qcow2 40G > /dev/null 2>&1
    fi
    
    if [ ! -f "windows11.iso" ]; then
        echo -e "${RED}❌ [ALERT] Please make sure 'windows11.iso' is present in this directory before boot!${NC}"
        echo -ne "${YELLOW}Press [Enter] to try booting anyway or setup space... ${NC}"
        read
    fi
    
    echo "OS_MODE=windows" > .vps_env
    echo "RAM_GB=$RAM_GB" >> .vps_env
    echo "CPU_CORES=$CPU_CORES" >> .vps_env
    
    boot_windows
}

boot_windows() {
    clear
    echo -e "${BLUE}==========================================================${NC}"
    type_effect "👹 WINDOWS MATRIX SYNCHRONIZED! BOOTING ENVIRONMENT!" 0.03
    echo -e "${BLUE}==========================================================${NC}"
    echo ""
    echo -e "${WHITE}⚙️  Allocated Resources : ${CYAN}${RAM_GB:-8}GB RAM | ${CPU_CORES:-4} Cores${NC}"
    echo -e "${WHITE}🚀 VNC Display Console : ${CYAN}Port 5900 (Use VNC Viewer to connect)${NC}"
    echo -e "${WHITE}🚀 RDP Windows Port    : ${CYAN}Port 3389 (Forwarded dynamically)${NC}"
    echo -e "${BLUE}==========================================================${NC}"
    echo ""
    
    # Windows virtualization console command base
    qemu-system-x86_64 \
        -m ${RAM_GB:-8}G \
        -smp ${CPU_CORES:-4} \
        -hda windows11.qcow2 \
        -cdrom windows11.iso \
        -vnc :0 \
        -net nic,model=e1000 \
        -net user,hostfwd=tcp::3389-:3389
}

# OPTION 3: RESTART MANAGER BASED ON PREVIOUS CACHE
restart_vps() {
    if [ -f ".vps_env" ]; then
        source .vps_env
        if [ "$OS_MODE" == "ubuntu" ]; then
            boot_ubuntu
        elif [ "$OS_MODE" == "windows" ]; then
            boot_windows
        fi
    else
        echo -e "${RED}❌ No existing architecture configuration found. Select Option 1 or 2 first!${NC}"
        sleep 3
        show_menu
    fi
}

# OPTION 4: WIPE ALL STORAGE FRESH
clean_vps() {
    echo -e "${RED}⚠️ Erasing all system drives, setups and OS storage blocks...${NC}"
    rm -rf user-data seed.img ubuntu22.qcow2 windows11.qcow2 .vps_env
    sleep 1
    echo -e "${GREEN}✅ Workspace successfully wiped fresh!${NC}"
    sleep 2
    show_menu
}

# INITIATE AUTOMATION TRIGGER
show_menu
