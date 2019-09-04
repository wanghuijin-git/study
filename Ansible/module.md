# ansible 模块
## ansible常用模块介绍
查看所支持的模块，可以使用ansible-doc -l 查看
```
[root@manager ~]# ansible-doc -l
a10_server                                             Manage A10 Networks A...
a10_server_axapi3                                      Manage A10 Networks A...
a10_service_group                                      Manage A10 Networks A...
a10_virtual_server                                     Manage A10 Networks A...
aci_aaa_user                                           Manage AAA users (aaa...
aci_aaa_user_certificate                               Manage AAA user certi...
aci_access_port_block_to_access_port                   Manage port blocks of...
aci_access_port_to_interface_policy_leaf_profile       Manage Fabric interfa...
aci_access_sub_port_block_to_access_port               Manage sub port block...
...
```
ansible的每个模块用法可以使用#ansible-doc MOD / #ansible-doc -s MOD 来查看
```
[root@manager ~]# ansible-doc ping
> PING    (/usr/lib/python2.7/site-packages/ansible/modules/system/ping.py)

        A trivial test module, this module always returns `pong' on successful contact. It does not make sense in playbooks, but it is useful from `/usr/bin/ansible' to verify the ability to
        login and that a usable Python is configured. This is NOT ICMP ping, this is just a trivial test module that requires Python on the remote-node. For Windows targets, use the [win_ping]
        module instead. For Network targets, use the [net_ping] module instead.

  * This module is maintained by The Ansible Core Team
OPTIONS (= is mandatory):
...

[root@manager ~]# ansible-doc -s ping
- name: Try to connect to host, verify a usable python and return `pong' on success
  ping:
      data:                  # Data to return for the `ping' return value. If this parameter is set to `crash', the module will cause an exception.
```

## ansible常用模块
### setup 
用于收集远程主机的一些基本信息
```
[root@manager ~]# ansible -i ip nginx -m setup
```
### ping
用于判断远程客户端是否在线
```
[root@manager ~]# ansible -i ip nginx -m ping
192.168.11.2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```
### file
完成一些对文件的基本操作
- path：必须参数，用于指定要操作的文件或目录
- state ：此参数非常灵活，其对应的值需要根据情况设定。
    - directory：如果目录不存在，创建目录
    - file：指定文件是普通文件，如果文件不存在，也不会被创建
    - touch：创建文件，如果文件不存在，也会创建，如果存在，则更新最后更改时间
    - link：创建软连接
    - hard：创建硬链接
    - absent：删除文件、目录或取消链接文件
- src：当state设置为link或者hard时，表示我们想要创建一个软链或者硬链，指定链接的源文件
- force： : 当state=link的时候，可配合此参数强制创建链接文件，当force=yes时，表示强制创建链接文件
- owner：用于指定被操作文件的属主，属主对应的用户必须在远程主机中存在，否则会报错
- group：用于指定被操作文件的属组，属组对应的组必须在远程主机中存在，否则会报错
- mode：用于指定被操作文件的权限，想要将文件权限设置为”rw-r-x---“，可以使用mode=650进行设置，或者使用mode=0650
- recurse：当要操作的文件为目录，将recurse设置为yes，可以递归的修改目录中文件的属性
```
[root@manager ~]# ansible -i ip nginx -m file -a "path=/tmp/fstab state=link src=/etc/fstab owner=root group=root mode=0777"
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/fstab", 
    "gid": 0, 
    "group": "root", 
    "mode": "0777", 
    "owner": "root", 
    "size": 10, 
    "src": "/etc/fstab", 
    "state": "link", 
    "uid": 0
}

