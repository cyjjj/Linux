#脚本名称：teacher_module
#作者姓名：曹一佳；学号：3180101226

#!/bin/bash
#教师模块（teacher_module）
#对某门课程，创建或导入、修改、删除学生帐户，根据学号查找学生帐号
##学生帐号的基本信息包括学号、姓名、专业、年级、班级，学生使用学号登录
#发布课程信息。包括新建、编辑、删除、显示（list）课程信息等功能
#布置作业或实验。包括新建、编辑、删除、显示（list）作业或实验等功能
#查找、打印所有学生的完成作业情况

function teacher_menu { #教师菜单
    tid=$1
	clear
	while true
	do
        #教师菜单界面如下
        echo "============================================"
	    echo -e "\t\t教师菜单"
	    echo "============================================"
		echo -e "\t当前账号: $tid"
	    echo "============================================"
		echo "学生管理："
		echo -e "  [1] 添加学生账户\t[2] 修改学生账户"
		echo -e "  [3] 删除学生账户\t[4] 显示学生帐户"
		echo "--------------------------------------------"
		echo "课程管理："
		echo -e "  [5] 发布课程信息\t[6] 修改课程信息"
		echo -e "  [7] 删除课程信息\t[8] 显示课程信息"
		echo "  [9] 查看您教授的课程"
		echo "--------------------------------------------"
		echo "作业/实验管理："
		echo -e "  [10] 布置作业/实验\t[11] 修改作业/实验"
		echo -e "  [12] 删除作业/实验\t[13] 显示作业/实验"
		echo "  [14] 查看学生作业/实验完成情况"
		echo "--------------------------------------------"
		echo "账号管理："
		echo -e "  [15] 修改密码\t\t[0] 退出账号"
	    echo "============================================"
        
		read teacher_choice #读取用户输入
		case $teacher_choice in #以下函数名与上面的功能一一对应
		1)add_sid $tid;;
		2)alter_sid $tid;;
		3)delete_sid $tid;;
		4)find_sid $tid;;
		5)add_courseinfo $tid;;
		6)alter_courseinfo $tid;;
		7)delete_courseinfo $tid;;
		8)show_courseinfo $tid;;
		9)check_course $tid;;
		10)assign_job $tid;;
		11)alter_job $tid;;
		12)delete_job $tid;;
		13)show_job $tid;;
		14)check_job $tid;;
		15)change_tpwd $tid;;
		0)back;;
		*)
			echo "无对应选项，请重新输入！"
			sleep 2
			clear;;
		esac
	done
}

#对某门课程，创建或导入学生帐户，根据学号查找学生帐号
#学生帐号的基本信息包括学号、姓名、专业、年级、班级，学生使用学号登录
#先输入学号，进行查找，若student库中不存在该学生，创建该学生账户（初始密码123456）；
#若已存在，则直接添加该课程的学习关系
#可以创建单个账号，也可以通过文件批量导入账号
function add_sid { 
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t添加学生账户[输入q返回]"
	echo "--------------------------------------------"
	echo "  对某门课程，创建或导入学生帐户"
	echo "============================================"
    echo -e "  [1]创建单个账号\t[2]批量导入账号"
	echo "============================================"
	while true
    do
	    read create_choice #读取用户输入
	    case $create_choice in
        1) #创建单个账号
		    read -p "课程号:" cid
			read -p "学生学号:" sid
			MYSQL=$(which mysql)
			check=$($MYSQL management -u test -Bse "select student_id from student where student_id = '$sid'")
            if [ ! -z $check ] #该学号对应账号账号存在
			then 
			    #显示该学号对应信息
			    $MYSQL management -u test -e "select student_id,name,major,grade,class from student where student_id = '$sid'"
				#将该学生账户加入该课程
				while true
				do
				    read -p "存在对应学生账户，是否将其加入该课程(Y/N):" op
				    case $op in
				    Y) #加入课程
				        MYSQL=$(which mysql)
			            statement="insert into take_course values('$sid','$cid')" #插入新记录
			            $MYSQL management -u test << EOF
			            $statement
