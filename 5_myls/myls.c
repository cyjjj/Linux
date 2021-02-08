//文件名称：myls.c
//作者姓名：曹一佳；学号：3180101226
//实现-a,-A,-l,-i,-d,-t,-F,-R,-g,-o,-1,-m,-Q,-n,-c,-u,-r等20个选项的功能

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h> 
#include <time.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>

#define MAX_PATH_LENGTH 200  //假设路径长度最多200个字符
#define MAX_STRLENGTH 200 //假设字符串长度最多200个字符
#define MAX_FILENUM 1000 //假设一个文件夹里最多只能有1000个文件

/* 选项状态变量 */
//表示选项的状态变量，为1则进行该操作，允许同时选择多个选项
int op_a = 0; //-a,列出目录下的一切文件，包含以.开头的隐含文件
int op_A = 0; //-A,显现除 "."和".."外的一切文件
int op_l = 0; //-l:列出文件的具体信息
int op_i = 0; //-i,输出文件的inode的索引信息
int op_d = 0; //-d,仅仅显示指定目录信息
int op_t = 0; //-t:以时刻排序，默认mtime（修改时间）
int op_F = 0; //-F,在每个文件名后附上一个字符以阐明该文件的类型
              //"*"表明可执行的一般文件;"/"表明目录;"@"表明符号连接;"|"表明FIFOs;"="表明sockets
int op_R = 0; //-R,列出一切子目录下的文件
int op_g = 0; //-g:显现文件的除拥有者外的具体信息
int op_o = 0; //-o:显现文件的除组信息外的具体信息
int op_1 = 0; //-1:一行只输出一个文件
int op_m = 0; //-m:横向输出文件名，并以","作分格符
int op_Q = 0; //-Q:把输出的文件名用双引号括起来
int op_n = 0; //-n:除显示用户和组ID而不是用户和组名称以外，和-l相同
int op_c = 0; //-c,with -lt: 显示并按ctime排序 (更改时间);with -l: 显示ctime，字典序
int op_u = 0; //-u,with -lt: 显示并按atime排序 (访问时间);with -l: 显示atime，字典序
int op_r = 0; //-r,逆序

int dir_flag = 0; //递归时第一个文件夹的标志，用于空行打印判断

/* 函数声明 */
void ls_attributes(struct stat buf); //打印文件具体信息(-l)
void list_single(char *path); //打印单个文件的信息
void list_dir(char *path, char *full_path); //用于打印目录文件的信息，包括处理递归遍历

/* 主函数 */
//int argc入参为命令行参数个数,char *argv[]入参为命令行参数数组。
int main(int argc, char *argv[])
{
    int i, j, para_num = 0;
    char para[MAX_PATH_LENGTH][MAX_PATH_LENGTH];//路径长度最多100个字符
    struct stat buf; //文件属性存储在结构体stat里
    char *tmp = "./";
    
    //解析传入的所有参数
    //若多个参数可以以"-al"格式或"-a -l"格式（例）输入
    for (i = 1; i < argc; i++) 
    {
        if (argv[i][0] == '-') //若为选项参数
        {
            for (j = 1; j < strlen(argv[i]); j++)
            {
                switch(argv[i][j]) //将对应状态变量置1
                {
                    case 'a': op_a = 1; break;
                    case 'A': op_A = 1; break;
                    case 'l': op_l = 1; break;
                    case 'i': op_i = 1; break;
                    case 'd': op_d = 1; break; 
                    case 't': op_t = 1; break;
                    case 'F': op_F = 1; break;
                    case 'R': op_R = 1; break;
                    case 'g': op_g = 1; break; 
                    case 'o': op_o = 1; break;
                    case '1': op_1 = 1; break;
                    case 'm': op_m = 1; break;
                    case 'Q': op_Q = 1; break;
                    case 'n': op_n = 1; break;
                    case 'c': op_c = 1; break;
                    case 'u': op_u = 1; break;
                    case 'r': op_r = 1; break;
                    default: printf("myls: invalid option -- '%c'\n", argv[i][j]); return 0;
                }
            }
        }
        else //文件或目录参数
        {
            strcpy(para[para_num++], argv[i]);
        }
    }
    //对指定目录或文件进行操作
    if (para_num == 0) //没有输入路径，则默认为当前目录
    {
        strcpy(para[para_num++], "./\0");
        if (op_d) //如果有-d选项
        {
            list_single(para[0]);
            printf("\n");
        }
        else
            list_dir(para[0], ".");
    }
    else
    {
        for (i = 0; i < para_num; i++)
        {
            if (lstat(para[i], &buf) == -1) //如果目标文件或目录不存在，报错
            {
                printf("myls: cannot access '%s': No such file or directory\n", para[i]);
                return 1;
            }
            if (S_ISDIR(buf.st_mode)) //是目录
            {
                if (op_d) //有-d选项
                {
                    list_single(para[i]);
                    printf("\n");
                }
                else
                    list_dir(para[i], para[i]);
            }
            else //不是目录，打印单个文件信息
            {
                list_single(para[i]);
            }
        }
    }
    return 0;
}

