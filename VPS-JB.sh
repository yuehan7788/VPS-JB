#!/bin/bash

# 作者信息
author="Your Name"
version="1.0.0"

# 颜色定义
red='\e[31m'
yellow='\e[33m'
gray='\e[90m'
green='\e[92m'
blue='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

# 颜色输出函数
_red() { echo -e ${red}$@${none}; }
_blue() { echo -e ${blue}$@${none}; }
_cyan() { echo -e ${cyan}$@${none}; }
_green() { echo -e ${green}$@${none}; }
_yellow() { echo -e ${yellow}$@${none}; }
_magenta() { echo -e ${magenta}$@${none}; }
_red_bg() { echo -e "\e[41m$@${none}"; }

# 错误和警告提示
is_err=$(_red_bg 错误!)
is_warn=$(_red_bg 警告!)

# 错误处理函数
err() {
    echo -e "\n$is_err $@\n" && exit 1
}

warn() {
    echo -e "\n$is_warn $@\n"
}

# 检查root权限
[[ $EUID != 0 ]] && err "当前非 ${yellow}ROOT用户${none}，请使用root权限运行此脚本"

# 显示菜单
show_menu() {
    clear
    echo -e "${cyan}========================================${none}"
    echo -e "${green}        一键安装脚本合集 v$version${none}"
    echo -e "${cyan}========================================${none}"
    echo -e "${yellow}1.${none} 安装 Xray"
    echo -e "${yellow}2.${none} 安装 V2ray"
    echo -e "${yellow}3.${none} 安装 Trojan"
    echo -e "${yellow}4.${none} 安装 Shadowsocks"
    echo -e "${yellow}5.${none} 安装 WireGuard"
    echo -e "${yellow}6.${none} 安装 Docker"
    echo -e "${yellow}7.${none} 安装 Nginx"
    echo -e "${yellow}8.${none} 安装 Node.js"
    echo -e "${yellow}9.${none} 安装 Python"
    echo -e "${yellow}0.${none} 退出"
    echo -e "${cyan}========================================${none}"
    echo -n "请输入选项 [0-9]: "
}

# 执行安装命令
run_install() {
    local install_cmd=$1
    _yellow "正在执行安装命令..."
    bash <(wget -qO- -o- $install_cmd)
}

# 主函数
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                run_install "https://github.com/233boy/Xray/raw/main/install.sh"
                ;;
            2)
                run_install "https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh"
                ;;
            3)
                run_install "https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/install.sh"
                ;;
            4)
                run_install "https://raw.githubusercontent.com/shadowsocks/shadowsocks-libev/master/install.sh"
                ;;
            5)
                run_install "https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh"
                ;;
            6)
                run_install "https://get.docker.com"
                ;;
            7)
                run_install "https://raw.githubusercontent.com/nginx/nginx/master/auto/install"
                ;;
            8)
                run_install "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
                ;;
            9)
                run_install "https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer"
                ;;
            0)
                _green "感谢使用，再见！"
                exit 0
                ;;
            *)
                _red "无效的选项，请重新选择"
                ;;
        esac
        
        echo
        read -p "按回车键继续..."
    done
}

# 启动脚本
main 