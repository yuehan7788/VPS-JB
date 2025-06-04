#!/bin/bash

# 作者信息
author="Yu G"
version="1.1.6"

# 颜色定义
red='\e[31m'
yellow='\e[33m'
gray='\e[90m'
green='\e[92m'
blue='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

#颜色定义2
echoContent() {
    case $1 in
        "black")    echo -e "\033[30m$2\033[0m" ;; # 黑色
        "red")      echo -e "\033[31m$2\033[0m" ;; # 红色
        "green")    echo -e "\033[32m$2\033[0m" ;; # 绿色
        "yellow")   echo -e "\033[33m$2\033[0m" ;; # 黄色
        "blue")     echo -e "\033[34m$2\033[0m" ;; # 蓝色
        "magenta")  echo -e "\033[35m$2\033[0m" ;; # 品红/紫色
        "cyan")     echo -e "\033[36m$2\033[0m" ;; # 青色
        "white")    echo -e "\033[37m$2\033[0m" ;; # 白色
        "gray")     echo -e "\033[90m$2\033[0m" ;; # 灰色
        "skyBlue")  echo -e "\033[1;36m$2\033[0m" ;; # 天蓝色（高亮青色）
        "lightRed") echo -e "\033[91m$2\033[0m" ;; # 亮红色
        "lightGreen") echo -e "\033[92m$2\033[0m" ;; # 亮绿色
        "lightYellow") echo -e "\033[93m$2\033[0m" ;; # 亮黄色
        "lightBlue") echo -e "\033[94m$2\033[0m" ;; # 亮蓝色
        "lightMagenta") echo -e "\033[95m$2\033[0m" ;; # 亮品红
        "lightCyan") echo -e "\033[96m$2\033[0m" ;; # 亮青色
        *) echo "$2" ;; # 默认无色
    esac
}


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
    echo -e "${yellow}7.${none} 自动安装 mack-a sing-box Hysteria2 "
    echo -e "${yellow}8.${none} 卸载expect工具"
    echo -e "${yellow}9.${none} 一键卸载mack-a sing-box和VPS-JB脚本"
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
    echo -e "${yellow}脚本版本：${none}\t= $version"
    echo -e "${yellow}脚本安装路径：${none}\t= /usr/local/bin/VPS-JB.sh"
    echo -e "${yellow}别名配置文件：${none}\t= /etc/profile.d/vps-jb-bieming.sh"
    echo -e "${yellow}软链接路径：${none}\t= /usr/local/bin/vps-jb"
    echo -e "${yellow}快捷命令：${none}\t= y 或 vps-jb"
    echo -e "${yellow}无响应中断操作：${none}\t= Ctrl+C"
    echo -e "${yellow}Xray(233boy急速)：${none}\t= 命令 xray"
    echo -e "${yellow}八合一键脚本mack-a：${none}\t= (歇斯底里) & 命令 vasma"
    echo -e "${yellow}kejilong工具：${none}\t= 命令 k"
    echo -e "${cyan}========================================${none}"
    show_script_info
    # 显示信息后直接跳转到root命令行
    bash
}

# 执行安装命令
run_install() {
    local install_cmd=$1
    local show_info=$2
    
    _yellow "正在执行安装命令..."
    
    # 检查命令是否有效
    if [[ -z "$install_cmd" ]]; then
        _red "安装命令无效"
        return 1
    fi
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local temp_script="${temp_dir}/install.sh"
    
    _yellow "正在下载安装脚本..."
    # 下载脚本到临时目录
    curl -sL "$install_cmd" -o "$temp_script"
    if [[ $? -ne 0 ]]; then
        _red "下载安装脚本失败"
        rm -rf "$temp_dir"
        return 1
    fi
    
    chmod +x "$temp_script"
    _green "下载完成，开始安装..."
    
    # 执行临时脚本
    bash "$temp_script"
    local install_status=$?
    
    # 清理临时文件
    rm -rf "$temp_dir"
    
    # 检查安装结果
    if [[ $install_status -eq 0 ]] || [[ $install_status -eq 1 ]]; then
        _green "安装命令执行完成"
        # 安装完成后直接退出到root命令行
        bash
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
        "/usr/local/bin/install_scripts"
        "/tmp/setup_zh.sh"
        "/tmp/install.exp"
        "/tmp/continue.exp"
        "/tmp/uninstall.exp"
        "/tmp/mack-a.sh"
    )
    
    # 删除文件
    for file in "${files_to_remove[@]}"; do
        if [[ -f "$file" ]] || [[ -L "$file" ]] || [[ -d "$file" ]]; then
            rm -rf "$file"
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
    
    # 清理环境变量
    unset LANG
    unset LC_ALL
    unset LANGUAGE
    unset DEBIAN_FRONTEND
    
    # 重新加载配置
    source ~/.bashrc
    
    _green "脚本卸载完成！"
    _yellow "请重新打开终端或执行 'exec bash' 使更改生效"
}

