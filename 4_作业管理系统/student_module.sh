#脚本名称：student_module
#作者姓名：曹一佳；学号：3180101226

#!/bin/bash
#以下是学生模块（student_module）
#在教师添加学生账户后，学生就可以登录系统，并完成作业和实验
#基本功能：新建、编辑作业或实验功能；查询作业或实验完成情况

function student_menu { #学生菜单
    sid=$1
	clear
	while true
	do
        #学生菜单界面如下
        echo "============================================"
	    echo -e "\t\t学生菜单"
	    echo "============================================"
		echo -e "\t当前账号: $sid"
	    echo "============================================"
		echo -e "  [1] 查看您的课程\t[2] 新建作业/实验"
		echo -e "  [3] 修改作业/实验\t[4] 删除作业/实验"
		echo -e "  [5] 查询作业完成情况\t[6] 修改密码"
		echo -e "  [0] 退出账号"
	    echo "============================================"
        
		read student_choice #读入用户输入
		case $student_choice in #以下函数名与上面的功能一一对应
		1)show_course $sid;;
		2)create_job $sid;;
		3)alter_job $sid;;
		4)delete_job $sid;;
		5)check_job $sid;;
		6)change_spwd $sid;;
		0)back;;
		*)
			echo "无对应选项，请重新输入！"
			sleep 2
			clear;;
		esac
	done
}

#查看该学生所上的所有课程
function show_course {
	sid=$1
	clear
	MYSQL=$(which mysql)
    $MYSQL management -u test -e "select course_id,title as course_title,description as course_description from course natural join take_course where student_id='$sid'"
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    student_menu $sid
	fi
}

