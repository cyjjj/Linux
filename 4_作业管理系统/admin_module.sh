#脚本名称：admin_module
#作者姓名：曹一佳；学号：3180101226

#!/bin/bash
#管理员模块（admin_module）
#创建、修改、删除、显示（list）教师帐号；教师帐户包括教师工号、教师姓名，教师用户以教师工号登录。
#创建、修改、删除课程；绑定（包括添加、删除）课程与教师用户。课程名称以简单的中文或英文命名。

function admin_menu { #管理员菜单
    aid=$1
	clear
	while true
	do
        #管理员菜单界面如下
        echo "============================================"
	    echo -e "\t\t管理员菜单"
	    echo "============================================"
		echo -e "\t当前账号: $aid"
	    echo "============================================"
		echo -e "  [1] 创建教师账号\t[2] 修改教师账号"
		echo -e "  [3] 删除教师账号\t[4] 显示教师账号"
		echo -e "  [5] 创建课程\t\t[6] 修改课程"
		echo -e "  [7] 删除课程\t\t[8] 显示课程列表"
		echo -e "  [9] 修改密码\t\t[0] 退出账号"
	    echo "============================================"
        
		read admin_choice #读入用户输入
		case $admin_choice in #以下函数名与上面的功能一一对应
		1)create_tid $aid;;
		2)alter_tid $aid;;
		3)delete_tid $aid;;
		4)show_tid $aid;;
		5)create_course $aid;;
		6)alter_course $aid;;
		7)delete_course $aid;;
		8)show_course $aid;;
		9)change_adminpwd $aid;;
		0)back;;
		*)
			echo "无对应选项，请重新输入！"
			sleep 2
			clear;;
		esac
	done
}

#创建教师账号，包括教师账号（工号）、姓名、密码（初始123456）、院系
#可以创建单个账号，也可以通过文件批量创建账号
function create_tid { 
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t创建教师账号[输入q返回]"
	echo "--------------------------------------------"
	echo -e "  账号即为教师工号,初始密码为123456"
	echo "============================================"
    echo -e "  [1]创建单个账号\t[2]批量创建账号"
	echo "============================================"
	while true
    do
	    read create_choice #读取用户输入
	    case $create_choice in
        1) #创建单个账号
		    read -p "教师工号:" tid
			read -p "教师姓名:" name
			read -p "教师院系:" department #输入相关信息
			MYSQL=$(which mysql)
			statement="insert into teacher values('$tid','$name','123456','$department')" #插入新记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "创建成功！"
			else
			    echo "创建失败！"
			fi;;
        2) #批量创建账号
		    echo "（批量创建文件中每行信息为该新建账号的账号、姓名、院系，#分隔）"
		    read -p "选择批量创建文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				#拆分字符串到数组
				str=$LINE
				OLD_IFS="$IFS"
				IFS="#"
				arr=($str)
				IFS="$OLD_IFS"
				#为自定义变量赋值
				tid=${arr[0]}
				tname=${arr[1]}
				tdepart=${arr[2]}
				#插入新记录
				MYSQL=$(which mysql)
			    statement="insert into teacher values('$tid','$tname','123456','$tdepart')" 
			    $MYSQL management -u test << EOF
			    $statement
EOF
				if [ $? -eq 0 ]
			    then
			        let "count+=1"
				else
				    echo "$tid对应账号创建失败！"
			    fi
			done
			echo "成功创建账号!";;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#修改教师账号，包括修改工号、姓名、院系，重置密码（重置为初始密码123456）
function alter_tid {
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改教师账号[输入q返回]"
	echo "============================================"
    echo -e "  [1]修改工号\t[2]修改姓名"
	echo -e "  [3]修改院系\t[4]重置密码"
	echo "============================================"
	while true
    do
	    read alter_choice #读取用户输入
	    case $alter_choice in
        1) #修改工号
		    read -p "要修改的工号:" alter_tid
			read -p "新的工号:" new_tid #输入相关信息
			MYSQL=$(which mysql)
			statement="update teacher set teacher_id='$new_tid' where teacher_id='$alter_tid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改工号成功！"
			else
			    echo "修改工号失败！"
			fi;;
        2) #修改姓名
		    read -p "要修改的账号:" alter_tid
			read -p "新的姓名:" new_name #输入相关信息
			MYSQL=$(which mysql)
			statement="update teacher set name='$new_name' where teacher_id='$alter_tid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改姓名成功！"
			else
			    echo "修改姓名失败！"
			fi;;
		3) #修改院系
		    read -p "要修改的账号:" alter_tid
			read -p "新的院系:" new_depart #输入相关信息
			MYSQL=$(which mysql)
			statement="update teacher set department='$new_depart' where teacher_id='$alter_tid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改院系成功！"
			else
			    echo "修改院系失败！"
			fi;;
		4) #重置密码
		    read -p "要重置密码的账号:" alter_tid #输入相关信息
			MYSQL=$(which mysql)
			statement="update teacher set password='123456' where teacher_id='$alter_tid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "密码重置成功！"
			else
			    echo "密码重置失败！"
			fi;;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！"
		    sleep 2;;
        esac
    done
}

