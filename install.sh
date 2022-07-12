#!/bin/sh
verlte() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
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

echo $OS - $OSVER

install_packet() {
    echo "========== [$OS - $OSVER] Package install $@ =========="
    for p in $@; do
        echo "Installing $p"
        if ! command -v $p >/dev/null; then
            if [ $OS = "debian" ]; then
                apt-get install -y "$p"
            elif [ $OS = "redhat" ]; then
                yum install -y "$p"
            elif [ $OS = "alpine" ]; then
                apk add --no-cache "$p"
            else
                echo "No support for $OS"
            fi
        else
            echo "Package $p already installed"
        fi
    done
}

check_zsh_version() {
    if [ -z "$ZSH_VERSION" ]; then
        ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    fi
    if [ $OS = "redhat" ] && [ $OSVER -lt 8 ] && ! verlte 5.1 $ZSH_VERSION; then
        rpm -iUvh http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm
    fi
}

install_packet zsh curl git vim
check_zsh_version

export TERM=xterm-256color
export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

if [ ! -d "$ZSH_CUSTOM" ]; then echo 'Y' | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; fi
if [ ! -d "$ZSH_CUSTOM"/plugins/zsh-autosuggestions ]; then git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions; fi
if [ ! -d "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting ]; then git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting; fi
if [ ! -d "$ZSH_CUSTOM"/themes/powerlevel10k ]; then git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}"/themes/powerlevel10k; fi
if [ -f $HOME/.zshrc ]; then
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting extract copypath copyfile copybuffer dirhistory)/g' ~/.zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >>~/.zshrc
curl -Lo $HOME/.p10k.zsh https://gist.githubusercontent.com/nhahv/5cf111134fcc812b5bb96958d055c94d/raw/fc829bcc554fadc4332b857793537027fe92a220/p10k-rainbow-slanted.zsh
zsh