#新建作业/实验
#输入课程号，先显示该课程布置的所有作业/实验，以便于选择作业布置编号
#再输入作业布置编号，新建该布置作业的上交作业（包括标题，内容）
#可以选择直接输入标题和内容，也可以选择通过文件上传（文件名作为上交作业标题，文件内容作为上交作业内容）
#只有上该课程的学生可新建，需检查权限
function create_job {
	sid=$1
	clear
	echo "============================================"
	echo -e "\t\t新建作业/实验[输入q返回]"
	echo "============================================"
    echo -e "  [1]直接输入\t[2]文件上传"
	echo "============================================"
	while true
	do
	    read -p "课程编号[输入q返回]:" cid
		if [ $cid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#先检查权限（是否学习该课程）
	    MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from take_course where course_id = '$cid' and student_id='$sid'")
        if [ ! -z $check ] #该学生确实学习该课程
	    then
		    #显示该课程布置的所有作业/实验，以便于选择作业布置编号
            $MYSQL management -u test -e "select * from hw_assign where course_id='$cid'"
	        break
		else
	        echo "您并不学习该课程，请重新选择课程！"
	    fi
	done

	while true
	do
	    read -p "要上交作业/实验的作业/实验布置编号[输入q返回]:" hwid
		if [ $hwid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#检查该课程中作业编号是否存在
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select assign_no from hw_assign where course_id = '$cid' and assign_no='$hwid'")
        if [ ! -z $check ] #该作业编号确实属于该课程
	    then
	        break
		else
	        echo "该作业/实验布置编号并不属于该课程，请重新选择作业/实验！"
	    fi
	done

	while true
    do
	    read -p "选择上交作业方式(1/2):" create_choice #读取用户输入
	    case $create_choice in
        1) #直接输入
		    read -p "上交作业标题:" title
			read -p "上交作业内容:" content
			MYSQL=$(which mysql)
			statement="insert into hw_submit(assign_no,course_id,student_id,submit_title,content) values('$hwid','$cid','$sid','$title','$content')" #插入新记录,submit_no自动生成
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "作业/实验上交成功！"
			else
			    echo "作业/实验上交失败！"
			fi;;
        2) #文件上传
		    echo "(创建时，文件名作为上交作业/实验的标题，文件内容作为上交作业/实验的内容)"
		    read -p "选择文件：" filename #输入文件名（若非当前目录则必须包括路径）
			title=${filename##*/} #去掉从左边算起的最后一个'/'字符及其左边的内容，即去掉前面的路径只剩下文件名
			content=`cat $filename` #读取文件内容
			MYSQL=$(which mysql)
			statement="insert into hw_submit(assign_no,course_id,student_id,submit_title,content) values('$hwid','$cid','$sid','$title','$content')" #插入新记录,submit_no自动生成
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "作业/实验上交成功！"
			else
			    echo "作业/实验上交失败！"
			fi;;
		q) #返回
		    student_menu $sid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#修改上交的作业/实验
#输入课程号，先显示该课程上交的所有作业/实验，以便于选择作业上交编号
#再输入作业上交编号，修改该上交作业（标题，内容）
#可以选择直接输入新标题和新内容，也可以选择通过文件上传（文件名作为上交作业新标题，文件内容作为上交作业新内容）
#只有上交该作业的学生可修改，需检查权限
function alter_job {
	sid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改作业/实验[输入q返回]"
	echo "============================================"
	echo -e "  [1]直接输入\t[2]文件上传"
	echo "============================================"
    while true
	do
	    read -p "课程编号[输入q返回]:" cid
		if [ $cid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#先检查权限（是否学习该课程）
	    MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from take_course where course_id = '$cid' and student_id='$sid'")
        if [ ! -z $check ] #该学生确实学习该课程
	    then
		    #显示该学生在该课程上交的所有作业/实验，以便于选择作业上交编号
            $MYSQL management -u test -e "select * from hw_submit where course_id='$cid' and student_id='$sid'"
	        break
		else
	        echo "您并不学习该课程，请重新选择课程！"
	    fi
	done

	while true
	do
	    read -p "要修改作业/实验的作业/实验上交编号[输入q返回]:" hwid
		if [ $hwid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#检查该课程中该学生上交作业编号是否存在
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select submit_no from hw_submit where course_id = '$cid' and student_id='$sid' and submit_no='$hwid'")
        if [ ! -z $check ] #该上交作业编号确实属于该课程该学生
	    then
	        break
		else
	        echo "该作业/实验上交编号并不属于该课程或并非您所上交，请重新选择作业/实验！"
	    fi
	done
	#修改
	while true
    do
	    read -p "选择修改作业方式(1/2):" alter_choice #读取用户输入
	    case $alter_choice in
        1) #直接输入
		    read -p "新的作业标题:" new_title
			read -p "新的作业内容:" new_content
			MYSQL=$(which mysql)
	        statement="update hw_submit set submit_title='$new_title',content='$new_content' where submit_no='$hwid'" 
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "作业/实验修改成功！"
			else
			    echo "作业/实验修改失败！"
			fi;;
        2) #文件上传
		    echo "(修改时，文件名作为上交作业/实验的新标题，文件内容作为上交作业/实验的新内容)"
		    read -p "选择文件：" filename #输入文件名（若非当前目录则必须包括路径）
			new_title=${filename##*/} #去掉从左边算起的最后一个'/'字符及其左边的内容，即去掉前面的路径只剩下文件名
			new_content=`cat $filename` #读取文件内容
			MYSQL=$(which mysql)
	        statement="update hw_submit set submit_title='$new_title',content='$new_content' where submit_no='$hwid'" 
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "作业/实验修改成功！"
			else
			    echo "作业/实验修改失败！"
			fi;;
		q) #返回
		    student_menu $sid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#删除上交的作业/实验
#输入课程号，先显示该课程上交的所有作业/实验，以便于选择作业上交编号
#再输入作业上交编号，删除该上交作业
#只有上交该作业的学生可修改，需检查权限
function delete_job {
	sid=$1
	clear
	echo "============================================"
	echo -e "\t\t删除作业/实验[输入q返回]"
	echo "============================================"
    while true
	do
	    read -p "课程编号[输入q返回]:" cid
		if [ $cid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#先检查权限（是否学习该课程）
	    MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from take_course where course_id = '$cid' and student_id='$sid'")
        if [ ! -z $check ] #该学生确实学习该课程
	    then
		    #显示该学生在该课程上交的所有作业/实验，以便于选择作业上交编号
            $MYSQL management -u test -e "select * from hw_submit where course_id='$cid' and student_id='$sid'"
	        break
		else
	        echo "您并不学习该课程，请重新选择课程！"
	    fi
	done

	while true
	do
	    read -p "要删除作业/实验的作业/实验上交编号[输入q返回]:" hwid
		if [ $hwid = "q" ] #返回菜单
		then
		    student_menu $sid
		fi
		#检查该课程中该学生上交作业编号是否存在
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select submit_no from hw_submit where course_id = '$cid' and student_id='$sid' and submit_no='$hwid'")
        if [ ! -z $check ] #该上交作业编号确实属于该课程该学生
	    then
	        break
		else
	        echo "该作业/实验上交编号并不属于该课程或并非您所上交，请重新选择作业/实验！"
	    fi
	done
	#删除
	MYSQL=$(which mysql)
	statement="delete from hw_submit where submit_no='$hwid'" 
	$MYSQL management -u test << EOF
	$statement
EOF
    if [ $? -eq 0 ]
	then
	    echo "作业/实验删除成功！"
	else
	    echo "作业/实验删除失败！"
	fi
}

#查询作业完成情况
function check_job {
	sid=$1
	clear
	MYSQL=$(which mysql)
	all=$($MYSQL management -u test -Bse "select count(distinct assign_no) from hw_assign natural join take_course where student_id = '$sid'")
	echo "您已完成的作业/实验："
	MYSQL=$(which mysql)
	finish=$($MYSQL management -u test -Bse "select count(distinct assign_no) from hw_submit where student_id = '$sid'")
	if [ $finish -eq 0 ]
	then
	    echo "No homework finished yet."
	else
	    MYSQL=$(which mysql)
        $MYSQL management -u test -e "select assign_no,hw_assign.title as assign_title,requirement,submit_no,submit_title,content from hw_assign natural join hw_submit where student_id='$sid'" #某学生已完成的作业
	fi

	echo "您未完成的作业/实验："
	MYSQL=$(which mysql)
	let not_finish=all-finish #未完成作业人数
	if [ $not_finish -eq 0 ]
	then
	    echo "All homework has been finished."
	else
	    MYSQL=$(which mysql)
		$MYSQL management -u test -e "select assign_no,hw_assign.title as assign_title,requirement from hw_assign where assign_no not in(select assign_no from hw_assign natural join hw_submit where student_id='$sid')" #某学生未完成的作业
    fi

	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    student_menu $sid
	fi
}

#修改密码
function change_spwd {
	sid=$1
	while true
	do
	    read -s -p "原来的密码:" passwd #输入密码，输入的密码不显示在命令终端上
	    echo
		MYSQL=$(which mysql)
        apasswd=$($MYSQL management -u test -Bse 'select password from student where student_id = '$sid'')
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
		statement="update student set password='$new_passwd0' where student_id='$sid'" #修改记录
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
	student_menu $sid
}

#返回上级菜单
function back { 
	clear
	exit
}

sid=$1
student_menu $sid