[root@manager ~]# ansible -i ip nginx -a "ls -l /tmp/fstab"
192.168.11.2 | CHANGED | rc=0 >>
lrwxrwxrwx 1 root root 10 Sep  3 22:38 /tmp/fstab -> /etc/fstab
```
### copy
向目标主机拷贝文件，类似于scp功能
- src：用于指定需要copy的文件或目录
- dest：用于指定文件将被拷贝到远程主机的哪个目录中，dest为必须参数
- content：当不使用src指定拷贝的文件时，可以使用content直接指定文件内容，src与content两个参数必有其一，否则会报错
- force : 当远程主机的目标路径中已经存在同名文件，并且与ansible主机中的文件内容不同时，是否强制覆盖，可选值有yes和no
- backup: 当远程主机的目标路径中已经存在同名文件，并且与ansible主机中的文件内容不同时，是否对远程主机的文件进行备份，可选值有yes和no
- owner: 指定文件拷贝到远程主机后的属主，但是远程主机上必须有对应的用户，否则会报错
- group: 指定文件拷贝到远程主机后的属组，但是远程主机上必须有对应的组，否则会报错
- mode: 指定文件拷贝到远程主机后的权限，将权限设置为”rw-r--r--“，则可以使用mode=0644表示，要在user对应的权限位上添加执行权限，则可以使用mode=u+x表示
```
[root@manager ~]# ansible -i ip nginx -m copy -a "src=/etc/fstab dest=/tmp/fstab2 owner=root group=root mode=o+x"
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "a6ff9e6c6d8e242c96a38c7b2d68328b660b890d", 
    "dest": "/tmp/fstab2", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "5cc50fe5be7a3e9ab3bce31ce16ce232", 
    "mode": "0645", 
    "owner": "root", 
    "size": 509, 
    "src": "/root/.ansible/tmp/ansible-tmp-1567522227.73-132760667419646/source", 
    "state": "file", 
    "uid": 0
}

[root@manager ~]# ansible -i ip nginx -a "ls -l /tmp/fstab2"
192.168.11.2 | CHANGED | rc=0 >>
-rw-r--r-x 1 root root 509 Sep  3 22:50 /tmp/fstab2
```
### commond
在远程主机上执行命令

> 类似作用的模块：
> - shell：远程命令支持管道符
> - script：把本地脚本传到远程服务器并上执行
> - raw：执行一些低级的，脏的ssh命令，不需要远程系统上的python

- free_from：需要执行的脚本,一般使用Ansible的-a参数代替
- chdir：执行命令前，切换到目录
- creates：当该文件存在时，不执行该步骤
- removes：当该文件不存在时，不执行该步骤
- executable：切换shell来执行命令，需要使用命令的绝对路径
- warn：如果在ansible.cfg中存在告警，如果设定了false，不会告警该行
```
[root@manager ~]# ansible -i ip nginx -m command -a 'chdir=/tmp creates=fstab ls fstab'
192.168.11.2 | SUCCESS | rc=0 >>
skipped, since fstab exists
```
### service
用于远程客户端各种服务管理，包括启动、停止、重启、重新加载等
- enabled：是否开机启动服务
- name：服务名称
- runlevel：服务启动级别
- arguments：服务命令行参数传递
- state：服务操作状态，状态包括started、stopped、restarted、reloaded
```
[root@manager ~]# ansible -i ip nginx -m service -a 'name=chronyd state=restarted enabled=yes'
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "enabled": true, 
    "name": "chronyd", 
    "state": "started", 
    "status": {
        "ActiveEnterTimestamp": "Thu 2019-08-29 23:50:45 CST", 
        ...(省略)
    }
}
```
### cron
管理远程主机中的计划任务，功能相当于 crontab 命令
- minute：此参数用于设置计划任务中分钟设定位的值
- hour：此参数用于设置计划任务中小时设定位的值
- day：此参数用于设置计划任务中日设定位的值
- month：此参数用于设置计划任务中月设定位的值
- weekday：此参数用于设置计划任务中周几设定位的值
- special_time：@reboot 表示重启时执行，@hourly 表示每小时执行一次，相当于设置成”0 0 * * *”，special_time 参数的可用值有 reboot(重启后)、yearly(每年)、annually(每年，与yearly相同)、monthly(每月)、weekly(每周)、daily(每天)、hourly(每时)
- user：此参数用于设置当前计划任务属于哪个用户
- job：此参数用于指定计划的任务中需要实际执行的命令或者脚本
- name：此参数用于设置计划任务的名称，计划任务的名称会在注释中显示
- state：当计划任务有名称时，我们可以根据名称修改或删除对应的任务，当删除计划任务时，需要将 state 的值设置为 absent
- disabled：当计划任务有名称时，我们可以根据名称使对应的任务”失效”（注释掉对应的任务）
- backup：如果此参数的值设置为 yes，那么当修改或者删除对应的计划任务时，会先对计划任务进行备份，然后再对计划任务进行修改或者删除，cron 模块会在远程主机的 /tmp 目录下创建备份文件，以 crontab 开头并且随机加入一些字符，具体的备份文件名称会在返回信息的 backup_file 字段中看到，推荐将此此参数设置为 yes
```
[root@manager ~]# ansible -i ip nginx -m cron -a 'special_time=reboot user=root job=nginx name="start nginx"'
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "envs": [], 
    "jobs": [
        "start nginx"
    ]
}

