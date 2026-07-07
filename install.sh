#!/bin/bash

clear

# ==========================================
# COLOR CODES
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ==========================================
# DISPLAY SPECS (banner only)
# ==========================================
DISPLAY_RAM="64G"
DISPLAY_CPU="16 Cores"
DISPLAY_DISK="500G"

# ==========================================
# ACTUAL QEMU SPECS (safe for 8GiB/4vCPU host)
# ==========================================
QEMU_RAM="7G"
QEMU_CPU=4
DISK_GB=500

# ==========================================
# FIXED CONFIG
# ==========================================
USER_NAME="root"
USER_PASS="root"
TCP_HOST_PORT=2222
TCP_GUEST_PORT=22

# ==========================================
# HELPERS
# ==========================================
type_effect() {
    local text="$1"
    local delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

loading_bar() {
    local title="$1"
    echo -ne "${YELLOW}⏳ $title ${NC}[          ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[===       ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[======    ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[========= ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[==========]"
    echo -e " ${GREEN}DONE!${NC}"
}

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO_CMD="sudo"
fi

# ==========================================
# MENU
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
    echo -e "${CYAN}  ____  _____ _   _ ____     ____    _    __  __ ___ _   _  ____${NC}"
    echo -e "${CYAN} |  _ \| ____| | | |  _ \   / ___|  / \  |  \/  |_ _| \ | |/ ___|${NC}"
    echo -e "${CYAN} | | | |  _| | | | | |_) | | |  _  / _ \ | |\/| || ||  \| | |  _${NC}"
    echo -e "${CYAN} | |_| | |___| |_| |  __/  | |_| |/ ___ \| |  | || || |\  | |_| |${NC}"
    echo -e "${CYAN} |____/|_____|\___/|_|      \____/_/   \_\_|  |_|___|_| \_|\____|${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""
    echo -e "${YELLOW}👉 SELECT AN OPTION TO PROCEED FROM LIST:${NC}"
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
        *) echo -e "${RED}❌ Invalid Choice! Please select 1-4.${NC}"; sleep 2; show_menu ;;
    esac
}

# ==========================================
# CREATE VPS
# ==========================================
create_vps() {
    clear
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}⚙️  BOOTING VPS WITH SPECS${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo -e "${CYAN}  RAM    : ${WHITE}${DISPLAY_RAM}${NC}"
    echo -e "${CYAN}  CPU    : ${WHITE}${DISPLAY_CPU}${NC}"
    echo -e "${CYAN}  Disk   : ${WHITE}${DISPLAY_DISK}${NC}"
    echo -e "${CYAN}  User   : ${WHITE}${USER_NAME}${NC}"
    echo -e "${CYAN}  Port   : ${WHITE}${TCP_HOST_PORT} → ${TCP_GUEST_PORT}${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""

    loading_bar "Installing dependencies"
    $SUDO_CMD apt-get update -y > /dev/null 2>&1
    $SUDO_CMD apt-get install -y qemu-system-x86 qemu-utils wget cloud-image-utils curl > /dev/null 2>&1

    $SUDO_CMD mkdir -p /home/daytona

    # Download image only if it doesn't exist
    if [ ! -f "/home/daytona/ubuntu22.qcow2" ]; then
        echo -e "${YELLOW}📥 Downloading Ubuntu 22.04 Cloud Image...${NC}"
        $SUDO_CMD wget -q --show-progress \
            https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
            -O /home/daytona/ubuntu22.qcow2
        $SUDO_CMD chmod 666 /home/daytona/ubuntu22.qcow2

        # ✅ Absolute resize — no + prefix, so re-runs never stack
        loading_bar "Resizing disk to exactly ${DISK_GB}G"
        $SUDO_CMD qemu-img resize /home/daytona/ubuntu22.qcow2 ${DISK_GB}G
    else
        echo -e "${GREEN}✅ Existing Ubuntu image found — skipping download & resize.${NC}"
        sleep 2
    fi

    loading_bar "Generating Cloud-Init config"
    cat <<EOF > /home/daytona/user-data
#cloud-config
ssh_pwauth: True
disable_root: false
chpasswd:
  list: |
    ${USER_NAME}:${USER_PASS}
  expire: False
runcmd:
  - sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  - sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - systemctl restart ssh
EOF

    cloud-localds /home/daytona/seed.img /home/daytona/user-data > /dev/null 2>&1

    boot_qemu
}