EOF
                        if [ $? -eq 0 ]
					    then
					        echo "创建成功！"
					    else
					        echo "创建失败！"
					    fi
						break;;
				    y)
				        MYSQL=$(which mysql)
			            statement="insert into take_course values('$sid','$cid')" #插入新记录
			            $MYSQL management -u test << EOF
			            $statement
EOF
                        if [ $? -eq 0 ]
					    then
					        echo "创建成功！"
					    else
			    		    echo "创建失败！"
			    		fi
						break;;
				    N) #放弃加入课程
				        echo "放弃课程$cid中创建该学生账户$sid！"
						break;;
				    n)
				        echo "放弃课程$cid中创建该学生账户$sid！"
						break;;
				    *) #其他输入，报错，重新选择Y/N
		                echo "无对应操作，请重新输入！";;
				    esac
				done
			else #该学生账号不在库中，新建账号并加入课程
			    read -p "姓名：" name
				read -p "专业：" major
				read -p "年级：" grade
				read -p "班级：" class
				MYSQL=$(which mysql)
			    statement="insert into student values('$sid','$name','123456','$major','$grade','$class')" #插入student新记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
                statement="insert into take_course values('$sid','$cid')" #加入课程
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
				then
				    echo "创建成功！"
				else
			        echo "创建失败！"
			    fi
			fi;;
        2) #批量导入账号
		    read -p "课程号:" cid
		    echo "（批量创建文件中每行信息为该新建学生账号的学号、姓名、专业、年级、班级，#分隔）"
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
				sid=${arr[0]}
				name=${arr[1]}
				major=${arr[2]}
				grade=${arr[3]}
				class=${arr[4]}
				#插入新记录
				MYSQL=$(which mysql)
				check_id=$($MYSQL management -u test -Bse 'select student_id from student where student_id = '$sid'')
                check_name=$($MYSQL management -u test -Bse 'select name from student where student_id = '$sid'')
				check_major=$($MYSQL management -u test -Bse 'select major from student where student_id = '$sid'')
				check_grade=$($MYSQL management -u test -Bse 'select grade from student where student_id = '$sid'')
				check_class=$($MYSQL management -u test -Bse 'select class from student where student_id = '$sid'')
				if [ ! -z $check_id ] #该学号对应账号账号存在
			    then #检查信息
				    if [[ $name = $check_name ]] && [[ $major = $check_major ]] && [[ $grade = $check_grade ]] && [[ $class = $check_class ]]
					then #信息匹配，直接将该学生账户加入该课程
				        MYSQL=$(which mysql)
			            statement="insert into take_course values('$sid','$cid')" #插入新记录
			            $MYSQL management -u test << EOF
			            $statement
EOF
                        if [ $? -eq 0 ]
					    then
					        let "count+=1"
					    else
					        echo "$sid对应账号加入课程失败！"
					    fi
					else #信息不匹配，创建出错
					    echo "$sid对应账号信息不匹配，加入课程失败！"
					fi
				else #先创建该学生账号，再加入该课程
				    MYSQL=$(which mysql)
			        statement="insert into student values('$sid','$name','123456','$major','$grade','$class')" #插入student新记录
			        $MYSQL management -u test << EOF
			        $statement
EOF
                    if [ $? -ne 0 ]
				    then
			            echo "$sid对应账号创建失败！"
			        fi
                    statement="insert into take_course values('$sid','$cid')" #加入课程
			        $MYSQL management -u test << EOF
			        $statement
EOF
                    if [ $? -eq 0 ]
				    then
				        let "count+=1"
				    else
			            echo "$sid对应账号加入课程失败！"
			        fi
				fi
			done
			echo "成功在课程$cid中导入账号!";;
		q) #返回
		    teacher_menu $tid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#修改学生账号，包括修改学号、姓名、专业、年级、班级，重置密码（重置为初始密码123456）
