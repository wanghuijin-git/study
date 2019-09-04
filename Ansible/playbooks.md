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