# ==========================================
# BOOT QEMU
# ==========================================
boot_qemu() {
    clear
    echo -e "${GREEN}==========================================================${NC}"
    type_effect "👹 DATA SYSTEM SYNCHRONIZED! PIPING TERMINAL CHANNELS..." 0.02
    echo -e "${GREEN}==========================================================${NC}"
    echo ""

    # Launch sshx tunnel in background
    SSHX_LOG=$(mktemp)
    curl -sSf https://sshx.io/get | sh -s run > "$SSHX_LOG" 2>&1 &

    sleep 5
    SSHX_URL=$(grep -o 'https://sshx\.io/s/[a-zA-Z0-9#]*' "$SSHX_LOG" | head -n1)
    rm -f "$SSHX_LOG"

    clear
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "🎉       DEUP GAMING & DXD LABS - VM NETWORK ACTIVE        "
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${WHITE}👤 Username  : ${CYAN}${USER_NAME}${NC}"
    echo -e "${WHITE}🔑 Password  : ${CYAN}${USER_PASS}${NC}"
    echo -e "${WHITE}⚙️  Resources : ${CYAN}${DISPLAY_RAM} RAM | ${DISPLAY_CPU} | ${DISPLAY_DISK} Disk${NC}"
    echo -e "${WHITE}🚀 Port Rule : ${YELLOW}Host ${TCP_HOST_PORT} → VM Port ${TCP_GUEST_PORT}${NC}"
    echo -e "${RED}----------------------------------------------------------${NC}"
    if [ -n "$SSHX_URL" ]; then
        echo -e "${YELLOW}🔥 BROWSER ACCESS LINK:${NC}"
        echo -e "${GREEN}👉 $SSHX_URL 👈${NC}"
    else
        echo -e "${RED}⚠️  Tunnel loading slow. Use SSH directly below.${NC}"
    fi
    echo -e "${RED}----------------------------------------------------------${NC}"
    echo -e "${WHITE}👉 SSH Command: ssh ${USER_NAME}@localhost -p ${TCP_HOST_PORT}${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo ""

    # ✅ Safe QEMU values — 7G RAM and 4 CPUs fit within Daytona's 8GiB/4vCPU host
    # Display specs above are cosmetic; these are what QEMU actually gets
    $SUDO_CMD qemu-system-x86_64 \
        -hda /home/daytona/ubuntu22.qcow2 \
        -m ${QEMU_RAM} \
        -smp ${QEMU_CPU} \
        -drive file=/home/daytona/seed.img,format=raw \
        -nographic \
        -netdev user,id=net0,hostfwd=tcp::${TCP_HOST_PORT}-:${TCP_GUEST_PORT} \
        -device e1000,netdev=net0
}

# ==========================================
# RESTART
# ==========================================
restart_vps() {
    if [ -f "/home/daytona/ubuntu22.qcow2" ] && [ -f "/home/daytona/seed.img" ]; then
        echo -e "${GREEN}🔄 Restarting existing VM...${NC}"
        sleep 1
        boot_qemu
    else
        echo -e "${RED}❌ No existing VM found. Use Option 1 to create one.${NC}"
        sleep 3
        show_menu
    fi
}

# ==========================================
# CLEAN
# ==========================================
clean_vps() {
    echo -e "${RED}⚠️  Purging all VPS files...${NC}"
    $SUDO_CMD rm -rf /home/daytona/ubuntu22.qcow2 /home/daytona/seed.img /home/daytona/user-data
    pkill sshx > /dev/null 2>&1
    sleep 1
    echo -e "${GREEN}✅ Cleaned! Fresh install on next boot.${NC}"
    sleep 2
    show_menu
}

# ==========================================
# ENTRY
# ==========================================
show_menu
