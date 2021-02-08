#脚本名称：dirsync
#作者姓名：曹一佳；学号：3180101226
#dirsync ~\dir1 ~\dir2  # ~\dir1为源目录，~\dir2为目标目录
#实现两个目录内的所有文件和子目录（递归所有的子目录）内容保持一致
#备份功能：目标目录将使用来自源目录的最新文件，新文件和新子目录进行升级，源目录将保持不变。dirsync程序能够实现增量备份。
#同步功能：两个方向上的旧文件都将被最新文件替换，新文件都将被双向复制。源目录被删除的文件和子目录，目标目录也要对应删除。

#!/bin/bash
if [ $# -ne 2 ] #要求输入两个参数，否则报错
then
	echo "Usage: $0 ordinary_file"
    exit 1
else
	sourcedir=$1 #源目录
	destdir=$2 #目标目录
fi

if [ ! -d $destdir ] #目标目录不存在
then
    mkdir $destdir #建立目标目录
fi

function Only_in_Source {
	diff -rq $sourcedir $destdir | grep $sourcedir | grep -v Files | cut -d' ' -f 3,4 | sed 's#: #/#'
	#只在源目录的文件或子目录
}

function Only_in_Dest {
	diff -rq $sourcedir $destdir | grep $destdir | grep -v Files | cut -d' ' -f 3,4 | sed 's#: #/#'
	#只在目标目录的文件或子目录
}

function Diff_files {
	diff -rq $sourcedir $destdir | grep Files | cut -d' ' -f 2,4 | sed 's# #=#'
    #源目录和目标目录中内容不同的同名文件，两者中间用=连接
	#若内容一样，时间不同，忽略
}

while [[ `Only_in_Source` || `Only_in_Dest` ]] #while循环保证所有文件特别是子目录下文件进行备份同步
do
    for src in `Only_in_Source` #只在源目录的文件或子目录，复制到目标目录
    do
	    if [ -d $src ] #若为子目录
	    then
		    echo $src >/tmp/onlysrc
		    sed -i "s#$sourcedir#$destdir#" /tmp/onlysrc #将子目录的路径替换成目标目录下
		    mkdir -p `cat /tmp/onlysrc` #在目标目录建立对应子目录
		    rm /tmp/onlysrc #删除过程中用到的临时文件
	    else #若非目录（文件）
		    echo $src >/tmp/onlysrcfile
		    sed "s#$sourcedir#$destdir#" /tmp/onlysrcfile >/tmp/onlysrcfile1 #将文件的路径替换成目标目录下	
		    cp `cat /tmp/onlysrcfile` `cat /tmp/onlysrcfile1` #把文件拷贝到目标目录
		    rm /tmp/onlysrcfile /tmp/onlysrcfile1 #删除过程中用到的临时文件
	    fi
    done

    for des in `Only_in_Dest` #只在目标目录的文件，即在源目录被删除
    do
        rm -rf $des #-r:递归删除目录及其内容；-f:忽略不存在的文件
		            #源目录被删除的文件和子目录，目标目录也要对应删除
    done
done

for df in `Diff_files` #内容被修改的文件
do
	fs=$(echo $df | cut -d= -f1) #源目录中文件
	fd=$(echo $df | cut -d= -f2) #目标目录中文件
	if [ $fs -nt $fd ] #源目录中文件比目标目录中文件新
	then
	   cp $fs $fd
	elif [ $fd -nt $fs ] #目标目录中文件比源目录中文件新
	then
	   cp $fd $fs
	fi
done

echo "Successfully synchronize between $1 (S) and $2 (D)！"