void list_single(char *path) //-d
{
    int i, j = 0, k = 0;
    int len;
    int flag = 0; //第一个文件标志，用于","打印判断
    char name[MAX_STRLENGTH], tmp[MAX_STRLENGTH];
    struct stat buf;
    if (lstat(path, &buf) == -1)
    {
        printf("myls: cannot access '%s': No such file or directory\n", path);
        return;
    }
    //首先从传入的路径中获取文件名
    len = strlen(path);
    if (path[len - 1] == '/')
        len--;
    for (i = len - 1; i != '/' && i >= 0; i--, j++)
        tmp[j] = path[i];
    for (i = j - 1; i >= 0; i--, k++)
        name[k] = tmp[i];
    name[k] = '\0';

    if (op_F == 1) //-F
    {
        if (S_ISDIR(buf.st_mode)) //目录
        {
            name[k] = '/';
            name[k + 1] = '\0';
        }
        else if (S_ISLNK(buf.st_mode))//符号链接
        { 
            name[k] = '@';
            name[k + 1] = '\0';
        }
        else if (S_ISSOCK(buf.st_mode)) //socket文件
        {
            name[k] = '=';
            name[k + 1] = '\0';
        }
        else if (S_ISFIFO(buf.st_mode)) //管道文件
        {
            name[k] = '|';
            name[k + 1] = '\0';
        }
        else if (buf.st_mode & S_IXUSR) //可执行的一般文件
        {
            name[k] = '*';
            name[k + 1] = '\0';
        }
    }
    //打印文件信息
    if (!op_a && !op_A && !op_l && !op_g && !op_o) //没有-a和-A,没有-l,-g,-o
    {
        if (name[0] != '.') //不打印包含以.开头的隐含文件
        {
            if(flag && op_m) //-m:横向输出文件名，并以","作分格符
                printf(", ");
            if(flag == 0) flag = 1;
            if (op_i == 1) //-i
                printf("%6d ", buf.st_ino); //打印inode号
            if(op_Q) //-Q:把输出的文件名用双引号括起来
                printf("\"%s\"", name);
            else
                printf("%s", name);
            if(!op_m) printf("\t");
            if(op_i) printf("\t"); //有inode，一个tab难以对齐
            if(op_1) printf("\n");//-1:一行只输出一个文件
        }
    }
    else if (!op_a && !op_A && (op_l || op_g || op_o)) //没有-a和-A,有-l或-g或-o
    {
        if (name[0] != '.') //不打印包含以.开头的隐含文件
        {
            if (op_i == 1) //-i
                printf("%6d ", buf.st_ino); //打印inode号
            ls_attributes(buf);
            if(op_Q) //-Q:把输出的文件名用双引号括起来
                printf("\"%s\"", name);
            else
                printf("%s", name);
            printf("\n");
        }
    }
    else if ((op_a || op_A) && !op_l && !op_g && !op_o) //有-a或-A，没有-A和-l,-g,-o
    {
        if(flag && op_m) //-m:横向输出文件名，并以","作分格符
            printf(", ");
        if(flag == 0) flag = 1;
        if(op_A) //不显示 "."和".."
        {
            if (name[0] == '.' && (name[1] == '\0' || name[1] == '.'))
                return;
        }
        //打印包含以.开头的隐含文件
        if (op_i == 1) //-i
            printf("%6d ", buf.st_ino); //打印inode号
        if(op_Q) //-Q:把输出的文件名用双引号括起来
                printf("\"%s\"", name);
            else
                printf("%s", name);
        if(!op_m) printf("\t");
        if(op_i) printf("\t"); //有inode，一个tab难以对齐
        if(op_1) printf("\n");//-1:一行只输出一个文件
    }
    else if ((op_a || op_A) && (op_l || op_g || op_o))  //有-a或-A，有-l或-g或-o
    {
        if(op_A) //不显示 "."和".."
        {
            if (name[0] == '.' && (name[1] == '\0' || name[1] == '.'))
                return;
        }
        //打印包含以.开头的隐含文件
        if (op_i == 1) //-i
            printf("%6d ", buf.st_ino); //打印inode号
        ls_attributes(buf);
        if(op_Q) //-Q:把输出的文件名用双引号括起来
                printf("\"%s\"", name);
            else
                printf("%s", name);
        printf("\n");
    }
}

