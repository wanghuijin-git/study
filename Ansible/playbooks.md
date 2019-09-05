# playbooks
Playbooks 是 Ansible的配置,部署,编排语言.他们可以被描述为一个需要希望远程主机执行命令的方案,或者一组IT程序运行的命令集合

Playbooks 的格式是YAML（详见:YAML 语法）,语法做到最小化,意在避免 playbooks 成为一种编程语言或是脚本,但它也并不是一个配置模型或过程的模型

playbook语法有如下特性：
- 以 --- (三个减号)开始，必须顶行写；
- 次行开始写Playbook的内容，但是一般要求写明该playbook的功能；
- 严格缩进，并且不能用Tab键缩进；
- 缩进级别必须是一致的，同样的缩进代表同样的级别，程序判别配置的级别是通过缩进结合换行来实的；
- K/V的值可同行写，也可换行写。同行使用 :分隔，换行写需要以 - 分隔；
```
---
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: write the apache config file
    template: src=/srv/httpd.j2 dest=/etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service: name=httpd state=started
  handlers:
    - name: restart apache
      service: name=httpd state=restarted
```
## playbook基础
核心元素：
- Tasks：任务，由模板定义的操作列表
- Variables：变量
- Templates：模板，即使用模板语法的文件
- Handlers：处理器 ，当某条件满足时，触发执行的操作
- Roles：角色

### 主机与用户
```
---
- hosts: webservers     # 指定主机组，可以是一个或多个组
  remote_user: yourname     # 指定远程主机执行的用户名
  sudo: yes         # 可以是全局sudo，也可以放在任务内sudo
  sudo_user: postgres   # 指定远程主机sudo到哪个用户
    tasks:
    - service: name=nginx state=started
#     sudo: yes
```
### 变量
#### vars
1. yaml文件中定义变量  

playbook中用vars关键字声明变量，变量定义 **变量名: 变量值**  

变量引用 ：{{ 变量名 }}
```
[root@LOCALHOST ~]# cat yaml/vars.yaml 
---
- hosts: compute-node
  remote_user: root
  vars:
    pkg: httpd        # 定义变量
  tasks:
    - name: install httpd service
      yum: name={{ pkg }} state=installed     # 引用变量
```
2. 引用外部变量
- 在命令行使用--extra-vars参数赋值变量
```
[root@LOCALHOST ~]# cat yaml/extra_vars.yaml 
---
- hosts: control-node
  remote_user: root
  tasks:
    - name: create a file
      file:
        path: /tmp/{{ filename }}    # 引用外部变量
        mode: 0644
        state: touch
# 命令行使用--extra_vars传入变量
[root@LOCALHOST ~]# ansible-playbook yaml/extra_vars.yaml --extra-vars "filename=temp.txt"
```
> --extra_vars "变量名=变量值"

3. 资产清单（inventory）中定义的变量

在/etc/ansible/hosts文件中定义的变量
```
[root@LOCALHOST ~]# cat /etc/ansible/hosts
[load-node]
openstack-load1 
openstack-load2

[control-node]
openstack-control1 filename=control1.txt    # 主机变量
openstack-control2 filename=control2.txt

[openstack:children]
load-node
control-node

[openstack:vars]
issue="Hello, World"    # 组变量
```
> 注意：组变量定义时，不要落下关键字vars，[组名:vars]。  
在playbook中引用{{ 变量名 }}即可。

#### vars_files
单独的variables文件
```
[root@manager playbooks]# vim variables 
port:80
http:apache

[root@manager playbooks]# vim test.yml
- hosts: all
  user: root
  vars_files:
    - variables

  tasks:
    - name: print IP
      tempalte: src=files/test1.txt dest=/tmp/test1.txt
```
#### vars_prompt
```
[root@manager playbooks]# vim test.yml
- hosts: all
  user: root
  vars_prompt:
    - name: nginx
      prompt: please enter something
      private: no   # 输入的值是否不打印，no为打印，yes为不打印

  tasks:
    - name: print IP
      tempalte: src=files/test1.txt dest=/tmp/test1.txt
```
#### fact
ansible有一个模块叫setup，用于获取远程主机的相关信息，并可以将这些信息作为变量在playbook里进行调用。而setup模块获取这些信息的方法就是依赖于fact

