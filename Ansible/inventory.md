# inventory
## inventory 简介
ansible的hosts文件是存放被管理主机的，被管理主机比较少的情况下，直接在hosts中定义即可，但是以后很定会管理多台主机，而ansible可管理的主机集合就叫做inventory。在ansible中，描述你主机的默认方法是将它们列在一个文本文件中,这个文件叫inventory文件。

## inventory的行为参数
有时候我们需要在ansible inventory文件中描述我们的主机，我们需要定义主机名，以及ansible的ssh客户端可以连接到的端口(22,2222,22300)等，那么ansible将这些变量命名为inventory的行为参数
名称 | 默认值 | 描述
- | - | -
ansible_ssh_host | 主机的名字 | SSH目的主机名或IP
ansible_ssh_port | 22 | SSH目的端口
ansible_ssh_user | root | SSH登录使用的用户名
ansible_ssh_pass | none | SSH认证所使用的密码
host_key_checking | False | 当第一次远程主机时，提示输入yes/no，跳过此环节
ansible_connection | smart | ansible使用何种连接模式连接到主机
ansible_ssh_private_key_file | none | SSH认证所使用的私钥
ansible_shell_type | sh | 命令所使用的shell
ansible_python_interpreter | /usr/bin/python | 主机上的python解释器
```
[root@manager ~]# cat ip
[nginx]
192.168.11.2 ansible_ssh_user=root ansible_ssh_pass=1qaz!QAZ
192.168.11.3 ansible_ssh_user=root ansible_ssh_pass=1qaz!QAZ

```

## 主机和主机组定义方式
1. 直接定义一台或者2台server
```
#vim /etc/ansible/hosts 
192.168.100.10          
192.168.100.11
```
2. 定义一个组,可以是ip也可以是解析好的域名
```
[web]
192.168.100.10
192.168.100.11
[httpd]
192.168.100.12
192.168.100.13
```
3. 嵌套定义组 
```
[apache]
http1.test.com
http2.test.com
[nginx]
nginx1.test.com
nginx2.test.com
[webservers:children]
apache
nginx
```

## 主机变量和组变量
1. 主机变量
```
针对单主机的特性化要求，通过内置变量实现

[webservers]
web1.test.com http_port=80 ansible_ssh_port=12345
```
2. 群组变量
```
语法：[<group name>:vars] 在inventory中指定群组变量

[all:vars]
ntp_server=ntp.centos.com
 
[production]
test1
test2
test3
[production:vars]
db_primary_port=22
 
[groupservers]
web1.test.com
web2.test.com
[groupservers:vars]
ntp_server=ntp.test.com
admin_user=tom
```
3. 嵌套组和组变量 
```
[apache]
http1.test.com
http2.test.com
 
[nginx]
nginx1.test.com
nginx2.test.com
 
[webservers:children]
apache
nginx
 
[webservers:vars]
ntp_server=ntp.test.com
```
4. 变量分离

变量除了可以和inventory一起存储在INI配置文件中，也可以独立出来。
当我们要为非常多的主机和主机组分别设置不同的变量时，用如上的方式就显得比较笨拙了，就需要用到group_vars和host_vars 变量了。Ansible在运行任何yml文件之前，都会去搜索与Hosts文件同一个目录下的两个用于定义变量的目录group_vars和host_vars，所以，我们可以在这两个目录下放一些使用YAML语法编辑的定义变量的文件，并以对应的主机名和主机组名来命名这些文件，这样在运行ansible时
ansible会自动去这两个目录下读取针对不同主机和主机组的变量定义
```
比如对主机组group设置变量：

File: /etc/ansible/group_vars/group
admin_user: tom

对主机host1设置变量

File: /etc/ansible/host_vars/host1
admin_user: john
```
除此之外，我们还可以在group_vars和host_vars两个文件夹下定义all文件来一次性地为所有的主机组和主机定义变量。如何巧妙使用主机变量和组变量有些时候，我们在运行ansible任务时，可能需要从一台远程主机上面获取另一台远程主机的变量信息，这时一个神奇的变量hostvars可以帮我们实现这一个需求。变量hostvars包含了指定主机上面所定义的所有变量。

比如我们想获取host1上面的变量admin_user的内容，在任意主机上直接使用如下代码即可：
{{ hostvars['host1']['admin_user'] }}

Ansible提供了一些非常有用的内置变量，这里我们列举几个常用的：
- groups: 包含了所有Hosts文件里面主机组的一个列表
- group_names: 包含了当前主机所在的所有主机组名的一个列表
- inventory_hostname: 通过Hosts文件定义主机的主机名和ansible_home不一定相同
- play_hosts: 将会执行当前任务的所有主机

5. yml文件中使用变量的一个例子
```
---
- hosts: all
  user: root
  vars:
    GETURL:"http://192.168.24.14/sa"
    TARFILE:"sa"
    TMPPATCH:"/tmp"
    SHFILE:"os.sh" 
  tasks:
    - name: Download `TARFILE`.tar.gz package
      get_url: url="`GETURL`/`TARFILE`.tar.gz" dest=`TMPPATCH` sha256sum=b6f482b3c26422299f06524086d1f087e1d93f2748be18542945bca4c2df1569
      tags:
        -downsa 
    - name: tarzxvf `TARFILE`.tar.gz file
      shell: tar zxvf "`TMPPATCH`/`TARFILE`.tar.gz" -C `TMPPATCH`
      tags:
        -tarxsa
    - name: Run`SHFILE` script
      shell: "`TMPPATCH`/`TARFILE`/`SHFILE`"
      tags:
        -runsa
```