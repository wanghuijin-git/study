# Redhat6和Redhat7的区别
## 内核
- rhel 6
    - 2.6.x-x Kernel
- rhel 7
    - 3.10.x-x kernel

## 启动
### 启动管理
- rhel 6:  
init (process ID 1)

- rhel 7:
systemd (process ID 1)

系统启动和服务器进程由systemd系统和服务管理器进行管理

以下是systemd提供的几项新功能：
- 并行化功能，它可以提高系统的启动速度
- 按需启动守护进程，而不需要单独的服务
- 自动服务依赖关系管理，可以防止长时间超时，例如在网络不可用时不启动网络服务
- 利用Linux控制组一起追踪相关进程的方式

### 默认运行级别
- rhel 6:   
    - runlevel 0    # 关机
    - runlevel 1    # 单用户模式(安全模式)
    - runlevel 2    # 多用户模式(无网络)
    - runlevel 3    # 默认运行的命令行模式
    - runlevel 4
    - runlevel 5    # 图形化模式
    - runlevel 6    # 重启
```
# cat /etc/inittab
id:3:initdefault:
```

- rhel 7:
```
# ll /etc/systemd/system/default.target
/etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target
```
- runlevel0.target -> poweroff.target
- runlevel1.target -> rescue.target
- runlevel2.target -> multi-user.target
- runlevel3.target -> multi-user.target
- runlevel4.target -> multi-user.target
- runlevel5.target -> graphical.target
- runlevel6.target -> reboot.target

设置默认运行级别： 
systemctl  set-default  x.target

### 服务管理
- rhel 6:   
所有的服务都放在/etc/init.d/下，开机服务启动通过chkconfig来管理。  
init管理的服务是基于shell的脚本来启动的传统服务。  
chkconfig主要作用就是在/etc/rc3.d/下做一个软连接到/etc/init.d/下的服务上。  

例如ntp服务：  

```
# ll /etc/rc3.d/ |grep ntpd
S58ntpd -> ../init.d/ntpd

# cat /etc/init.d/ntpd
# chkconfig: - 58 74
```

> S代表开机启动，K代表开机不启动  
> 58表示启动优先权 74表示停止优先权

- rhel 7:  
在systemd中，服务、挂载等资源统一被称为单元，所以systemd中有许多单元类型

以下列出一些常用的单元类型：
- 服务单元具有.service扩展名，代表系统服务。这种单元用于启动经常访问的守护进程。
- 套接字单元具有.socket扩展名，代表进程间通信套接字。套接字的控制可以在建立客户端连接时传递到守护进程或新启动的服务。套接字单元用于延迟系统启动时的服务启动，或者按需启动不常用的服务。

systemd单元文件放置位置：  
/usr/lib/systemd/system：每个服务最主要的启动脚本设置，类似于之前的/etc/initd.d  
/run/system/system：系统执行过程中所产生的服务脚本，比上面的目录优先运行  
/etc/system/system：系统管理员创建和管理的单元目录，此目录优先级最高  

- systemd的服务管理：    
systemctl常用命令  
    - 启动服务 systemctl start name.service
    - 关闭服务 systemctl stop name.service
    - 重启服务 systemctl restart tname.service
    - 仅当服务运行的时候，重启服务 systemctl try-restart name.service 
    - 重新加载服务配置文件 systemctl relaod name.service
    - 检查服务运作状态 systemctl status name.service (-l) 或者 systemctl is-active name.service
    - 展示所有服务状态详细信息 systemctl list-units--type service --all
    - 允许服务开机启动 systemctl enable name.service
    - 禁止服务开机启动 systemclt disable name.service
    - 检查服务开机启动状态 systemctl status name.service 或者 systemctl is-enabled name.service
    - 列出所有服务并且检查是否开机启动 systemctl list-unit-files --type service
    - 查看启动失败的服务 systemctl --failed -t service
    - 查看服务的依赖关系 systemctl list-dependencies


```
# systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-07-18 11:01:22 CST; 3 months 27 days ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 1660 (sshd)
   CGroup: /system.slice/sshd.service
           └─1660 /usr/sbin/sshd -D

服务状态：
loaded：unit配置文件已处理
active（running）：一次或多次持续处理的运行
active（exited）：成功完成一次性的配置
active（waiting）:运行中，等待一个事件
inactive：不运行
enabled：开机启动
disabled：开机不启动
static：开机不启动，但可以被另一个启用的服务激活
```

- systemd的服务配置

```
# cat /usr/lib/systemd/system/chronyd.service 
[Unit]
Description=NTP client/server
Documentation=man:chronyd(8) man:chrony.conf(5)
After=ntpdate.service sntp.service ntpd.service
Conflicts=ntpd.service systemd-timesyncd.service
ConditionCapability=CAP_SYS_TIME

[Service]
Type=forking
PIDFile=/var/run/chronyd.pid
EnvironmentFile=-/etc/sysconfig/chronyd
ExecStart=/usr/sbin/chronyd $OPTIONS
ExecStartPost=/usr/libexec/chrony-helper update-daemon
PrivateTmp=yes
ProtectHome=yes
ProtectSystem=full

[Install]
WantedBy=multi-user.target
```

