#!/bin/sh
verlte() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}
export TERM=xterm-256color
# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

function danger {
    printf "${RED}$@${NC}\n"
}

function success {
    printf "${GREEN}$@${NC}\n"
}

function warning {
    printf "${YELLOW}$@${NC}\n"
}

OS=
OSVER=$(cat /etc/os-release | grep VERSION_ID | cut -d'=' -f2 | tr -d '"' | cut -d'.' -f1)

if command -v apt-get >/dev/null; then
    OS="debian"
elif command -v yum >/dev/null; then
    OS="redhat"
elif command -v apk >/dev/null; then
    OS="alpine"
else
    echo "Unsupported OS"
    exit 1
fi

install_packet() {
    echo "========== [${OS^^} - $OSVER] Package install [$@] =========="
    for p in $@; do
        echo "Installing $p"
        if ! command -v $p >/dev/null; then
            if [ $OS = "debian" ]; then
                apt-get install -y "$p" >/dev/null
            elif [ $OS = "redhat" ]; then
                yum install -y "$p" >/dev/null
            elif [ $OS = "alpine" ]; then
                apk add --no-cache "$p" >/dev/null
            else
                echo "No support for $OS"
            fi
        else
            echo "Package $p already installed"
        fi
    done
}

check_packets() {
    PKGS=()
    for p in $@; do
        if ! command -v $p >/dev/null; then
            PKGS+=($p)
        fi
    done
    IFS=' '
    echo "${PKGS[*]}"
    if [ ${#PKGS[@]} -gt 0 ]; then
        exit 1
    fi
}

check_zsh_version() {
    if [ -z "$ZSH_VERSION" ]; then
        ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    fi
    if [ $OS = "redhat" ] && [ $OSVER -lt 8 ] && ! verlte 5.1 $ZSH_VERSION; then
        rpm -iUvh http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm
    fi
    success "ZSH_VERSION: [$ZSH_VERSION] \t OS: [${OS^^}] \t OSVER: [$OSVER]"
}

PACKAGES="zsh curl git vim"
if [ $(whoami 2>&1) = "root" ] || sudo -nv 2>/dev/null; then
    echo "========== RUN AS ROOT =========="
    PKGS=$(check_packets $PACKAGES)
    if [ ! "$PKGS" = "" ]; then
        echo "Installing missing packages: [${PKGS[@]}]"
        install_packet $PKGS 2>/dev/null
    fi

fi
# Check packages agains
warning "========== RUN AS USER $(whoami) =========="
PKGS=$(check_packets $PACKAGES)
if [ ! "$PKGS" = "" ]; then
    danger "🔴 Required packages [$PKGS] not founds! Please run as root or install missing packages manually."
    exit 1
fi

check_zsh_version

export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

if [ ! -d "$ZSH_CUSTOM" ]; then echo 'Y' | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>&1 >/dev/null; fi
if [ ! -d "$ZSH_CUSTOM"/plugins/zsh-autosuggestions ]; then git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions >/dev/null; fi
if [ ! -d "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting ]; then git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting >/dev/null; fi
if [ ! -d "$ZSH_CUSTOM"/themes/powerlevel10k ]; then git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}"/themes/powerlevel10k >/dev/null; fi
if [ -f $HOME/.zshrc ]; then
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting extract copypath copyfile copybuffer dirhistory)/g' ~/.zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >>~/.zshrc
curl -s -Lo $HOME/.p10k.zsh "https://raw.githubusercontent.com/nhahv/oh-my-zsh-installer/main/.p10k.zsh"
echo typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true >>~/.zshrc
echo export TERM=xterm-256color >>~/.zshrc
success "Success Install ZSH"
zsh