[root@manager ~]# ansible -i ip nginx -m cron -a 'name="start nginx" state=absent'
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "envs": [], 
    "jobs": []
}
```
### filesystem
在块设备上创建文件系统
- dev：目标块设备
- fstype：文件系统的类型
- opts：传递给mkfs命令的选项
- force：在一个已有文件系统的设备上强制创建
### mount
配置挂载点
- fstype：必选参数，挂载文件的类型
- name：必选参数，挂载点
- src：必选参数，要挂载的文件
- state：必选参数
- 	- present：只处理fstab中的配置
- 	- absent：删除挂载点
- 	- mounted：自动创建挂载点并挂载
- 	- umounted：卸载
- opts：传递给mount命令的参数
### yum
在远程主机上通过 yum 源管理软件包
- name：必须参数，用于指定需要管理的软件包，比如 nginx
- state：用于指定软件包的状态 ，默认值为present，表示确保软件包已经安装，除了present，其他可用- 值有installed、latest、absent、removed，其中installed与present等效，latest表示安装 yum中- 最新的版本，absent和removed等效，表示删除对应的软件包
- disable_gpg_check：用于禁用对 rpm 包的公钥 gpg 验证。默认值为 no，表示不禁用验证，设置为 - yes 表示禁用验证，即不验证包，直接安装。在对应的 yum 源没有开启 gpg 验证的情况下，需要将此参- 数的值设置为 yes，否则会报错而无法进行安装。
- enablerepo：用于指定安装软件包时临时启用的 yum 源
- disablerepo：用于指定安装软件包时临时禁用的 yum 源
> enablerepo 参数和 disablerepo 参数可以同时使用

### user
管理远程主机上的用户，比如创建用户、修改用户、删除用户、为用户创建密钥对等操作
- name：必须参数，用于指定要操作的用户名称，可以使用别名 user
- group：此参数用于指定用户所在的基本组
- gourps：此参数用于指定用户所在的附加组。注意，如果说用户已经存在并且已经拥有多个附加组，那么- 如果想要继续添加新的附加组，需要结合 append 参数使用，否则在默认情况下，当再次使用 groups 参- 数设置附加组时，用户原来的附加组会被覆盖
- append：如果用户原本就存在多个附加组，那么当使用 groups 参数设置附加组时，当前设置会覆盖原来的附加组设置，如果不想覆盖原来的附加组设置，需要结合 append 参数，将 append 设置为 yes，表示追加附加组到现有的附加组设置，append 默认值为 no。
- shell：此参数用于指定用户的默认 shell
- uid：此参数用于指定用户的 uid 号
- expires：此参数用于指定用户的过期时间
- comment：此参数用于指定用户的注释信息
- state：此参数用于指定用户是否存在于远程主机中，可选值有 present、absent，默认值为 present，- 表示用户需要存在，当设置为 absent 时表示删除用户
- remove：当 state 的值设置为 absent 时，表示要删除远程主机中的用户。但是在删除用户时，不会删除用户的家目录等信息，这是因为 remove 参数的默认值为 no，如果设置为yes，在删除用户的同时，会删除用户的家目录。当 state=absent 并且 remove=yes 时，相当于执行 “userdel --remove” 命令
- password：此参数用于指定用户的密码。但是这个密码不能是明文的密码。可以在 python 的命令提示符下输入如下命令，生成明文密码对应的加密字符串。
    ```
    import crypt; crypt.crypt('your_password')
    ```
- update_password：此参数有两个值可选，always 和 on_create
- generate_ssh_key：此参数默认值为 no，如果设置为 yes，表示为对应的用户生成 ssh 密钥对
- ssh_key_file：当 generate_ssh_key 参数的值为 yes 时，使用此参数自定义生成 ssh 私钥的路径和名称
- ssh_key_passphrase：当 generate_ssh_key 参数的值为 yes 时，在创建证书时，使用此参数设置私钥的密码
- ssh_key_type：当 generate_ssh_key 参数的值为 yes 时，在创建证书时，使用此参数设置密钥对的类型。默认密钥类型为 rsa
```
[root@manager ~]# ansible -i ip nginx -m user -a "name=test groups=root uid=2000 expires=99999"
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 2000, 
    "groups": "root", 
    "home": "/home/test", 
    "name": "test", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 2000
}

