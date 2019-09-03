# ansible
## ansible 简介
### ansible 基本架构
![ansible架构](https://www.linuxprobe.com/wp-content/uploads/2018/05/Ansible1.png)
上图为ansible的基本架构，从上图可以了解到其由以下部分组成：
- 核心：ansible
- 核心模块（Core Modules）：这些都是ansible自带的模块
- 扩展模块（Custom Modules）：如果核心模块不足以完成某种功能，可以添加扩展模块
- 插件（Plugins）：完成模块功能的补充
- 剧本（Playbooks）：ansible的任务配置文件，将多个任务定义在剧本中，由ansible自动执行
- 连接插件（Connectior Plugins）：ansible基于连接插件连接到各个主机上，虽然ansible是使用ssh连接到各个主机的，但是它还支持其他的连接方法，所以需要有连接插件
- 主机群（Host Inventory）：定义ansible管理的主机

### ansible 工作原理
![ansible 工作原理1](https://www.linuxprobe.com/wp-content/uploads/2018/05/Ansible2.png)
![ansible 工作原理2](https://www.linuxprobe.com/wp-content/uploads/2018/05/Ansible3.png)
以上是从网上找到的两张ansible工作原理图，两张图基本都是在架构图的基本上进行的拓展。从上面的图上可以了解到：
1. 管理端支持local 、ssh、zeromq 三种方式连接被管理端，默认使用基于ssh的连接－－－这部分对应基本架构图中的连接模块；
2. 可以按应用类型等方式进行Host Inventory（主机群）分类，管理节点通过各类模块实现相应的操作－－－单个模块，单条命令的批量执行，我们可以称之为ad-hoc；
3. 管理节点可以通过playbooks 实现多个task的集合实现一类功能，如web服务的安装部署、数据库服务器的批量备份等。playbooks我们可以简单的理解为，系统通过组合多条ad-hoc操作的配置文件 。

## ansible 使用
### ansible 安装
```
[root@manager ~]# yum install ansible -y
```
### ansible 命令
ansible是指令核心部分，其主要用于执行ad-hoc命令，即单条命令。默认后面需要跟主机和选项部分，默认不指定模块时，使用的是command模块。
不过默认使用的模块是可以在ansible.cfg 中进行修改的。
```
ansible <host-pattern> [options]
```
ansible命令下的参数部分解释如下：
- 参数：
	- -a 'Arguments', --args='Arguments' 命令行参数
	- -m NAME, --module-name=NAME 执行模块的名字，默认使用 command 模块，所以如果是只执行单一命令可以不用 -m参数
	- -i PATH, --inventory=PATH 指定库存主机文件的路径,默认为/etc/ansible/hosts.
	- -u Username， --user=Username 执行用户，使用这个远程用户名而不是当前用户
	- -U --sud-user=SUDO_User sudo到哪个用户，默认为 root
	- -k --ask-pass 登录密码，提示输入SSH密码而不是假设基于密钥的验证
	- -K --ask-sudo-pass 提示密码使用sudo
	- -s --sudo sudo运行
	- -S --su 用 su 命令
	- -l --list 显示所支持的所有模块
	- -s --snippet 指定模块显示剧本片段
	- -f --forks=NUM 并行任务数。NUM被指定为一个整数,默认是5。 #ansible testhosts -a "/sbin/reboot" -f 10 重启testhosts组的所有机器，每次重启10台
	- --private-key=PRIVATE_KEY_FILE 私钥路径，使用这个文件来验证连接
	- -v --verbose 详细信息
	- all 针对hosts 定义的所有主机执行
	- -M MODULE_PATH, --module-path=MODULE_PATH 要执行的模块的路径，默认为/usr/share/ansible/
	- --list-hosts 只打印有哪些主机会执行这个 playbook 文件，不是实际执行该 playbook 文件
	- -o --one-line 压缩输出，摘要输出.尝试一切都在一行上输出。
	- -t Directory, --tree=Directory 将内容保存在该输出目录,结果保存在一个文件中在每台主机上。
	- -B 后台运行超时时间
	- -P 调查后台程序时间
	- -T Seconds, --timeout=Seconds 时间，单位秒s
	- -P NUM, --poll=NUM 调查背景工作每隔数秒。需要- b
	- -c Connection, --connection=Connection 连接类型使用。可能的选项是paramiko(SSH),SSH和地方。当地主要是用于crontab或启动。
	- --tags=TAGS 只执行指定标签的任务 例子:ansible-playbook test.yml --tags=copy 只执行标签为copy的那个任务
	- --list-hosts 只打印有哪些主机会执行这个 playbook 文件，不是实际执行该 playbook 文件
	- --list-tasks 列出所有将被执行的任务
	- -C, --check 只是测试一下会改变什么内容，不会真正去执行;相反,试图预测一些可能发生的变化
	- --syntax-check 执行语法检查的剧本,但不执行它
	- -l SUBSET, --limit=SUBSET 进一步限制所选主机/组模式 --limit=192.168.0.15 只对这个ip执行
	- --skip-tags=SKIP_TAGS 只运行戏剧和任务不匹配这些值的标签 --skip-tags=copy_start
	- -e EXTRA_VARS, --extra-vars=EXTRA_VARS 额外的变量设置为键=值或YAML / JSON
    ```
	#cat update.yml
	---
	- hosts: {{ hosts }}
	remote_user: {{ user }}
	..............
	#ansible-playbook update.yml --extra-vars "hosts=vipers user=admin" 传递{{hosts}}、{{user}}变量,hosts可以是 ip或组名
    ```
	- -l,--limit 对指定的 主机/组 执行任务 --limit=192.168.0.10，192.168.0.11 或 -l 192.168.0.10，192.168.0.11 只对这个2个ip执行任务
    
```
[root@manager ~]# cat ip
[nginx]
192.168.11.2
192.168.11.3

[root@manager ~]# ansible -i ip nginx -u root -m command -a 'date'
192.168.11.3 | CHANGED | rc=0 >>
Tue Sep  3 17:54:41 CST 2019

192.168.11.2 | CHANGED | rc=0 >>
Tue Sep  3 17:54:41 CST 2019
```