#删除教师账号，输入教师账号（工号），删除对应账号
#可以删除单个账号，也可以通过文件批量删除账号
function delete_tid { 
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t删除教师账号[输入q返回]"
	echo "============================================"
    echo -e "  [1]删除单个账号\t[2]批量删除账号"
	echo "============================================"
	while true
    do
	    read delete_choice #读取用户输入
	    case $delete_choice in
        1) #删除单个账号
		    read -p "要删除的账号（工号）:" del_tid #输入相关信息
			MYSQL=$(which mysql)
			statement="delete from teacher where teacher_id='$del_tid'" #删除记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi;;
        2) #批量删除账号
		    echo "（批量删除文件中每行信息为要删除账号的工号）"
		    read -p "选择批量删除文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				del_tid=$LINE
				#删除记录
				MYSQL=$(which mysql)
			    statement="delete from teacher where teacher_id='$del_tid'" 
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
			    then
			        let "count+=1"
			    else
			        echo "$del_tid对应账号删除失败！"
			    fi
			done
			echo "成功删除账号!";;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#显示所有已经创建的教师信息，包括账号（工号）、姓名、院系，但为了安全，不显示密码
function show_tid {
	aid=$1
	clear
	MYSQL=$(which mysql)
    $MYSQL management -u test -e 'select teacher_id,name,department from teacher'
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    admin_menu $aid
	fi
}

#创建课程，包括课程号、课程名称和课程描述，以及负责老师的工号（允许多名老师负责同一课程）
#可以创建单门课程，也可以通过文件批量创建课程
function create_course {
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t创建课程[输入q返回]"
	echo "============================================"
    echo -e "  [1]创建单门课程\t[2]批量创建课程"
	echo "============================================"
	while true
    do
	    read create_choice #读取用户输入
	    case $create_choice in
        1) #创建单个账号
		    read -p "课程编号:" cid
			read -p "课程名称:" title
			read -p "课程描述:" description
			MYSQL=$(which mysql)
			statement="insert into course values('$cid','$title','$description')" #插入新记录
			$MYSQL management -u test << EOF
			$statement
EOF
			read -p "负责教师数：" tnum
			for (( i=1; i <= $tnum; i++ )) 
			do 
			    read -p "第$i个教师工号:" tid
				MYSQL=$(which mysql)
			    statement="insert into teach_course values('$tid','$cid')" #插入新记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
			done #输入相关信息
            if [ $? -eq 0 ]
			then
			    echo "创建成功！"
			else
			    echo "创建失败！"
			fi;;
        2) #批量创建账号
		    echo "（批量创建文件中每行信息为该新建课程的课程号、名称、课程描述、负责教师数目、负责教师工号，#分隔）"
		    read -p "选择批量创建文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				#拆分字符串到数组
				str=$LINE
				OLD_IFS="$IFS"
				IFS="#"
				arr=($str)
				IFS="$OLD_IFS"
				#为自定义变量赋值
				cid=${arr[0]}
				title=${arr[1]}
				description=${arr[2]}
				MYSQL=$(which mysql)
			    statement="insert into course values('$cid','$title','$description')" #插入新记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
				tnum=${arr[3]}
				for (( i=1; i <= $tnum; i++ )) 
			    do 
			    tid=${arr[$[3+$i]]}
				MYSQL=$(which mysql)
			    statement="insert into teach_course values('$tid','$cid')" #插入新记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
			    done #插入新记录
                if [ $? -eq 0 ]
			    then
			        let "count+=1"
			    else
			        echo "$cid对应课程创建出错！"
			    fi
			done
			echo "成功创建课程!";;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}
