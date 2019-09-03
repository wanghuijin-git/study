# Jenkins
## Jenkins简介
Jenkins是Java编写的非常流行的持续集成（CI）服务，起源于Hudson项目。所以Jenkins和Hudson功能相似。

Jenkins支持各种版本的控制工具，如CVS、SVN、Git、Mercurial、Perforce和ClearCase，而且可以执行用Apache Ant或Java Maven构建的项目。同时，它也可以利用一些插件、Shell脚本和Windows批处理命令来构建其他平台的项目。

Jenkins除了构建软件功能外，还可以用于搭建自动化测试环境，比如实现Python Selenium测试的无人值守的情况下按照预定的时间调度运行（如晚上），或者每次代码变更提交至版本控制系统时实现自动运行的效果。

## Jenkins安装
jenkins下载地址：https://pkg.jenkins.io/redhat-stable/
```
# 安装依赖包
[root@jenkins ~]# yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel -y

# 安装jenkins
[root@jenkins ~]# rpm -ivh /tools/packages/jenkins-2.164.3-1.1.noarch.rpm 
warning: /tools/packages/jenkins-2.164.3-1.1.noarch.rpm: Header V4 DSA/SHA1 Signature, key ID d50582e6: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:jenkins-2.164.3-1.1              ################################# [100%]
[root@jenkins ~]# systemctl start jenkins.service

# 访问http://192.168.1.52:8080/ 获取默认密码
[root@jenkins ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
eed81c88ec5d43e68785f8253a007ee9
```

### Jenkins默认插件
- Folders
- OWASP Markup Formatter
- Build Timeout
- Credentials Binding
- Timestamper
- Workspace Cleanup
- Ant
- Gradle
- Pipeline
- GitHub Branch Source
- Pipeline: GitHub Groovy Libraries
- Pipeline: Stage View
- Git
- Subversion
- SSH Slaves
- Matrix Authorization Strategy
- PAM Authentication
- LDAP
- Email Extension
- Mailer
- Localization: Chinese (Simplified)

- 后续gitlab需要安装jenkins插件
    - gitlab
    - ssh

## Jenkins管理
### Jenkins目录
```
[root@jenkins ~]# rpm -ql jenkins 
/etc/init.d/jenkins
/etc/logrotate.d/jenkins
/etc/sysconfig/jenkins
/usr/lib/jenkins
/usr/lib/jenkins/jenkins.war
/usr/sbin/rcjenkins
/var/cache/jenkins
/var/lib/jenkins
/var/log/jenkins
```
- /etc/sysconfig/jenkins：配置文件
- /var/lib/jenkins：主目录
- /etc/init.d/jenkins：启动文件
- /var/cache/Jenkins：程序文件
- /var/log/Jenkins：日志文件

### Jenkins启动参数配置
```
# 配置文件内配置的就是服务启动参数
[root@jenkins ~]# cat /etc/sysconfig/jenkins |grep -v "^#" |grep -v "^$"
JENKINS_HOME="/var/lib/jenkins"
JENKINS_JAVA_CMD=""
JENKINS_USER="jenkins"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"
JENKINS_PORT="8080"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""

[root@jenkins ~]# ps -ef |grep jenkins
jenkins   20114      1  6 20:13 ?        00:02:28 /etc/alternatives/java -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --httpPort=8080 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
```

### Jenkins备份
```
tar zcvf jenkins.tar.gz /var/lib/jenkins/
```
当代码数量特别大时，可以使用rsync增量备份。








