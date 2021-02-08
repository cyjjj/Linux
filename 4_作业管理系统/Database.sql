mysql -u root -p
CREATE DATABASE management;
USE management;

CREATE TABLE admin (
admin_id varchar(10) not null,
name varchar(30),
password varchar(10),
primary key (admin_id));

CREATE TABLE teacher (
teacher_id varchar(10) not null,
name varchar(30),
password varchar(10),
department varchar(30),
primary key (teacher_id));

CREATE TABLE student (
student_id varchar(10) not null,
name varchar(30),
password varchar(10),
major varchar(30),
grade varchar(10),
class varchar(15),
primary key (student_id));

CREATE TABLE course (
course_id varchar(10) not null,
title varchar(30),
description varchar(50),
primary key(course_id));

#CASCADE：表示父表在进行更新和删除时，更新和删除子表相对应的记录;

CREATE TABLE teach_course (
teacher_id  varchar(10) not null,
course_id  varchar(10) not null,
primary key(teacher_id,course_id),
foreign key(teacher_id) references teacher(teacher_id) on delete cascade on update cascade,
foreign key(course_id) references course(course_id) on delete cascade on update cascade);

CREATE TABLE take_course (
student_id  varchar(10) not null,
course_id  varchar(10) not null,
primary key(student_id,course_id),
foreign key(student_id) references student(student_id) on delete cascade on update cascade,
foreign key(course_id) references course(course_id) on delete cascade on update cascade);

CREATE TABLE notice (
notice_no integer not null auto_increment,
course_id  varchar(10) not null,
title varchar(50),
content varchar(500),
primary key(notice_no),
foreign key(course_id) references course(course_id) on delete cascade on update cascade);

CREATE TABLE hw_assign (
assign_no integer not null auto_increment,
course_id  varchar(10),
teacher_id  varchar(10),
title varchar(50),
requirement varchar(200),
primary key(assign_no),
foreign key(teacher_id) references teacher(teacher_id) on delete cascade on update cascade,
foreign key(course_id) references course(course_id) on delete cascade on update cascade);

CREATE TABLE hw_submit (
submit_no integer not null auto_increment,
assign_no integer,
course_id varchar(10),
student_id  varchar(10),
submit_title varchar(50),
content varchar(500),
primary key(submit_no),
foreign key(assign_no) references hw_assign(assign_no) on delete cascade on update cascade,
foreign key(student_id) references student(student_id) on delete cascade on update cascade,
foreign key(course_id) references course(course_id) on delete cascade on update cascade);

GRANT SELECT,INSERT,DELETE,UPDATE ON management.* TO 'test'@'localhost' identified by '123456';
FLUSH PRIVILEGES; #立即生效权限

#创建账户
create user 'test'@'localhost' identified by  '123456';

#赋予权限
GRANT SELECT,INSERT,DELETE,UPDATE ON management.* TO 'test'@'localhost';

flush privileges;

SHOW GRANTS for 'test'@'localhost';

mysql management -u test

insert into admin values('10101','张三','123456');
insert into teacher values('21658','王云','123456','数学');
insert into teacher values('41248','Paul','123456','数学');
insert into teacher values('02175','John','123456','英语');
insert into student values('3180101465','刘畅','123456','计算机','大二','计科1812');
insert into student values('3160107312','刘强','123456','软工','大四','软工1603');
insert into student values('3170103901','Alice','123456','数学','大三','数学1701');
insert into course values('124a27','离散数学','数学必修');
insert into course values('43761b','托福口语','英语课');
insert into teach_course values('21658','124a27');
insert into teach_course values('02175','43761b');
insert into take_course values('3160107312','124a27');
insert into take_course values('3170103901','124a27');
insert into take_course values('3180101465','43761b');
insert into take_course values('3160107312','43761b');

21879 Lily CS
13325
21345
36546
1d2378
3182983012#Zhang#计算机#大二#计科1802
3190100122#Liu#计算机#大二#计科1804
select course_id,title as course_title,description as course_description,teacher_id,name as teacher_name,department as teacher_department from course natural join teach_course natural join teacher；
update admin set password='123456';

#该课程所有学生数
select count(distinct student_id) from take_course where course_id = '$cid'

#完成作业人数
select count(distinct student_id) from hw_submit where assign_no = '$hwid'

#已完成学生信息
select student_id,name,major,grade,class from student natural join hw_submit where assign_no='$hwid'

#未完成学生信息
select student_id,name,major,grade,class from student natural join take_course where course_id='$cid' and student_id not in(select student_id from student natural join hw_submit where assign_no='$hwid')

#某学生已完成的作业
select assign_no,hw_assign.title as assign_title,requirement,submit_no,hw_submit.title as submit_title,content from hw_assign natural join hw_submit where student_id='$sid' and course_id='$cid'

#某学生未完成的作业
select assign_no,hw_assign.title as assign_title,requirement from hw_assign where assign_no not in(select assign_no from hw_assign natural join hw_submit where student_id='$sid' and course_id='$cid')

select * from hw_assign natural join hw_submit where student_id='3160107312' and course_id='$124a27' and hw_assign.assign_no=hw_submit.assign_no