function alter_sid {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改学生账号[输入q返回]"
	echo "============================================"
    echo -e "  [1]修改学号\t[2]修改姓名"
	echo -e "  [3]修改专业\t[4]修改年级"
	echo -e "  [5]修改班级\t[6]重置密码"
	echo "============================================"
	while true
    do
	    read alter_choice #读取用户输入
	    case $alter_choice in
        1) #修改学号
		    read -p "要修改的学号:" alter_sid
			read -p "新的学号:" new_sid #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set student_id='$new_sid' where student_id='$alter_sid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改学号成功！"
			else
			    echo "修改学号失败！"
			fi;;
        2) #修改姓名
		    read -p "要修改的学号:" alter_sid
			read -p "新的姓名:" new_name #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set name='$new_name' where student_id='$alter_sid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改姓名成功！"
			else
			    echo "修改姓名失败！"
			fi;;
		3) #修改专业
		    read -p "要修改的学号:" alter_sid
			read -p "新的专业:" new_major #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set major='$new_major' where student_id='$alter_sid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改专业成功！"
			else
			    echo "修改专业失败！"
			fi;;
		4) #修改年级
		    read -p "要修改的学号:" alter_sid
			read -p "新的年级:" new_grade #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set grade='$new_grade' where student_id='$alter_sid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改年级成功！"
			else
			    echo "修改年级失败！"
			fi;;
		5) #修改班级
		    read -p "要修改的学号:" alter_sid
			read -p "新的班级:" new_class #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set class='$new_class' where student_id='$alter_sid'" #修改记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改专业成功！"
			else
			    echo "修改专业失败！"
			fi;;
		6) #重置密码
		    read -p "要重置密码的学号:" alter_sid #输入相关信息
			MYSQL=$(which mysql)
			statement="update student set password='123456' where student_id='$alter_sid'" #修改记录
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
		    teacher_menu $tid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！"
		    sleep 2;;
        esac
    done
}

#删除学生账号，输入学生账号（学号），删除对应账号
#可以删除单个账号，也可以通过文件批量删除账号
#可以只在某课程中删除该账号（不影响该账号的其他课程），也可以彻底删除该账号（所有课程）
function delete_sid { 
	tid=$1
	clear
	echo "================================================================================="
	echo -e "\t\t删除学生账号[输入q返回]"
	echo "================================================================================="
    echo -e "  [1]指定课程删除单个账号\t\t[2]指定课程批量删除账号"
	echo -e "  [3]彻底删除单个账号（所有课程）\t[4]彻底批量删除账号（所有课程）"
	echo "================================================================================="

	while true
    do
	    read delete_choice #读取用户输入
	    case $delete_choice in
		1) #指定课程删除单个账号
		    read -p "课程号:" cid
			read -p "要删除的账号（学号）:" del_sid #输入相关信息
			MYSQL=$(which mysql)
			statement="delete from take_course where student_id='$del_sid' and course_id='$cid'" #删除记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi;;
        2) #指定课程批量删除账号
		    echo "（批量创建文件中每行信息为要删除账号的学号）"
			read -p "课程号:" cid
		    read -p "选择批量删除文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				del_sid=$LINE
				#删除记录
				MYSQL=$(which mysql)
			    statement="delete from take_course where student_id='$del_sid' and course_id='$cid'" #删除记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
			    then
			        let "count+=1" 
				else
			        echo "$del_sid对应账号删除失败！"
			    fi
			done
			echo "成功彻底删除账号!";;
        3) #彻底删除单个账号
		    read -p "要删除的账号（学号）:" del_sid #输入相关信息
			MYSQL=$(which mysql)
			statement="delete from student where student_id='$del_sid'" #删除记录
			$MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi;;
        4) #彻底批量删除账号
		    echo "（批量创建文件中每行信息为要删除账号的学号）"
		    read -p "选择批量删除文件：" filename #输入文件名（若非当前目录则必须包括路径）
			count=0 #计数
			#读取行内容
			cat $filename | while read LINE
			do
				del_sid=$LINE
				#删除记录
				MYSQL=$(which mysql)
			    statement="delete from student where student_id='$del_sid'" #删除记录
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
			    then
			        let "count+=1"
			     else
			        echo "$del_sid对应账号删除失败！"
			    fi
			done
			echo "成功彻底删除账号!";;
		q) #返回
		    teacher_menu $tid;;
        *) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#显示学生帐号