ansible内置了一些固定的主机变量名，在inventory中定义其值，如下：
```
ansible_ssh_host
      将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.

ansible_ssh_port
      ssh端口号.如果不是默认的端口号,通过此变量设置.

ansible_ssh_user
      默认的 ssh 用户名

ansible_ssh_pass
      ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)

ansible_sudo_pass
      sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)

ansible_sudo_exe (new in version 1.8)
      sudo 命令路径(适用于1.8及以上版本)

ansible_connection
      与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.

ansible_ssh_private_key_file
      ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.

ansible_shell_type
      目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.

ansible_python_interpreter
      目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如  \*BSD, 或者 /usr/bin/python
      不是 2.X 版本的 Python.我们不使用 "/usr/bin/env" 机制,因为这要求远程用户的路径设置正确,且要求 "python" 可执行程序名不可为 python以外的名字(实际有可能名为python26).

      与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径....
```
1. 手动设置fact

ansible除了能获取到预定义的fact的内容,还支持手动为某个主机定制fact。称之为本地fact。本地fact默认存放于被控端的/etc/ansible/facts.d目录下，如果文件为ini格式或者json格式，ansible会自动识别。以这种形式加载的fact是key为ansible_local的特殊变量。

下面是一个简单的示例，在ansibler主控端定义一个ini格式的custom.fact文件内容如下：
```
[general]
package = httpd
service = httpd
state = started
```
然后我们编写一个playbook文件名为setup_facts.yml内容如下：
```
---
- name: Install remote facts
  hosts: test
  vars: 
    remote_dir: /etc/ansible/facts.d
    facts_file: custom.fact
  tasks:
    - name: Create the remote directory
      file:
        state: directory
        recurse: yes
        path: "{{ remote_dir }}"
    - name: Install the new facts
      copy:
        src: "{{ facts_file }}"
        dest: "{{ remote_dir }}"
```
执行该playbook，完成facts的推送：
```
ansible-playbook setup_facts.yml
```
此时，我们可以在被控端看到新的facts已经生成：
```
# ansible test -m setup        
10.1.61.187 | SUCCESS => {
    "ansible_facts": {
    
        ...output omitted...
        
        "ansible_local": {
            "custom": {
                "general": {
                    "package": "httpd",
                    "service": "httpd",
                    "state": "started"
                }
            }
        },

        ...output omitted...
}
```
我们可以写一个简单的playbook来使用这些facts：
```
- name: Install Apache and starts the service
  hosts: test
  tasks:
    - name: Install the required package
      yum: 
        name: "{{ ansible_facts.ansible_local.custom.general.package }}"
        state: latest
    - name: Start the service
      service: 
        name: "{{ ansible_facts.ansible_local.custom.general.service }}"
        state: "{{ ansible_facts.ansible_local.custom.general.state }}"
```
2. 使用set_fact模块定义新的变量

set_fact模块可以自定义facts，这些自定义的facts可以通过template或者变量的方式在playbook中使用。如果你想要获取一个进程使用的内存的百分比，则必须通过set_fact来进行计算之后得出其值，并将其值在playbook中引用。

下面是一个set_fact模块的应用示例：
```
- name: set_fact example
  hosts: test
  tasks:
    - name: Calculate InnoDB buffer pool size
      set_fact: innodb_buffer_pool_size_mb="{{ ansible_memtotal_mb / 2 |int }}"
      
    - debug: var=innodb_buffer_pool_size_mb
```
3. 启用fact缓存
如果在play中需要引入fact，则可以开启fact缓存。fact缓存目前支持三种存储方式，分别为JSON、memcached、redis。
- Json文件fact缓存后端  

使用JSON文件作为fact缓存后端的时候，ansible将会把采集的fact写入到控制主机的文件中。  

ansible.cfg配置如下：
```
[defaults]
gathering = smart
#缓存时间，单位为秒
fact_caching_timeout = 86400    
fact_caching = jsonfile
#指定ansible包含fact的json文件位置，如果目录不存在，会自动创建
fact_caching_connection = /tmp/ansible_fact_cache    
```
- Redis fact缓存后端

使用redis作为fact缓存后端，需要在控制主机上安装redis服务并保持运行。需要安装python操作redis的软件包。  

ansible.cfg配置如下：
```
[defaults]
gathering = smart
fact_caching_timeout = 86400 
fact_caching = redis
```
- Memcached fact缓存后端

使用memcached作为fact缓存后端，需要在控制主机上安装Memcached服务并保持运行，需要安装python操作memcached的软件包。

