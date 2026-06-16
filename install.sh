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
# MAIN DASHBOARD MENU (JISHNU TECH STYLE)
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
    echo -e "${YELLOW}👉 SELECT AN OPTION TO PROCEED:${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Create & Boot New Ubuntu VPS Instance"
    echo -e "  ${CYAN}[2]${NC} Restart Existing VPS Instance"
    echo -e "  ${CYAN}[3]${NC} Remove/Clean VPS Cache Files"
    echo -e "  ${CYAN}[4]${NC} Exit Dashboard"
    echo ""
    echo -e "${RED}==========================================================${NC}"
    echo -ne "${WHITE}🔹 Enter Choice [1-4]: ${NC}"
    read CHOICE
    
    case $CHOICE in
        1) create_vps ;;
        2) restart_vps ;;
        3) clean_vps ;;
        4) exit 0 ;;
        *) echo -e "${RED}❌ Invalid Choice!${NC}"; sleep 1; show_menu ;;
    esac
}

# CONFIGURATION AND SPECIFICATION INPUTS
create_vps() {
    clear
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}⚙️  CONFIGURE YOUR VIRTUAL MACHINE SPECIFICATIONS${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""
    
    echo -ne "${BLUE}🔹 Enter RAM Size in GB (e.g., 4, 8, 16, 32): ${NC}"
    read RAM_GB
    echo -ne "${BLUE}🔹 Enter CPU Cores (e.g., 2, 4, 8): ${NC}"
    read CPU_CORES
    echo -ne "${BLUE}🔹 Enter Disk Space to ADD in GB (e.g., 10, 20): ${NC}"
    read DISK_ADD
    echo -ne "${BLUE}🔹 Create Username (Default: ubuntu): ${NC}"
    read USER_NAME
    USER_NAME=${USER_NAME:-ubuntu}
    echo -ne "${BLUE}🔹 Create Password (Default: 1234): ${NC}"
    read USER_PASS
    USER_PASS=${USER_PASS:-1234}
    
    echo ""
    echo -e "${YELLOW}⏳ Background dependencies install ho rahi hain... Please wait.${NC}"
    echo ""
    
    $SUDO_CMD apt-get update -y > /dev/null 2>&1
    $SUDO_CMD apt-get install -y qemu-system-x86 qemu-utils wget cloud-image-utils > /dev/null 2>&1
    
    # Check and download Ubuntu Image
    if [ ! -f "ubuntu22.qcow2" ]; then
        echo -e "${YELLOW}📥 Downloading Ubuntu 22.04 Cloud Image...${NC}"
        wget -q --show-progress https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O ubuntu22.qcow2
    else
        echo -e "${GREEN}✅ Existing Ubuntu Image Cache Detected.${NC}"
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
    
    loading_bar "Expanding Server Hard Disk Allocation"
    qemu-img resize ubuntu22.qcow2 +${DISK_ADD}G > /dev/null 2>&1
    
    # Environment variables save kar rhe hain taaki restart ke waqt kaam aayein
    echo "RAM_GB=$RAM_GB" > .vps_env
    echo "CPU_CORES=$CPU_CORES" >> .vps_env
    echo "USER_NAME=$USER_NAME" >> .vps_env
    echo "USER_PASS=$USER_PASS" >> .vps_env
    
    boot_qemu
}

# SYSTEM EXECUTION & BOOT ENGINE
boot_qemu() {
    # If environment file exists, load variables
    if [ -f ".vps_env" ]; then
        source .vps_env
    fi

    clear
    echo -e "${GREEN}==========================================================${NC}"
    type_effect "👹 CHARACTER MATRIX SYNCHRONIZED! VPS BOOTING NOW!" 0.03
    echo -e "${GREEN}==========================================================${NC}"
    echo ""
    echo -e "${WHITE}👤 Username : ${CYAN}${USER_NAME:-ubuntu}${NC}"
    echo -e "${WHITE}🔑 Password : ${CYAN}${USER_PASS:-1234}${NC}"
    echo -e "${WHITE}⚙️  Resources: ${CYAN}${RAM_GB:-8}GB RAM | ${CPU_CORES:-4} Cores${NC}"
    echo -e "${WHITE}🚀 Connection Port: ${CYAN}2223${NC}"
    echo -e "${WHITE}👉 Login Command  : ${YELLOW}ssh ${USER_NAME:-ubuntu}@localhost -p 2223${NC}"
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

restart_vps() {
    if [ -f "ubuntu22.qcow2" ] && [ -f "seed.img" ]; then
        echo -e "${GREEN}🔄 Restarting existing server architecture...${NC}"
        sleep 1
        boot_qemu
    else
        echo -e "${RED}❌ No existing system installation found! Please select Option 1 first.${NC}"
        sleep 2
        show_menu
    fi
}

clean_vps() {
    echo -e "${RED}⚠️ Cleaning up workspace environment and caches...${NC}"
    rm -rf user-data seed.img ubuntu22.qcow2 .vps_env
    sleep 1
    echo -e "${GREEN}✅ Workspace is completely wiped fresh!${NC}"
    sleep 2
    show_menu
}

# TRIGGER CODE BASE
show_menu