#在某课程中，显示所有学生信息或根据学号查找学生帐号，显示学生信息（学号、姓名、专业、年级、班级）
function find_sid {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t显示学生帐户[输入q返回]"
	echo "============================================"
    echo -e "  [1]显示课程所有学生信息\t[2]查找学生帐号"
	echo "============================================"
	read -p "课程编号:" cid
	while true
    do
	    read find_choice #读取用户输入
	    case $find_choice in
		1) #显示课程所有学生信息
		    MYSQL=$(which mysql)
			$MYSQL management -u test -e "select student_id,name,major,grade,class from student natural join take_course where course_id='$cid'"
		    ;;
		2) #根据学号查找学生帐号
		    read -p "要查找学生的学号:" sid
			MYSQL=$(which mysql)
			$MYSQL management -u test -e "select student_id,name,major,grade,class from student natural join take_course where course_id='$cid' and student_id='$sid'"
			if [ $# -eq 0 ]
			then
			    echo "$cid课程中不存在该学生！"
			fi;;
		q) #返回
		    teacher_menu $tid;;
		*) #其他输入，报错
		    echo "无对应选项，请重新输入！";;
        esac
    done
}

#发布课程信息
#课程信息是您想告知学生的关于您所教授的课程的信息,如课程通知、参考资料、课堂纪律等(notice)
function add_courseinfo {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t发布课程信息"
	echo "--------------------------------------------"
	echo "  您可以告知学生的关于您所教授的课程的信息"
	echo "  如：课程通知、参考资料、课堂纪律等"
	echo "============================================"
	while true
	do
	    read -p "需要发布课程信息的课程编号[输入q返回菜单]:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    read -p "需要发布信息的标题:" title
			read -p "需要发布信息的内容:" content
			MYSQL=$(which mysql)
	        statement="insert into notice(course_id,title,content) values('$cid','$title','$content')" #插入新记录,notice_no自动生成
	        $MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
				echo "发布成功！"
			else
				echo "发布失败！"
			fi
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
}

#修改已发布的课程信息
function alter_courseinfo {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改课程信息"
	echo "============================================"
	while true
	do
	    read -p "需要修改课程信息的课程编号[输入q返回菜单]:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    #先显示所有课程信息
		    $MYSQL management -u test -e "select * from notice where course_id='$cid'"
			#修改记录
		    read -p "需要修改的信息编号:" alter_nid
			read -p "新的标题:" new_title
			read -p "新的内容:" new_content
	        statement="update notice set title='$new_title',content='$new_content' where notice_no='$alter_nid'" 
	        $MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
}

#删除已发布的课程信息
function delete_courseinfo {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t删除课程信息"
	echo "============================================"
	while true
	do
	    read -p "需要删除课程信息的课程编号[输入q返回菜单]:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    #先显示所有课程信息
		    $MYSQL management -u test -e "select * from notice where course_id='$cid'"
			#修改记录
		    read -p "需要删除的信息编号:" del_nid
	        statement="delete from notice where notice_no='$del_nid'" 
	        $MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
}

#显示已发布的课程信息
function show_courseinfo {
	tid=$1
	clear
	while true
	do
	    read -p "课程编号:" cid
	    MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
	    then
            $MYSQL management -u test -e "select * from notice where course_id='$cid'"
	        break
		else
	        echo "您并不教授该课程，请重新选择课程！"
	    fi
	done
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    teacher_menu $tid
	fi
}

#查看该老师教授的所有课程
function check_course {
	tid=$1
	clear
	MYSQL=$(which mysql)
    $MYSQL management -u test -e "select course_id,title as course_title,description as course_description from course natural join teach_course where teacher_id='$tid'"
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    teacher_menu $tid
	fi
}

#发布作业/实验，作业信息由（布置）作业号、课程编号、布置老师工号、作业标题、作业要求组成
#老师只可发布所教授课程的作业、实验
#可以创建单个作业/实验，也可以通过文件批量导入作业/文件（但必须是同一课程，否则需要分成不同文件分次导入）
function assign_job {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t发布作业/实验[输入q返回]"
	echo "============================================"
    echo -e "  [1]创建单个作业/实验\t[2]批量导入作业/实验"
	echo "============================================"
	while true
	do
	    read -p "需发布作业/实验的课程编号:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    read -p "选择操作:" assign_choice #读取用户输入
	        case $assign_choice in 
		    1) #创建单个作业/实验
			    read -p "作业/实验标题:" title
			    read -p "作业/实验要求:" requirement
			    MYSQL=$(which mysql)
	            statement="insert into hw_assign(course_id,teacher_id,title,requirement) values('$cid','$tid','$title','$requirement')" #插入新记录,assign_no自动生成
			    $MYSQL management -u test << EOF
			    $statement