void list_dir(char *path, char *full_path)
{
    DIR *dp;
    struct dirent *entry;
    struct stat buf, buf1;
    char filename[MAX_FILENUM][MAX_STRLENGTH];
    char tmp[MAX_STRLENGTH];
    char path_final[MAX_PATH_LENGTH]; //递归时完整的目录路径
    int num = 0; //文件个数
    int i, j;

    if ((dp = opendir(path)) == NULL) //检查目录是否存在
    {
        printf("myls: cannot access '%s': No such file or directory\n", path);
        return;
    }
    chdir(path); //进入目录
    while ((entry = readdir(dp)) != NULL) //获取文件名
    { 
        strcpy(filename[num], entry->d_name);
        num++;
    }
    //排序,insert sort
    if (!op_t) //按字典序给文件名排序
    {
        for (i = 1; i < num; i++)
        {
            strcpy(tmp, filename[i]);
            if(!op_r)
            {
                for (j = i; j > 0 && strcmp(filename[j - 1], tmp) > 0; j--)
                strcpy(filename[j], filename[j - 1]);
            }
            else
            {
                for (j = i; j > 0 && strcmp(filename[j - 1], tmp) < 0; j--)
                strcpy(filename[j], filename[j - 1]);
            }
            
            strcpy(filename[j], tmp);
        }
    }
    else //-t,按最后修改时间排序
    {
        for (i = 1; i < num; i++)
        {
            strcpy(tmp, filename[i]);
            lstat(filename[i - 1], &buf);
            lstat(tmp, &buf1);
            if(op_c) //按ctime排序
            {
                if(!op_r)
                {
                    for (j = i; j > 0 && buf.st_ctime - buf1.st_ctime < 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
                else
                {
                   for (j = i; j > 0 && buf.st_ctime - buf1.st_ctime > 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
            }
            else if(op_u) //按atime排序
            {
                if(!op_r)
                {
                    for (j = i; j > 0 && buf.st_atime - buf1.st_atime < 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
                else
                {
                   for (j = i; j > 0 && buf.st_atime - buf1.st_atime > 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
            }
            else //按mtime排序
            {
                if(!op_r)
                {
                    for (j = i; j > 0 && buf.st_mtime - buf1.st_mtime < 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
                else
                {
                   for (j = i; j > 0 && buf.st_mtime - buf1.st_mtime > 0; j--)
                    {
                        strcpy(filename[j], filename[j - 1]);
                        lstat(filename[j - 2], &buf);
                    }
                }
            }
            strcpy(filename[j], tmp);
        }
    }
    closedir(dp);

    //打印文件信息
    if(dir_flag) printf("\n");
    if(dir_flag == 0) dir_flag = 1;
    dp = opendir(path); //重新打开目录
    if(op_R)
        printf("%s:\n", full_path); //打印路径
    for (i = 0; i < num; i++)
    {
        list_single(filename[i]); //打印当前目录下的文件信息
        if(!op_l && !op_g && !op_o && i && (i+1) % 6 == 0) printf("\n"); //6个一行
    }
    printf("\n");
    if (op_R) //-R,递归,列出一切子目录下的文件
    {
        for (i = 0; i < num; i++)
        {
            strcpy(path_final, full_path);
            lstat(filename[i], &buf);
            if (S_ISDIR(buf.st_mode)) //如果是目录，则进行递归遍历
            {   
                if (strcmp(".", filename[i]) == 0 || strcmp("..", filename[i]) == 0) 
                    continue; //忽略"."和".."
                strcat(path_final, "/");
                strcat(path_final, filename[i]); //获取完整路径
                list_dir(filename[i], path_final); //递归遍历目录
                chdir("..");//返回上一级目录
            }
        }
    }
    closedir(dp);
}

void ls_attributes(struct stat buf)
{
    struct passwd *pwd; //stat中用户名
    struct group *grp; //stat中组名
    char time[30]; //时间信息
    //打印文件类型
    if (S_ISDIR(buf.st_mode)) //目录
        printf("d");
    else if (S_ISLNK(buf.st_mode)) //符号链接
        printf("l");
    else if (S_ISREG(buf.st_mode)) //普通文件
        printf("-");
    else if (S_ISCHR(buf.st_mode)) //字符设备
        printf("c");
    else if (S_ISBLK(buf.st_mode)) //块设备
        printf("b");
    else if (S_ISFIFO(buf.st_mode)) //管道文件
        printf("f");
    else if (S_ISSOCK(buf.st_mode)) //socket文件
        printf("s");
    //打印user权限
    if (buf.st_mode & S_IRUSR) //r
        printf("r");
    else
        printf("-");
    if (buf.st_mode & S_IWUSR) //w
        printf("w");
    else
        printf("-");
    if (buf.st_mode & S_IXUSR) //x
        printf("x");
    else
        printf("-");
    //打印group权限
    if (buf.st_mode & S_IRGRP) //r
        printf("r");
    else
        printf("-");
    if (buf.st_mode & S_IWGRP) //w
        printf("w");
    else
        printf("-");
    if (buf.st_mode & S_IXGRP) //x
        printf("x");
    else
        printf("-");
    //打印others权限
    if (buf.st_mode & S_IROTH) //r
        printf("r");
    else
        printf("-");
    if (buf.st_mode & S_IWOTH) //w
        printf("w");
    else
        printf("-");
    if (buf.st_mode & S_IXOTH) //x
        printf("x");
    else
        printf("-");

    printf(" ");
    //打印链接数
    printf("%4d", buf.st_nlink);
    printf(" ");
    //打印用户名与组名
    pwd = getpwuid(buf.st_uid);
    grp = getgrgid(buf.st_gid);
    if(!op_g) //-g不显示用户名
    {
        if(!op_n) //-n显示用户和组ID
            printf("%-6s ", pwd->pw_name);
        else
            printf("%-6s ",buf.st_uid);
    }
    if(!op_o) //-o不显示组信息
    {
        if(!op_n) //-n显示用户和组ID
            printf("%-6s ", grp->gr_name);
        else
            printf("%-6s ",buf.st_gid);
    }
    //打印文件的大小
    printf("%6d", buf.st_size);
    //打印时间
    if(op_c)
       strcpy(time, ctime(&buf.st_ctime));
    else if(op_u)
       strcpy(time, ctime(&buf.st_atime));
    else
       strcpy(time, ctime(&buf.st_mtime)); //默认mtime(最后修改时间),ctime函数把日期和时间转换为字符串
    time[strlen(time) - 1] = '\0'; //去掉'\n'
    printf(" ");
    printf("%s", time);
    printf(" ");
}