- systemd服务配置文件组成：
    - [Unit]：用于提供unit的扫描信息，unit行为及依赖关系等
    - [Service]：与特定类型相关的专用选项；此处为Service类型
    - [Install]：定义由“systemctl enable及systemctl disable”命令在实现服务启用或禁用时用到的一些选项

- Unit段常用选项
    - Description：描述信息
    - After：定义unit的启动次序，表示当前unit应该晚于哪些unit启动
    - Requires：依赖到的其他units，强依赖，被一来的units无法激活时，当前unit即无法激活
    - Wants：依赖到的其他units，弱依赖
    - Conflicts：定义units间的冲突关系

- Service段常用选项
    - Type：定义硬性ExecStart及相关参数的功能的unit进程启动类型
        - simple：默认值；这个daemon主要有ExecStart接的指令串来启动，启动后常驻于内存中
        - forking：由ExecStart启动的程序透过spawns延伸出其他子程序来作为此daemon的主要服务原生父程序在启动结束后就会终止
        - onshot：用于执行一项任务，随后立即退出的服务，不会常驻于内存中
        - notify：与simple相同，但约定服务会在就绪后想systemd发送一个信号，需要配合NotifyAccess来让Systemd  接收消息
        - idle：与simple类似，要执行这个daemon必须要所有的工作都顺利执行完毕后才会执行。这类的daemon通常是开机到最后才只能即可的服务
    - EnvironmentFile：环境配置文件
    - ExeStart：指明启动unit要运行命令或脚本的绝对路径
    - ExeStartPre：ExecStart前运行
    - ExeStartPost：ExecStart后运行
    - ExecStop：指明停止unit要运行的命令或脚本
    - Restart：当设定Restart=1时，则当次daemon服务意外终止后，会在此自动启动此服务

- Install段常用选项
    - Alias：别名(可使用systemctl command Alial.service)
    - RequiredBy:被那些units所依赖，强依赖
    - WantedBy：被那些units所依赖，弱依赖
    - Also：安装本服务的时候还要安装别的相关服务

> 注意：对于新创建的unit文件，或者修改了的unit文件，要通知systemd重载次配置文件，而后可以选择重启：systemctl daemon-reload

### 磁盘
#### 文件系统
- rhel 6：    
默认使用ext4文件系统，最大支持16T的文件系统和单个文件大小  
文件系统的检查和修复 e2fsck  
更新文件系统大小 resize2fs  

- rhel 7：    
默认使用xfs文件系统，最大支持500T的文件系统和单个文件大小  
文件系统的检查和修复 xfs_repair  
更新文件系统大小 xfs_growfs  

### 网络
- rhel 6：   
双网卡绑定：bond0 
- rhel 7：  
双网卡绑定：team0

#### 防火墙
firewalld可以动态修改单条规则，动态管理规则集，允许更新规则而不破坏现有会话和连接。而iptables，在修改了规则后必须得全部刷新才可以生效；  
firewalld使用区域和服务而不是链式规则；  
firewalld默认是拒绝的，需要设置以后才能放行。而iptables默认是允许的，需要拒绝的才去限制。

- rhel 6：
    - iptables
        - INPUT链：处理输入数据包。
        - OUTPUT链：处理输出数据包。
        - PORWARD链：处理转发数据包。
        - PREROUTING链：用于目标地址转换（DNAT）。
        - POSTOUTING链：用于源地址转换（SNAT）。
- rhel 7：
    - firewalld

区域：系统默认处于public区域

1. 丢弃区域（Drop Zone）：如果使用丢弃区域，任何进入的数据包将被丢弃，使用丢弃规则意味着将不存在响应。
2. 阻塞区域（Block Zone）：阻塞区域会拒绝进入的网络连接，返回 icmp-host-prohibited阻止，只有服务器已经建立的连接会被通过即只允许由该系统初始化的网络连接。
3. 公共区域（Public Zone）：只接受那些被选中的连接，默认只允许ssh和dhcpv6-client。这个zone 是缺省 zone
4. 外部区域（External Zone）：这个区域相当于路由器的启用伪装（masquerading）选项。只有指定的连接会被接受，即ssh，而其它的连接将被丢弃或者不被接受。
5. 隔离区域（DMZ Zone）：如果想要只允许给部分服务能被外部访问，可以在DMZ区域中定义。它也拥有只通过被选中连接的特性，即ssh。
6. 工作区域（Work Zone）：在这个区域，我们只能定义内部网络。比如私有网络通信才被允许，只允ssh，ipp-client 和 dhcpv6-client。
7. 家庭区域（Home Zone）：这个区域专门用于家庭环境。它同样只允许被选中的连接，ssh，ipp-client，mdns，samba-client 和 dhcpv6-client。
8. 内部区域（Internal Zone）：这个区域和工作区域（Work Zone）类似，只有通过被选中的连接，和 home 区域一样。
9. 信任区域（Trusted Zone）：信任区域允许所有网络通信通过。记住：因为 trusted 是最被信任的，即使没有设置任何的服务，那么也是被允许的，因为 trusted 是允许所有连接的