ansible.cfg配置如下：
```
[defaults]
gathering = smart
fact_caching_timeout = 86400 
fact_caching = memcached
```
4. 关闭fact
如果不想从fact中获取变量，或者说整个playbook当中都没有使用到fact变量，可以通过如下方法关闭fact以提升执行效率：
```
- hosts: test
  gather_facts: no
```
也可以在ansible.cfg中添加如下配置：
```
[defaults]
gathering = explicit
```

#### 注册变量
在playbook中用**register**关键字定义一个变量，这个变量的值就是当前任务执行的输出结果
```
[root@LOCALHOST ~]# cat yaml/reg_vars.yaml 
---
- hosts: load-node
  remote_user: root
  tasks:
    - name: show date
      shell: "/bin/date"
      register: date        # 注册一个变量
    - name: Record time log
      shell: "echo {{ date.stdout }} > /tmp/date.log"
```
> 引用注册变量要用 {{ date.stdout }}表示标准输出
```
[root@openstack-load1 ~]# cat /tmp/date.log 
2018年 03月 29日 星期四 15:52:01 CST
```
> 如果直接{{ date }}这样引用，则文件中写入的是如下内容：
```
{stderr_lines: [], uchanged: True, uend: u2018-03-29 15:49:52.609894, failed: False, ustdout: u2018\u5e74 03\u6708 29\u65e5 \u661f\u671f\u56db 15:49:52 CST, ucmd: u/bin/date, urc: 0, ustart: u2018-03-29 15:49:52.602918, ustderr: u, udelta: u0:00:00.006976, stdout_lines: [u2018\u5e74 03\u6708 29\u65e5 \u661f\u671f\u56db 15:49:52 CST]}
```
#### 变量优先级
1. 在命令行中定义的变量（即用-e或--extra-vars定义的变量）；
2. 在Inventory中定义的连接变量（比如：ansible_ssh_user）;
3. 大多数的其他变量（命令行转换、play中的变量、included的变量、role中的变量等）；
4. 在Inventory中定义的其他变量；
5. Facts变量；
6. “Role”默认变量，这个是默认的值，很容易丧失优先权。

### Tasks 列表
下面是一种基本的 task 的定义,service moudle 使用 key=value 格式的参数,这也是大多数 module 使用的参数格式:
```
tasks:
  - name: make sure apache is running
    service: name=httpd state=running
```
比较特别的两个 modudle 是 command 和 shell ,它们不使用 key=value 格式的参数,而是这样:
```
tasks:
  - name: disable selinux
    command: /sbin/setenforce 0
```
使用 command module 和 shell module 时,我们需要关心返回码信息,如果有一条命令,它的成功执行的返回码不是0, 你或许希望这样做:
```
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand || /bin/true
```
或者是这样:
```
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_errors: True
```
如果 action 行看起来太长,你可以使用 space（空格） 或者 indent（缩进） 隔开连续的一行:
```
tasks:
  - name: Copy ansible inventory file to client
    copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
            owner=root group=root mode=0644
```
在 action 行中可以使用变量.假设在 ‘vars’ 那里定义了一个变量 ‘vhost’ ,可以这样使用它:
```
tasks:
  - name: create a virtual host file for {{ vhost }}
    template: src=somefile.j2 dest=/etc/httpd/conf.d/{{ vhost }}
```
### Handlers
在需要被监控的任务（tasks）中定义一个notify，只有当这个任务被执行时，才会触发notify对应的handlers去执行相应操作。
```
[root@LOCALHOST ~]# cat yaml/httpd.yaml 
---
- hosts: control-node
  remote_user: root
  vars:
    - pkg: httpd
  tasks:
    - name: "install httpd package."
      yum: name={{ pkg }}  state=installed
    - name: "copy httpd configure file to remote host."
      copy: src=/root/conf/httpd.conf dest=/etc/httpd/conf/httpd.conf
      notify: restart httpd
    - name: "boot httpd service."
      service: name=httpd state=started
  handlers:
    - name: restart httpd
      service: name=httpd state=restarted
```
> 在使用handlers的过程中，有以下几点需要注意：
> - handlers只有在其所在的任务被执行时，都会被运行；
> - handlers只会在Play的末尾运行一次；如果想在一个Playbook的中间运行handlers，则需要使用- meta> 模块来实现，例如：- meta: flush_handlers。
> - 如果一个Play在运行到调用handlers的语句之前失败了，那么这个handlers将不会被执行。我们- 可以使> 用mega模块的--force-handlers选项来强制执行handlers，即使在handlers所在Play中- 途运行失败也能执行。

## playbook模块