EOF
                if [ $? -eq 0 ]
			    then
			        echo "创建成功！"
			    else
			        echo "创建失败！"
			    fi;;
            2) #批量导入作业/实验
		        echo "（批量创建文件中每行信息为该新建作业/实验的标题、内容，#分隔）"
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
				    title=${arr[0]}
				    requirement=${arr[1]}
				    MYSQL=$(which mysql)
	                statement="insert into hw_assign(course_id,teacher_id,title,requirement) values('$cid','$tid','$title','$requirement')" #插入新记录,assign_no自动生成
			        $MYSQL management -u test << EOF
			        $statement
EOF
                    if [ $? -eq 0 ]
			        then
			            let "count+=1"
			        else
				        let errornum=count+1
			            echo "第$errornum个作业/实验创建出错！"
			        fi
			    done
			    echo "成功创建课程!";;
		    q) #返回
		        teacher_menu $tid;;
            *) #其他输入，报错
		        echo "无对应选项，请重新输入！";;
            esac  
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
}

#修改已布置的作业、实验信息，包括作业标题、作业内容
#老师只可修改所教授课程的作业、实验（包括教授该课程的其他老师布置的作业、实验）
function alter_job {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t修改作业/实验"
	echo "============================================"
	while true
	do
	    read -p "需要修改作业/实验的课程编号[输入q返回菜单]:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    #先显示该课程所有修改作业/实验
		    $MYSQL management -u test -e "select * from hw_assign where course_id='$cid'"
			#修改记录
		    read -p "需要修改的作业/实验编号:" alter_hwid
			read -p "新的作业/实验标题:" new_title
			read -p "新的作业/实验要求:" new_requirement
	        statement="update hw_assign set title='$new_title',requirement='$new_requirement' where assign_no='$alter_hwid'" 
	        $MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "修改成功！"
			else
			    echo "修改失败！"
			fi
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
}

#删除发布的作业
#老师只可删除所教授课程的作业、实验（包括教授该课程的其他老师布置的作业、实验）
function delete_job {
	tid=$1
	clear
	echo "============================================"
	echo -e "\t\t删除作业/实验"
	echo "============================================"
	while true
	do
	    read -p "需要删除作业/实验的课程编号[输入q返回菜单]:" cid
	    if [ $cid = "q" ] #返回菜单
		then
		    teacher_menu $tid
		fi
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
        then
		    #先显示该课程所有作业/实验
		    $MYSQL management -u test -e "select * from hw_assign where course_id='$cid'"
			#修改记录
		    read -p "需要删除的作业/实验编号:" del_hwid
	        statement="delete from hw_assign where assign_no='$del_hwid'" 
	        $MYSQL management -u test << EOF
			$statement
EOF
            if [ $? -eq 0 ]
			then
			    echo "删除成功！"
			else
			    echo "删除失败！"
			fi
        else 
            echo "您并不教授该课程，请重新选择课程！"
        fi
	done
} 

#显示已布置的作业、实验
#老师只可查看所教授课程的作业、实验（包括教授该课程的其他老师布置的作业、实验）
function show_job {
	tid=$1
	clear
	while true
	do
	    read -p "课程编号:" cid
	    MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
	    then
            $MYSQL management -u test -e "select * from hw_assign where course_id='$cid'"
	        break
		else
	        echo "您并不教授该课程，请重新选择课程！"
	    fi
	done
	echo "[输入q返回]"
	read char
	if [ $char = "q" ]
	then
	    teacher_menu $tid
	fi
}