```
# firewall-cmd --zone=public --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: ssh dhcpv6-client
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

区域属性：
- 接口：接口就是网卡接口，一个网卡只能在一个区域中存在，一个区域可以存在多个接口。每个接口可以设置自己的默认区域。
- 来源：指定数据包的来源，比如说来自192.168.1.0/24的IP地址被允许或拒绝。配合其他属性使用
- 服务：一个区域中可以对不同的服务进行配置防火墙规则。默认的只有dhcpv6-client和ssh是默认允许访问的，其他的默认不允许访问。
- 端口：根据端口来配置防火墙的规则，默认是什么端口也没有，即不允许任何端口访问（区域服务中被勾选的服务对应的端口除外），如果添加了某个端口，则可以访问端口
- 伪装：IPV4的IP转发，并在公网上隐藏自己私网的IP地址，外网看到的是内网到外网出口的IP地址。不适用于ipv6.
- 端口转发：端口转发可以是本地到本地，也可以是本地到外系统（伪装开启），也是只适用于IPV4
- ICMP过滤器：互联网控制信息，用来发送错误信息。ICMP过滤器主要就是过滤勾上的ICMP类型消息。
- 富规则：可以根据富规则详细地对防火墙进行设置，包括来源、目的、类型等等

firewalld命令行配置
- add：创建
- get：查看
- query：查询
- set：设置
- change：修改
- remove：移除
- permanent：永久生效
- reload ：重新加载防火墙

示例：

- firewall-cmd--get-zones：查看当前已存在的区域
- firewall-cmd--get-active-zones：查看当前活跃的区域
- firewall-cmd--get-default-zone：查看当前防火墙的默认区域
- firewall-cmd--list-services --zone=hom：查看home区域下的可用服务
- firewall-cmd--set-default-zone=home：设置默认区域为home
- firewall-cmd--change-zone=work：修改当前连接区域
> 注：具体使用方法可以直接help获取帮助信息

firewalld配置文件
- /etc/firewalld/zones 区域模板文件
- /usr/lib/firewalld/zones 服务相关的模板文件
- /usr/lib/firewalld/services

### 其他
#### 主机名配置
- rhel 6：  
/etc/sysconfig/network
- rhel 7：  
/etc/hostname

#### 普通用户UID
- rhel 6：  
起始500
- rhel 7： 
起始1000

#### 目录结构
- rhel 6：
/bin, /sbin, /lib, /lib64 这四个文件夹都是在/下
- rhel 7：
/bin, /sbin, /lib, /lib64 这四个文件夹都是在/usr下

#### 网络时间服务
- rhel 6：
    - NTP
        - 查看时间同步状态：ntpq -p
- rhel 7：
    - Chrony
        - 查看时间同步状态：chronyc sources

#### NFS
- rhel 6：
NFS4
- rhel 7：
NFSv3, NFSv4.0, NVSv4.1 clients

#### 默认数据库
- rhel 6：
mysql
- rhel 7：
mariadb

### rhel7新增
- 对docker的支持
- 热插拔设备udev规则的移除
- 不再提供32位的系统镜像
- meminfo新增MemAvailable
    - free 还有多少物理内存可用，free 是真正尚未被使用的物理内存数量
    - available 还可以被 **应用程序** 使用的物理内存大小，available 是应用程序认为可用内存数量
    - Linux 为了提升读写性能，会消耗一部分内存资源缓存磁盘数据，对于内核来说，buffer 和 cache 其实都属于已经被使用的内存。但当应用程序申请内存时，如果 free 内存不够，内核就会回收 buffer 和 cache 的内存来满足应用程序的请求。
- ruby使用2.0.0，python使用2.7.5
- rhel7使用的Openjdk版本默认版本是jdk7，7.5现在默认是jdk8
- 最高支持40GB的网络速率
- xfs文件挂载的时候会启用user_xattr和ACL选项

#### systemd-journald
- systemd-journald(一次性的日志，保存在内存中比较详细) 是 syslog 的补充，收集来自内核、启动过程早期阶段、标准输出、系统日志、守护进程启动和运行期间错误的信息。syslog 的信息也可以由 systemd-journald 转发到 rsyslog 中进一步处理。
- 默认情况下，systemd 的日志保存在 /run/log/journal 中，系统重启就会清除，这是RHEL7的新特性。
- 通过新建 /var/log/journal 目录，日志会自动记录到这个目录中，并永久存储。rsyslog 服务随后根据优先级排列日志信息，将它们写入到 /var/log目录中永久保存。

