#脚本名称：countfile
#作者姓名：曹一佳；学号：3180101226
#统计指定目录下的普通文件、子目录及可执行文件的数目
#统计该目录下所有普通文件字节数总和

#!/bin/bash
if [ $# -eq 0 ] #缺省查询目录路径时，默认查询当前目录
then
    curpath=$PWD
    checkpath=$PWD
elif [ $# -ne 1 ] #传入超过1个目录路径
then
    echo "Usage: $0 ordinary_file"
    exit 1
else #目录的路径名字由参数传入
    curpath=$PWD #记录当前路径
    checkpath=$1 #传入的查询路径
    cd $1
fi
fcnt=0 #普通文件数目
dcnt=0 #子目录数目
xcnt=0 #可执行文件（包括普通文件、目录等各类文件）数目
bsum=0 #所有普通文件字节数总和
for i in $( ls )
do
    if [ -x $i ] #若为可执行文件
    then
        let "xcnt+=1"
    fi
    if [ -f $i ] #若为普通文件
    then
      let "fcnt+=1"
      set -- $(ls -l $i)
      size=$5 #该文件字节数
      let "bsum+=$size"
    elif [ -d $i ] && [ ! -L $i ] #若为子目录
    then
      let "dcnt+=1"
   fi
done
#输出统计结果
echo "in $checkpath :"
echo "There are $fcnt regular files."
echo "There are $dcnt directories."
echo "There are $xcnt executeable files/directories."
echo "Total Byte count of all regular files is $bsum."
cd $curpath #返回原来的目录