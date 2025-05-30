#!/bin/bash

# 作者信息
author="Yu G"
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

# 检查别名冲突
check_alias_conflict() {
    local new_alias=$1
    if alias $new_alias 2>/dev/null; then
        _yellow "警告: 别名 '$new_alias' 已存在"
        read -p "是否覆盖现有别名？(y/n): " choice
        if [[ $choice != "y" && $choice != "Y" ]]; then
            return 1
        fi
    fi
    return 0
}

# 设置别名
setup_alias() {
    local system_script="/usr/local/bin/VPS-JB.sh"
    local github_url="https://raw.githubusercontent.com/yuehan7788/VPS-JB/refs/heads/main/VPS-JB.sh"
    
    # 检查脚本是否已经安装
    if [[ ! -f "$system_script" ]]; then
        _yellow "首次安装，正在从 GitHub 下载脚本..."
        
        # 使用 wget 下载脚本，保持原始文件名
        wget -qO "$system_script" "$github_url"
        if [[ ! -f "$system_script" ]]; then
            _red "下载脚本失败"
            return 1
        fi
        
        # 设置权限
        chmod +x "$system_script"
        
        # 验证文件大小
        local target_size=$(stat -c%s "$system_script" 2>/dev/null || stat -f%z "$system_script" 2>/dev/null)
        _yellow "下载的文件大小: $target_size 字节"
        
        if [[ ! -s "$system_script" ]]; then
            _red "下载的文件大小为0"
            return 1
        fi
    else
        _green "检测到脚本已安装，将使用本地文件"
    fi
    
    # 创建全局别名文件
    cat > "/etc/profile.d/vps-jb.sh" << EOF
#!/bin/bash

# VPS-JB 脚本别名
alias y='bash $system_script'
EOF
    
    # 设置权限
    chmod +x "/etc/profile.d/vps-jb.sh"
    
    # 立即加载
    source "/etc/profile.d/vps-jb.sh"
    
    # 验证别名是否设置成功
    if alias y >/dev/null 2>&1; then
        _green "别名设置成功！"
        _green "现在您可以使用以下命令来启动脚本："
        _green "- y"
        
        # 显示当前别名设置
        _yellow "当前别名设置："
        alias y
    else
        _red "别名设置失败，请手动运行以下命令："
        _yellow "echo 'alias y=\"bash $system_script\"' > /etc/profile.d/vps-jb.sh"
        _yellow "chmod +x /etc/profile.d/vps-jb.sh"
        _yellow "source /etc/profile.d/vps-jb.sh"
    fi
}

# 显示菜单
show_menu() {
    clear
    echo -e "${cyan}========================================${none}"
    echo -e "${green}        一键安装脚本合集 v$version${none}"
    echo -e "${cyan}========================================${none}"
    echo -e "${yellow}1.${none} 安装 Xray(233boy急速)"
    echo -e "${yellow}2.${none} 安装 八合一键脚本mack-a&(歇斯底里)"
    echo -e "${yellow}3.${none} 安装 FranzKafkaYu/x-ui"
    echo -e "${yellow}4.${none} 安装 kejilong工具"
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
                run_install "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh"
                ;;
            3)
                run_install "https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh"
                ;;
            4)
                run_install "kejilion.sh"
                ;;
            0)
                _green "感谢使用，再见！"
                # 在退出前自动执行 source 命令
                exec bash -c "source /etc/profile.d/vps-jb.sh; exec bash"
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
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 只在直接运行脚本时设置别名
    setup_alias
    main
fi 
