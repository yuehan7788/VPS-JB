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
    echo -e "${yellow}5.${none} 卸载脚本"
    echo -e "${yellow}6.${none} 脚本信息"
    echo -e "${yellow}0.${none} 退出"
    echo -e "${cyan}========================================${none}"
    echo -n "请输入选项 [0-9]: "
}

# 显示脚本信息
show_script_info() {
    clear
    echo -e "${cyan}========================================${none}"
    echo -e "${green}        脚本信息${none}"
    echo -e "${cyan}========================================${none}"
    echo -e "${yellow}脚本版本：${none} $version"
    echo -e "${yellow}脚本安装路径：${none} /usr/local/bin/VPS-JB.sh"
    echo -e "${yellow}别名配置文件：${none} /etc/profile.d/vps-jb-bieming.sh"
    echo -e "${yellow}软链接路径：${none} /usr/local/bin/vps-jb"
    echo -e "${yellow}快捷命令：${none} y 或 vps-jb"
    echo -e "${cyan}========================================${none}"
}

# 执行安装命令
run_install() {
    local install_cmd=$1
    _yellow "正在执行安装命令..."
    
    # 检查命令是否有效
    if [[ -z "$install_cmd" ]]; then
        _red "安装命令无效"
        return 1
    fi
    
    # 直接执行安装命令
    bash <(curl -sL "$install_cmd")
    
    # 检查安装结果
    if [[ $? -eq 0 ]]; then
        _green "安装命令执行完成"
    else
        _red "安装命令执行失败"
    fi
}

# 卸载脚本
uninstall_script() {
    _yellow "开始卸载脚本..."
    
    # 定义要删除的文件
    local files_to_remove=(
        "/usr/local/bin/VPS-JB.sh"
        "/usr/local/bin/vps-jb"
        "/etc/profile.d/vps-jb-bieming.sh"
    )
    
    # 删除文件
    for file in "${files_to_remove[@]}"; do
        if [[ -f "$file" ]] || [[ -L "$file" ]]; then
            rm -f "$file"
            _green "已删除: $file"
        fi
    done
    
    # 从 .bashrc 中移除别名
    if [[ -f ~/.bashrc ]]; then
        sed -i '/alias y=.*VPS-JB.sh/d' ~/.bashrc
        _green "已从 .bashrc 中移除别名"
    fi
    
    # 从 .bash_profile 中移除别名
    if [[ -f ~/.bash_profile ]]; then
        sed -i '/alias y=.*VPS-JB.sh/d' ~/.bash_profile
        _green "已从 .bash_profile 中移除别名"
    fi
    
    # 重新加载配置
    source ~/.bashrc
    
    _green "脚本卸载完成！"
}

# 设置别名
setup_alias() {
    local system_script="/usr/local/bin/VPS-JB.sh"
    local alias_config="/etc/profile.d/vps-jb-bieming.sh"
    local github_url="https://raw.githubusercontent.com/yuehan7788/VPS-JB/refs/heads/yuehan7788-patch-1/VPS-JB.sh"
    local show_info=$1  # 新增参数控制是否显示详细信息
    local is_first_install=0
    
    # 检查脚本是否已经安装
    if [[ ! -f "$system_script" ]] || [[ ! -s "$system_script" ]]; then
        is_first_install=1
        _yellow "首次安装,正在从GitHub下载脚本..."
        
        # 使用 wget 下载脚本，添加了超时设置（1秒） 添加了重试机制（3次）
        wget --timeout=1 --tries=3 --show-progress -qO "$system_script" "$github_url"
        
        # 验证下载是否成功
        if [[ ! -f "$system_script" ]] || [[ ! -s "$system_script" ]]; then
            _red "下载脚本失败，请检查网络连接或重试"
            return 1
        fi
        
        # 显示下载文件大小
        local file_size=$(stat -c%s "$system_script" 2>/dev/null || stat -f%z "$system_script" 2>/dev/null)
        _green "下载完成，文件大小: ${file_size} 字节"
    elif [[ "$show_info" != "true" ]]; then
        return 0  # 如果不是首次安装且不需要显示信息，直接返回
    else
        _green "检测到脚本已安装，将使用本地文件"
    fi
    
    # 确保脚本有执行权限
    chmod +x "$system_script"
    
    # 创建软链接（使用完整路径）
    local softlink="/usr/local/bin/vps-jb"
    if [[ -L "$softlink" ]]; then
        rm -f "$softlink"
    fi
    ln -sf "$system_script" "$softlink"
    chmod +x "$softlink"
    
    # 验证软链接是否创建成功
    if [[ ! -L "$softlink" ]]; then
        _yellow "警告: 软链接创建失败，但不会影响脚本使用"
    fi
    
    # 设置别名到所有可能的配置文件中
    local alias_cmd="alias y='bash $system_script'"
    
    # 添加到 .bashrc
    if ! grep -q "$alias_cmd" ~/.bashrc; then
        echo "$alias_cmd" >> ~/.bashrc
    fi
    
    # 添加到 .bash_profile
    if [[ -f ~/.bash_profile ]] && ! grep -q "$alias_cmd" ~/.bash_profile; then
        echo "$alias_cmd" >> ~/.bash_profile
    fi
    
    # 添加到 /etc/profile.d/
    echo "$alias_cmd" > "$alias_config"
    chmod +x "$alias_config"
    
    # 立即生效
    source ~/.bashrc
    
    # 在首次安装或需要显示信息时显示详细信息
    if [[ $is_first_install -eq 1 ]] || [[ "$show_info" == "true" ]]; then
        # 验证别名是否设置成功
        if alias y >/dev/null 2>&1; then
            _green "菜单快捷键<y>、<vps-jb>设置成功！"
            _green "现在您可以使用以下命令来启动脚本："
            _green "- <y> 或 <vps-jb>"
            
            # 显示当前别名设置
            _yellow "当前别名设置："
            alias y
            
            # 显示脚本文件信息
            _yellow "脚本文件信息："
            ls -l "$system_script"
            _yellow "别名配置文件："
            ls -l "$alias_config"
            _yellow "软链接信息："
            ls -l "$softlink"
        else
            _red "别名设置失败，请手动运行以下命令："
            _yellow "echo 'alias y=\"bash $system_script\"' >> ~/.bashrc"
            _yellow "source ~/.bashrc"
        fi
    fi
}

# 主函数
main() {
    # 检查是否是首次安装
    local is_first_run=0
    if [[ ! -f "/usr/local/bin/VPS-JB.sh" ]]; then
        is_first_run=1
        setup_alias "true"  # 首次安装时显示详细信息
    else
        setup_alias "false"  # 非首次安装时不显示详细信息
    fi
    
    # 直接显示菜单
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
            5)
                uninstall_script
                _green "脚本已卸载，程序将退出"
                exit 0
                ;;
            6)
                show_script_info
                ;;
            0)
                _green "感谢使用，再见！"
                # 在退出前自动执行 source 命令
                exec bash -c "source /etc/profile.d/vps-jb-bieming.sh; exec bash"
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