# 设置别名
setup_alias() {
    local system_script="/usr/local/bin/VPS-JB.sh"
    local alias_config="/etc/profile.d/vps-jb-bieming.sh"
    local github_url="https://raw.githubusercontent.com/yuehan7788/VPS-JB/refs/heads/yuehan7788-patch-2/VPS-JB.sh"
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
    
    # 在首次安装或需要显示信息时显示详细信息
    if [[ $is_first_install -eq 1 ]] || [[ "$show_info" == "true" ]]; then
        _green "菜单快捷键<y>、<vps-jb>设置成功！"
        _green "现在您可以使用以下命令来启动脚本："
        _green "- <y> 或 <vps-jb>"
        
        # 显示当前别名设置
        _yellow "当前别名设置："
        echo "$alias_cmd"
        
        # 显示脚本文件信息
        _yellow "脚本文件信息："
        ls -l "$system_script"
        _yellow "别名配置文件："
        ls -l "$alias_config"
        _yellow "软链接信息："
        ls -l "$softlink"
        
        _yellow "请执行以下命令使别名生效："
        _yellow "source ~/.bashrc"
    fi
}

# 自动化安装mack-a sing-box
auto_install_macka_singbox() {
    local domain=$1
    local username=$2
    local salt=$3
    local merge_info=$4
    local email=$5
    if [[ -z "$domain" ]]; then
        _red "域名不能为空"
        return 1
    fi

    # 检查并安装expect
    if ! command -v expect &> /dev/null; then
        _yellow "正在安装expect..."
        
        # 检测系统类型并安装
        if command -v apt &> /dev/null; then
            # Debian/Ubuntu系统
            _yellow "检测到Debian/Ubuntu系统，使用apt安装..."
            apt update
            apt install -y expect
        elif command -v dnf &> /dev/null; then
            # Rocky Linux/CentOS 8+/Fedora系统
            _yellow "检测到Rocky Linux/CentOS 8+/Fedora系统，使用dnf安装..."
            dnf install -y expect
        elif command -v yum &> /dev/null; then
            # CentOS 7/RHEL 7系统
            _yellow "检测到CentOS 7/RHEL 7系统，使用yum安装..."
            yum install -y expect
        elif command -v pacman &> /dev/null; then
            # Arch Linux系统
            _yellow "检测到Arch Linux系统，使用pacman安装..."
            pacman -Sy --noconfirm expect
        else
            _red "无法检测系统类型，请手动安装expect"
            return 1
        fi
        
        # 验证安装
        if ! command -v expect &> /dev/null; then
            _red "安装expect失败，请手动安装"
            return 1
        fi
        
        _green "expect安装成功！"
    fi

    # 创建expect脚本
    cat > /tmp/install.exp << EOF
#!/usr/bin/expect -f

# 设置超时时间
set timeout 120

# 设置域名和用户名变量
set domain "$domain"
set username "$username"
set salt "$salt"
set merge_info "$merge_info"

# 启动安装脚本
spawn bash -c "wget -P /root -N --no-check-certificate \"https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh\" && chmod 700 /root/install.sh && /root/install.sh"

# 设置通用输入处理
expect_before {
    timeout {
        # 当超时时，允许用户输入
        expect_user -re "(.*)\n"
        send "$expect_out(1,string)\r"
        exp_continue
    }
    eof { exit }
}

# 第 1 步:处理交互
expect "请选择:"
send "1\r"

expect "请选择:"
send "2\r"

# 第 2 步:使用预先输入的域名
expect "请输入要配置的域名 例: www.v2ray-agent.com ---> "
send "\$domain\r"

# 第 3 步:处理DNS API证书申请
expect -re "是否使用DNS API申请证书.*y/n"
send "n\r"

# 第 4 步:处理默认选项
expect "请选择"
expect "使用默认"
send "\r"

# 第 5 步:处理UUID和用户名
expect "UUID:"
send "\r"

expect "用户名:"
send "\$username\r"

# 第 6 步:处理端口输入
expect "请输入自定义端口"
send "\r"

expect "请输入自定义端口"
send "\r"

# 第 7 步:处理路径
expect "路径:"
send "\r"

# 第 8 步:处理端口输入
expect "请输入自定义端口"
send "\r"

# 第 9 步:处理上次安装记录
expect -re "读取到上次安装记录.*path路径.*y/n"
send "y\r"

# 第 10 步:处理Reality目标域名
expect -re "是否使用 .* 此域名作为Reality目标域名 ？.*y/n"
send "y\r"

# 第 11 步:处理端口输入
expect "请输入自定义端口"
send "\r"

# 第 12 步:处理伪装站点，哪个模式先出现就匹配哪个。
expect {
    -re "检测到安装伪装站点，是否需要重新安装.*y/n" {
        send "y\r"
        exp_continue
    }
    "请输入自定义端口" {
        # 如果直接出现端口输入提示，说明没有检测到伪装站点
        # 直接进入第13步
        send "\r"
    }
}

# 第 13 步:处理端口输入
#expect "请输入自定义端口"
#send "\r"

# 第 14 步:处理Reality目标域名
expect -re "是否使用 .* 此域名作为Reality目标域名 ？.*y/n"
send "y\r"

# 第 15 步:处理端口输入
expect "请输入自定义端口"
send "\r"

expect "请输入自定义端口"
send "\r"

# 第 16 步:处理速度设置
expect "下行速度:"
send "10000\r"

expect "上行速度:"
send "50\r"

# 第 17 步:处理端口输入
expect "请输入自定义端口"
send "\r"

expect "请输入自定义端口"
send "\r"

# 第 18 步:处理选择
expect "请选择:"
send "\r"

# 第 19 步:处理端口输入
expect "请输入自定义端口"
send "\r"

# 第 20 步:处理端口输入
expect "请输入自定义端口"
send "\r"

# 第 21 步:处理上次安装记录
expect -re "读取到上次安装记录.*path路径.*y/n"
send "y\r"

# 第 22 步:继续处理后续步骤
expect "是否继续"
send "y\r"

expect "是否安装"
send "y\r"

expect "是否卸载"
send "n\r"

expect "是否删除"
send "n\r"

expect "是否更新"
send "y\r"

expect "是否重启"
send "y\r"

expect "按回车继续"
send "\r"

# 第 23 步:处理内核更新OK提示（放在最后）
expect {
    timeout {
        send "\r"
        exp_continue
    }
    "请选择:" {
        # 继续下一步
    }
}

# 让mack脚本自己控制流程
expect eof
EOF

    # 给expect脚本添加执行权限
    chmod +x /tmp/install.exp

    # 运行安装脚本
    _yellow "开始自动化安装和配置mack-a sing-box..."
    _yellow "当提示输入域名时，请输入您的域名并按回车"
    expect /tmp/install.exp

    # 清理临时文件
    rm -f /tmp/install.exp
    
    # 创建新的expect脚本来处理后续选择
    cat > /tmp/continue.exp << EOF
#!/usr/bin/expect -f

# 设置超时时间
set timeout 120

# 设置变量
set salt "$salt"
set merge_info "$merge_info"

# 启动mack脚本
spawn /etc/v2ray-agent/install.sh

# 等待并选择选项7
expect "请选择:"
send "7\r"

# 等待并选择选项2
expect "请输入:"
send "2\r"

expect "请输入salt值"
send "\$salt\r"

# 让mack脚本自己控制后续流程
interact
EOF

    # 给新的expect脚本添加执行权限
    chmod +x /tmp/continue.exp

    # 执行新的expect脚本
    expect /tmp/continue.exp

    # 如果需要合并订阅，启动新的进程
    if [[ -n "$merge_info" ]]; then
        cat > /tmp/merge.exp << EOF
#!/usr/bin/expect -f

# 设置超时时间
set timeout 120

# 设置变量
set merge_info "$merge_info"
set email "$email"
# 启动新的mack脚本进程
spawn /etc/v2ray-agent/install.sh

# 等待并选择选项7
expect "请选择:"
send "7\r"

expect "请输入:"
send "3\r"

expect "请选择:"
send "1\r"

expect "请输入域名 端口 机器别名:"
send "\$merge_info\r"

expect "是否是HTTP订阅？"
send "n\r"

expect "是否使用上次生成的Salt"
send "y\r"

expect "读取到其他订阅，是否更新"
send "y\r"

# 继续执行新的步骤
# 启动新的mack脚本进程
spawn /etc/v2ray-agent/install.sh

expect "请选择:"
send "7\r"

expect "请输入:"
send "4\r"

expect "请输入要添加的用户数量:"
send "1\r"

expect "UUID:"
send "\r"

expect "随机email:"
send "\$email\r"

# 让mack脚本自己控制后续流程
interact
EOF

        # 给合并脚本添加执行权限
        chmod +x /tmp/merge.exp

        # 执行合并脚本
        expect /tmp/merge.exp

        # 清理临时文件
        rm -f /tmp/merge.exp
    fi

    # 清理临时文件
    rm -f /tmp/continue.exp
}

