#脚本名称：palindrome
#作者姓名：曹一佳；学号：3180101226
#忽略（删除）非字母，检测该符串是否为回文(palindrome)

#!/bin/bash
if [ $# -eq 0 ] #缺少参数（待检测的字符串）
then
    echo "Usage: $0 ordinary_file"
    exit 
fi

while [ $# -ne 0 ] #剩余待测字符串个数不为0时
do
    nword=`echo $1 | tr -c -d [:alpha:]` #去除所有非字母后的字符串
    rword=`echo $nword | rev` #将nword逆序
    if [ $nword = $rword ]; #字符串（去除所有非字母后）逆序前后相同，则为回文
    then
        echo "Palindrome"
    else
        echo "Not a palindrome"
    fi
    shift #参数左移一位，检测下一字符串
done