#修改已经创建的课程
function alter_course {
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改课程[输入q返回]"
	echo "============================================"
    echo -e "  [1]修改课程号\t[2]修改课程名称"
	echo -e "  [3]修改课程描述\t[4]修改负责教师"
	echo "============================================"
	while true
    do
	    read alter_choice #读取用户输入
	    case $alter_choice in
        1) #修改课程号
		    read -p "要修改课程的课程号:" alter_cid
			read -p "新的课程号:" new_cid #输入相关信息
			MYSQL=$(which mysql)
			statement="update course set course_id='$new_cid' where course_id='$alter_cid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi;;
        2) #修改课程名称
		    read -p "要修改课程的课程号:" alter_cid
			read -p "新的课程名称:" new_title #输入相关信息
			MYSQL=$(which mysql)
			statement="update course set title='$new_title' where course_id='$alter_cid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi;;
		3) #修改课程描述
		    read -p "要修改课程的课程号:" alter_cid
			read -p "新的课程描述:" new_descrip #输入相关信息
			MYSQL=$(which mysql)
			statement="update course set description='$new_descrip' where course_id='$alter_cid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi;;
		4) #修改负责教师
		    read -p "要修改课程的课程号:" alter_cid
			MYSQL=$(which mysql)
			statement="delete from teach_course where course_id='$alter_cid'" #删除原来的记录
			$MYSQL management -u test << EOF
			$statement
EOF
			read -p "负责教师数量:" tnum
			for (( i=1; i <= $tnum; i++ )) 
			do 
			    read new_tid
				MYSQL=$(which mysql)
			    statement="insert into teach_course values('$new_tid','$alter_cid')" #插入新记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
			done
			if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi;;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！"
		    sleep 2;;
        esac
    done
}

#删除课程
function delete_course {
	aid=$1
	clear
	echo "============================================"
	echo -e "\t\t删除课程[输入q返回]"
	echo "============================================"
    echo -e "  [1]删除单门课程\t[2]批量删除课程"
	echo "============================================"
	while true
    do
	    read delete_choice #读取用户输入
	    case $delete_choice in
        1) #删除单门课程
		    read -p "要删除课程的课程号:" del_cid #输入相关信息
			MYSQL=$(which mysql)
			statement="delete from course where course_id='$del_cid'" #删除记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi;;
        2) #批量删除课程
		    echo "（批量删除文件中每行信息为要删除课程的课程号）"
		    read -p "选择批量删除文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				del_cid=$LINE
				#删除记录
				MYSQL=$(which mysql)
			    statement="delete from course where course_id='$del_cid'" 
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
			    then
			        let "count+=1"
			    else
			        echo "$del_cid对应账号删除失败！"
			    fi
			done
			echo "成功删除账号!";;
		q) #返回
		    admin_menu $aid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#显示所有已经创建的课程，包括课程号、课程名称、课程描述、负责教师工号
function show_course {
	aid=$1
	clear
	MYSQL=$(which mysql)
    $MYSQL management -u test -e 'select course_id,title as course_title,description as course_description,teacher_id,name as teacher_name,department as teacher_department from course natural join teach_course natural join teacher'
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    admin_menu $aid
	fi
}

function change_adminpwd {
	aid=$1
	while true
	do
	    read -s -p "原来的密码:" passwd #输入密码，输入的密码不显示在命令终端上
	    echo
		MYSQL=$(which mysql)
        apasswd=$($MYSQL management -u test -Bse 'select password from admin where admin_id = '$aid'')
        if [ ! -z $apasswd ] && [[ $passwd = $apasswd ]] #密码正确
        then #修改密码
            break
        else #密码错误，不允许修改密码，重新输入密码
            echo "密码错误，请重新输入！"
        fi
	done
	#修改密码
	while true
	do
	    read -s -p "新的密码（长度不少于6位）:" new_passwd0
		echo
	    len=`expr length $new_passwd0` #密码长度
	    if [ $len -lt 6 ] #判断密码长度是否少于六位
	    then
		    echo "密码长度不够,请按要求重新输入！"
		else
		    break #密码符合要求
		fi
	done
	read -s -p "请再次输入以确认新密码：" new_passwd1 #再次输入密码
	echo
	if [ $new_passwd0 -ne $new_passwd1 ] #检查两次输入是否匹配
	then
		echo "两次输入不匹配，修改密码失败！"
	else
		MYSQL=$(which mysql)
		statement="update admin set password='$new_passwd0' where admin_id='$aid'" #修改记录
		$MYSQL management -u test << EOF
		$statement
EOF
        if [ $? -eq 0 ]
		then
		    echo "修改密码成功！"
		else
			echo "修改密码失败！"
		fi
	fi
	sleep 2
	admin_menu $aid
}

#返回上级菜单
function back { 
	clear
	exit
}

aid=$1
admin_menu $aid