# 卸载expect
uninstall_expect() {
    # 首先检查expect是否已安装
    if ! command -v expect &> /dev/null; then
        _yellow "expect工具未安装，无需卸载"
        return 0
    fi

    _yellow "正在卸载expect工具..."
    
    # 先卸载主程序
    apt-get remove -y expect
    
    # 卸载自动安装的依赖包
    apt-get autoremove -y libtcl8.6 tcl-expect tcl8.6
    
    # 清理配置文件
    rm -rf /etc/expect.rc
    rm -rf /usr/share/expect
    rm -rf /usr/share/doc/expect
    
    # 检查是否还有相关文件
    local remaining_files=$(find /usr -name "*expect*" 2>/dev/null)
    if [[ -n "$remaining_files" ]]; then
        _yellow "发现以下残留文件："
        echo "$remaining_files"
        _yellow "正在清理残留文件..."
        rm -rf $remaining_files
    fi
    
    # 再次检查是否真的卸载成功
    if ! command -v expect &> /dev/null && ! dpkg -l | grep -q "expect"; then
        _green "确认：expect工具已完全卸载"
    else
        _red "警告：expect工具可能未完全卸载"
        _yellow "请手动执行以下命令完成卸载："
        _yellow "apt-get autoremove -y"
        _yellow "apt-get clean"
    fi
}

