#脚本名称：main
#作者姓名：曹一佳；学号：3180101226
#用bash脚本实现一个简单的作业管理系统
#用数据库软实现数据的存储
#实现一个简单的菜单“作业管理系统”界面
#系统中根据不同的权限分为三类用户：管理员、教师、学生，分别通过各自的脚本实现
#该程序一共由四个文件组成（main,admin_module,teacher_module,student_module)

#!/bin/bash
#主目录模块（main）
function main {
    while true
    do
        clear
        main_menu #显示主菜单
        read choice #读取用户输入
        case $choice in
        1) admin_login;; #管理员
        2) teacher_login;; #教师
        3) student_login;; #学生
        0) #退出系统
		    echo "感谢您的使用，再见！"
		    exit 0;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！"
		    sleep 2;;
        esac
    done
}

function main_menu {
    #主界面菜单如下：
	echo "============================================"
	echo -e "\t\t作业管理系统"
    echo "============================================"
	echo -e "\t[1] 管理员登陆\t[2] 教师登陆"
	echo -e "\t[3] 学生登陆\t[0] 退出系统"
	echo "============================================"
}

#管理员登陆函数
function admin_login {
    read -p "[输入q重新选择]输入管理员账号:" id #输入管理员账号
    while true
    do
        if [ -z "$id" ] #如果帐号为空，则重新输入
        then
            read -p "帐号不能为空，请重新输入帐号:" id
        else break
        fi
    done
    if [ $id = "q" ] #返回主目录
    then
        clear
        main
    fi

    read -s -p "请输入密码:" passwd #输入密码，输入的密码不显示在命令终端上
    while true
    do
        if [ -z "$passwd" ] #如果帐号为空，则重新输入
        then
            echo
            read -s -p "密码不能为空，请重新输入密码:" passwd
        else break
        fi
        
    done
    echo #换行

    MYSQL=$(which mysql)
    apasswd=$($MYSQL management -u test -Bse 'select password from admin where admin_id = '$id'')
    if [ ! -z $apasswd ] && [[ $passwd = $apasswd ]] #账号存在且密码正确
    then
        ./admin_module $id #登陆
    else 
        echo "账号不存在或密码错误，登录失败！"
        sleep 2
        main #回到主目录
    fi
}

#教师登陆函数
function teacher_login {
    read -p "[输入q重新选择]输入教师账号:" id #输入教师账号
    while true
    do
        if [ -z "$id" ] #如果帐号为空，则重新输入
        then
            read -p "帐号不能为空，请重新输入帐号:" id
        else break
        fi
    done
    if [ $id = "q" ] #返回主目录
    then
        clear
        main
    fi

    read -s -p "请输入密码:" passwd #输入密码，输入的密码不显示在命令终端上
    while true
    do
        if [ -z "$passwd" ] #如果帐号为空，则重新输入
        then
            echo
            read -s -p "密码不能为空，请重新输入密码:" passwd
        else break
        fi
        
    done
    echo #换行

    MYSQL=$(which mysql)
    apasswd=$($MYSQL management -u test -Bse 'select password from teacher where teacher_id = '$id'')
    if [ ! -z $apasswd ] && [[ $passwd = $apasswd ]] #账号存在且密码正确
    then
        ./teacher_module $id #登陆
    else 
        echo "账号不存在或密码错误，登录失败！"
        sleep 2
        main #回到主目录
    fi
}

#学生登录函数
function student_login {
    read -p "[输入q重新选择]输入学生账号:" id #输入学生账号
    while true
    do
        if [ -z "$id" ] #如果帐号为空，则重新输入
        then
            read -p "帐号不能为空，请重新输入帐号:" id
        else break
        fi
    done
    if [ $id = "q" ] #返回主目录
    then
        clear
        main
    fi

    read -s -p "请输入密码:" passwd #输入密码，输入的密码不显示在命令终端上
    while true
    do
        if [ -z "$passwd" ] #如果帐号为空，则重新输入
        then
            echo
            read -s -p "密码不能为空，请重新输入密码:" passwd
        else break
        fi
        
    done
    echo #换行

    MYSQL=$(which mysql)
    apasswd=$($MYSQL management -u test -Bse 'select password from student where student_id = '$id'')
    if [ ! -z $apasswd ] && [[ $passwd = $apasswd ]] #账号存在且密码正确
    then
        ./student_module $id #登陆
    else 
        echo "账号不存在或密码错误，登录失败！"
        sleep 2
        main #回到主目录
    fi
}
chmod +x admin_module #设置管理员模块为可执行
chmod +x teacher_module #设置教师模块为可执行
chmod +x student_module #设置学生模块为可执行
main