[root@manager ~]# ansible -i ip nginx -m user -a "name=test state=absent remove=yes"
192.168.11.2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "force": false, 
    "name": "test", 
    "remove": true, 
    "state": "absent"
}
```
### group
管理远程主机上的组
- name：必须参数，用于指定要操作的组名称
- state：用于指定组的状态，两个值可选，present，absent，默认为 present，设置为absent 表示删除- 组
- gid：用于指定组的gid
### synchronize
用于目录、文件的同步，主要基于rsync命令工具同步目录和文件
- compress：开启压缩，默认为开启
- archive：是否采用归档模式同步，保证源文件和目标文件属性一致
- checksum：是否效验
- dirs：以非递归的方式传送目录
- links：同步链接文件
- recursive：是否递归yes/no
- rsync_opts：使用rsync的参数
- copy_links：同步的时候是否复制链接
- delete：是否删除源中没有但目标存在的文件，使两边内容一样，以推送方为主
- src：源目录及文件
- dest：目标文件及目录
- dest_port：目标接收的端口
- rsync_path：服务的路径，指定rsync在远程服务器上执行
- rsync_remote_user：设置远程用户名
- –exclude=.log：忽略同步以.log结尾的文件，这个可以自定义忽略什么格式的文件，或者.txt等等都可以，但是由于这个是rsync命令的参- 数，所以必须和rsync_opts一起使用，比如rsync_opts=--exclude=.txt这种模式
- mode：同步的模式，rsync同步的方式push、pull，默认是推送push，从本机推送给远程主机，pull表示从远程主机上拿文件
```
[root@manager ~]# ansible -i ip nginx -m synchronize -a "archive=yes recursive=yes src=/tmp/ dest=/tmp/ delete=yes"
192.168.11.2 | CHANGED => {
    "changed": true, 
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --delete-after --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null --out-format=<<CHANGED>>%i %n%L /tmp/ 192.168.11.2:/tmp/", 
    "rc": 0, 
    "stdout_lines": [
        ".d..t...... ./", 
        "<f+++++++++ 1", 
        "<f+++++++++ 2", 
        ".d..t...... .ICE-unix/", 
        ".d..t...... .Test-unix/", 
        ".d..t...... .X11-unix/", 
        ...(省略)
    ]
}
```