# 卸载mack-a sing-box
uninstall_macka_singbox() {
    _yellow "开始卸载mack-a sing-box..."
    
    # 创建expect脚本处理卸载
    cat > /tmp/uninstall.exp << 'EOF'
#!/usr/bin/expect -f

# 设置超时时间
set timeout 120

# 设置中文环境
set env(LANG) "zh_CN.UTF-8"
set env(LC_ALL) "zh_CN.UTF-8"

# 启动卸载脚本
spawn bash -c "curl -sL https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh > /tmp/mack-a.sh && bash /tmp/mack-a.sh"

# 处理交互
expect "请选择:"
send "20\r"

expect -re "是否确认卸载安装内容？.*y/n"
send "y\r"

# 等待卸载完成
expect eof
EOF

    # 给expect脚本添加执行权限
    chmod +x /tmp/uninstall.exp

    # 运行卸载脚本
    _yellow "正在执行卸载命令..."
    expect /tmp/uninstall.exp

    # 清理临时文件
    rm -f /tmp/uninstall.exp
    rm -f /tmp/mack-a.sh
    
    # 删除acme相关配置
    _yellow "正在删除acme相关配置..."
    if [[ -d "/root/.acme.sh" ]]; then
        rm -rf /root/.acme.sh
        _green "acme配置已删除"
    else
        _yellow "未找到acme配置目录"
    fi
    
    _green "mack-a sing-box卸载完成！"
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
    
    # 主菜单循环
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                _yellow "正在安装 Xray(233boy急速)..."
                run_install "https://github.com/233boy/Xray/raw/main/install.sh" "1"
                ;;
            2)
                _yellow "正在安装 八合一键脚本mack-a&(歇斯底里)..."
                run_install "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" "1"
                ;;
            3)
                _yellow "正在安装 FranzKafkaYu/x-ui..."
                run_install "https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh" "1"
                ;;
            4)
                _yellow "正在安装 kejilong工具..."
                run_install "kejilion.sh" "1"
                ;;
            5)
                uninstall_script
                _green "脚本已卸载，程序将退出"
                exit 0
                ;;
            6)
                show_script_info
                # 显示信息后直接跳转到root命令行
                bash
                ;;
            7)
                # 在选项7执行时立即提示输入域名和用户名
                echo -e "\n${green}=== 用户管理设置说明 ===${none}"
                echo -e "${green}1. 相同值Salt${none}"
                echo -e "${green}2. 相同用户名${none}"
                echo -e "${green}3. 添加订阅地址格式[域名:端口:机器别名](不带www.)非HTTP订阅${none}"
                echo -e "${green}4. 相同的用户邮箱${none}\n"

                echo -e "${yellow}=== 用户管理操作步骤说明 ===${none}"
                echo -e "${yellow}第1步：安装后自动查看可忽略${none}"
                echo -e "${yellow}第2步：等于生成订阅${none}"
                echo -e "${yellow}第3步：等于添加其他订阅地址(域名端口别名)${none}"
                echo -e "${yellow}第4步：等于生成其它VPS同用户邮箱订阅${none}\n"

                #字体颜色测试
                echoContent green "作者：mack-a"
                echoContent skyBlu "作者：mack-a"
                echoContent lightRed "作者：mack-a"
                echoContent cyan "作者：mack-a"
                

                _yellow "请输入要配置的域名"
                _red "-(例如: www.v2ray-agent.com或aaa.v2ray-agent.com，注意前缀和解析地址)"
                _blue "域名:"
                read domain
                if [[ -z "$domain" ]]; then
                    _red "域名不能为空"
                    continue
                fi
                
                _yellow "请输入salt加密值 (回车使用随机值，合并订阅必须用相同的值): "
                read salt
                salt=${salt:-""}  # 如果salt为空，使用空字符串，让系统生成随机值

                _yellow "请输入合并订阅所拉取的其他VPS的域名:端口:别名 (例如: vps1.com:443:server1，回车默认不合并): "
                read merge_info

                _yellow "请输入用户名 (回车默认: admin，合并订阅必须用相同用户名): "
                read username
                username=${username:-admin}  # 如果用户名为空，使用默认值 admin

                _yellow "请输入合并订阅邮箱 (例如:***@gmail.com): "
                read email
                if [[ -z "$email" ]]; then
                    _red "邮箱不能为空"
                    continue
                fi
                
                # 传递域名、用户名、salt值、合并信息和邮箱参数给auto_install_macka_singbox函数
                auto_install_macka_singbox "$domain" "$username" "$salt" "$merge_info" "$email"
                ;;
            8)
                uninstall_expect
                ;;
            9)
                _yellow "开始一键卸载..."
                uninstall_macka_singbox
                uninstall_script
                uninstall_expect
                _green "所有组件已卸载完成，程序将退出"
                exit 0
                ;;
            0)
                _green "感谢使用，再见！"
                # 在退出前自动执行 source 命令
                bash -c "source /etc/profile.d/vps-jb-bieming.sh; bash"
                exit 0
                ;;
            *)
                _red "无效的选项，请重新选择"
                ;;
        esac
        
        # 只有在安装失败时才显示"按回车继续"
        if [[ $install_status -ne 0 ]] && [[ $install_status -ne 1 ]]; then
            echo
            read -p "按回车键继续..."
        fi
    done
}

# 启动脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 只在直接运行脚本时设置别名
    setup_alias
    main
fi 
