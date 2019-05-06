# ecpect
## 概述
我们通过Shell可以实现简单的控制流功能，如：循环、判断等。但是对于需要交互的场合则必须通过人工来干预，有时候我们可能会需要实现和交互程序如telnet服务器等进行交互的功能。而expect就使用来实现这种功能的工具。  
expect是一个免费的编程工具语言，用来实现自动和交互式任务进行通信，而无需人的干预。expect是不断发展的，随着时间的流逝，其功能越来越强大，已经成为系统管理员的的一个强大助手。expect需要Tcl编程语言的支持，要在系统上运行expect必须首先安装Tcl。  

## expect的安装
```
[root@manager ~]# yum install expect -y
```

## expect的使用
### expect的工作流程
expect的工作流程可以理解为：spawn启动进程->>expect期待关键字->>send向进程发送字符->>退出结束

### expect的简单使用
```
[root@manager expect]# cat test1.sh 
#!/usr/bin/expect
spawn ssh root@192.168.1.31 ifconfig ens33
set timeout 60
expect "*password:"
send "1qaz!QAZ\n"
expect eof
exit

[root@manager expect]# expect test1.sh 
spawn ssh root@192.168.1.31 ifconfig ens33
root@192.168.1.31's password: 
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.31  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::20c:29ff:fe2a:4de5  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:2a:4d:e5  txqueuelen 1000  (Ethernet)
        RX packets 64987  bytes 95343538 (90.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 6922  bytes 708207 (691.6 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

### expect语法
#### spawn
apawn命令是expect的初始命令。它用于启动一个进程，之后所有expect操作都在这个进程中进行，如果没有spawn语句，整个expect就无法执行
```
spawn ssh root@192.168.1.31 ifconfig ens33
```
在spawn命令后面，直接加上要启动的进程、命令等信息。除此之外，spawn还支持其他选项如：  
-open    启动文件进程  
-ignore	忽略某些信号

#### expect
使用方法：expect 表达式 动作 表达式 动作 ......  

expect命令用于等候一个相匹配内容的输出，一旦匹配上就执行expect后面的动作或命令，这个命令接受几个特有参数，用的最多的就是-re，表示正则表达式的方式匹配，使用起来像这样：
```
spawn ssh root@192.168.1.31
expect "*password:" ｛send "1qaz!QAZ\r"｝
```
expect是依附与spawn命令的，当执行ssh命令后，expect就匹配命令执行后的关键字："password:"，如果匹配到关键字就会执行后面包含在{}括号中exp_send动作，匹配以及动作可以放在两行，这样就不需要使用{}括号了，比如这样：
```
spawn ssh root@192.168.1.31
expect "*password:"
send "1qaz!QAZ\r"
```
expect命令还有一种使用方法，它可以在一个expect匹配中多次匹配关键字，并给出处理动作，只需要将关键字放在一个大括号中就可以了，当然还要有exp_continue。
```
spawn ssh root@192.168.1.32 ifconfig ens33
expect {
	"yes/no" {exp_send "yes\r"; exp_continue }
	"*password:" {exp_send "1qaz!QAZ\r";}
}
```

#### exp_send和send

