#查看学生作业/实验完成情况
#老师只可查看所教授课程的作业、实验（包括教授该课程的其他老师布置的作业、实验）
#对于某一课程，可以查看某作业/实验的完成情况，显示信息包括作业应交人数、完成人数、未完成人数、完成率，选择作业编号又可查看已/未完成学生信息
#也可以查看某学生的所有作业/实验（该课程）的完成情况，显示信息包括布置作业的编号、标题、要求和上交作业的编号、标题、内容
function check_job {
    tid=$1
	clear
	echo "================================================================"
	echo -e "\t\t查看学生作业/实验完成情况[输入q返回]"
	echo "================================================================"
    echo -e "  [1]查看某作业/实验\t[2]查看某学生"
	echo "================================================================"
	while true
	do
	    read -p "要查看的课程编号:" cid
		if [ $cid = "q" ]
		then
		    teacher_menu $tid
		fi
		#检查权限（该老师是否教授该课程）
		MYSQL=$(which mysql)
        check=$($MYSQL management -u test -Bse "select course_id from teach_course where course_id = '$cid' and teacher_id='$tid'")
        if [ ! -z $check ] #该老师确实教授该课程
	    then
		    read -p "选择操作:" check_choice #读取用户输入
			case $check_choice in
		    1) #查看某作业/实验
		        $MYSQL management -u test -e "select * from hw_assign where course_id='$cid'" #先显示该课程所有作业/实验，便于选择
		        read -p "作业/实验编号:" hwid #输入相关信息
				all=$($MYSQL management -u test -Bse "select count(distinct student_id) from take_course where course_id = '$cid'") #该课程所有学生数
                finish=$($MYSQL management -u test -Bse "select count(distinct student_id) from hw_submit where assign_no = '$hwid'") #完成作业人数
                let not_finish=all-finish #未完成作业人数
			    finish_rate=$(echo "scale=4; $finish / $all" | bc) #计算完成率，结果保留四位小数
                echo -e "  应交人数：\t$all"
				echo -e "  已交人数：\t$finish"
				echo -e "  未完成人数：\t$not_finish"
				echo -e "  完成率：\t$finish_rate" #显示该作业/实验完成情况
				while true
				do
				    read -p "输入f/n可查看已完成/未完成学生信息[输入q退出]" more_choice
				    case $more_choice in
					f) #查看已完成学生信息
					    MYSQL=$(which mysql)
						$MYSQL management -u test -e "select student_id,name,major,grade,class from student natural join hw_submit where assign_no='$hwid'" #已完成学生信息
                        ;;
				    n) #查看未完成学生信息
					    MYSQL=$(which mysql)
						$MYSQL management -u test -e "select student_id,name,major,grade,class from student natural join take_course where course_id='$cid' and student_id not in(select student_id from student natural join hw_submit where assign_no='$hwid')" #未完成学生信息
                        ;;
                    q) #返回
		                teacher_menu $tid;;
                    *) #其他输入，报错
		                echo "无对应操作，请重新输入！";;
                    esac
				done;;
            2) #查看某学生
		        read -p "学生学号:" sid #输入相关信息
			    echo "学生$sid已完成的作业/实验："
			    MYSQL=$(which mysql)
				$MYSQL management -u test -e "select assign_no,hw_assign.title as assign_title,requirement,submit_no,hw_submit.submit_title as submit_title,content from hw_assign natural join hw_submit where student_id='$sid' and course_id='$cid'" #某学生已完成的作业
		        echo
                echo "学生$sid未完成的作业/实验："
			    MYSQL=$(which mysql)
				$MYSQL management -u test -e "select assign_no,hw_assign.title as assign_title,requirement from hw_assign where assign_no not in(select assign_no from hw_assign natural join hw_submit where student_id='$sid' and course_id='$cid')" #某学生未完成的作业
		        ;;
			q) #返回
		        teacher_menu $tid;;
            *) #其他输入，报错
		        echo "无对应选项，请重新输入！";;
            esac
		else
	        echo "您并不教授该课程，请重新选择课程！"
	    fi
	done
}

#教师用户修改密码
function change_tpwd {
	tid=$1
	while true
	do
	    read -s -p "原来的密码:" passwd #输入密码，输入的密码不显示在命令终端上
	    echo
		MYSQL=$(which mysql)
        apasswd=$($MYSQL management -u test -Bse 'select password from teacher where teacher_id = '$tid'')
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
		statement="update teacher set password='$new_passwd0' where teacher_id='$tid'" #修改记录
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
	teacher_menu $tid
}

#返回上级菜单
function back { 
	clear
	exit
}

tid=$1
teacher_menu $tid