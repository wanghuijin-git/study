# Git
## git安装
1. yum安装
```
[root@manager ~]# yum install git -y
```
2. 源码安装
```
从源码安装 Git，需要安装 Git 依赖的库：curl、zlib、openssl、expat，还有libiconv。
[root@manager ~]# yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel -y
为了能够添加更多格式的文档（如 doc, html, info），安装以下的依赖包：
[root@manager packages]# yum install asciidoc xmlto docbook2x -y

通过源码包安装
[root@manager ~]# cd /packages/packages/
[root@manager packages]# wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.21.0.tar.gz
[root@manager packages]# tar zxf git-2.21.0.tar.gz -C ../
[root@manager packages]# cd ../git-2.21.0/
[root@manager git-2.21.0]# make configure
[root@manager git-2.21.0]# mkdir /apps/git
[root@manager git-2.21.0]# ./configure --prefix=/apps/git
[root@manager git-2.21.0]# make all doc info
[root@manager git-2.21.0]# make install install-doc install-html install-info

完成后，你可以使用 Git 来获取 Git 的升级
git clone git://git.kernel.org/pub/scm/git/git.git

配置环境变量
[root@manager ~]# ln -s /apps/git/bin/* /usr/sbin/
```
> 源码包下载地址：  
Kernel.org 网站：https://www.kernel.org/pub/software/scm/git  
GitHub 网站上的镜像：https://github.com/git/git/releases
>
## git使用
### 初始化仓库
```
[root@manager ~]# mkdir /gitdata
[root@manager ~]# cd /gitdata/
通过git init命令把这个目录变成Git可以管理的仓库
[root@manager gitdata]# git init
Initialized empty Git repository in /gitdata/.git/
[root@manager gitdata]# git config --global user.name "jichengxi"
[root@manager gitdata]# git config --global user.email 948788684@qq.com
[root@manager gitdata]# git config --list
user.name=jichengxi
user.email=948788684@qq.com
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
```
### 常用命令
```
git add 加入暂存区(索引区)
git status 查看状态
git status -s 状态概览
git diff 尚未暂存的文件
git diff --staged 暂存区文件
git commit 提交更新
git reset 回滚
git rm 从版本库中删除
git rm --cached <file> 从暂存区中移除
git mv 相当于mv git rm git add三个命令
```
```
[root@manager gitdata]# touch pay.html
[root@manager gitdata]# git add pay.html
[root@manager gitdata]# touch pay2.html
[root@manager gitdata]# git add pay2.html
[root@manager gitdata]# git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   pay.html
	new file:   pay2.html

[root@manager gitdata]# git rm --cached pay2.html
rm 'pay2.html'
[root@manager gitdata]# git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   pay.html

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	pay2.html

[root@manager gitdata]# git commit -m "pay"
[master (root-commit) 4892b1a] pay
 1 file changed, 1 insertion(+)
 create mode 100644 pay.html
[root@manager gitdata]# git log
commit 4892b1a314e7f2723af67f0ed5b2c55f48381f98 (HEAD -> master)
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 15:35:04 2019 +0800

    pay

```
### 分支管理
```
git branch
git branch -v
git branch --merged
git branch --no-merged
git branch -d testing
git checkout 切换指针
git checkout --file.txt 撤销对文件的修改
git merge
git log
git stash
git tag
```
```
创建分支
[root@manager gitdata]# git branch licai
切换分支
[root@manager gitdata]# git checkout licai
Switched to branch 'licai'
[root@manager gitdata]# git status
On branch licai
nothing to commit, working tree clean

新建文件测试
[root@manager gitdata]# echo "licai" > licai.html
[root@manager gitdata]# git add licai.html
[root@manager gitdata]# git commit -m "licai01"
[licai b1d23ec] licai01
 1 file changed, 1 insertion(+)
 create mode 100644 licai.html
[root@manager gitdata]# git log
commit b1d23ec86eaff05898cba9a6fa098ce6f2a76b81 (HEAD -> licai)
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 16:11:17 2019 +0800

    licai01

commit 50350e6cfbefdf09ca9db171bae9bc0ca214ac10 (master)
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 15:37:39 2019 +0800

    pay

commit 4892b1a314e7f2723af67f0ed5b2c55f48381f98
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 15:35:04 2019 +0800

    pay
[root@manager gitdata]# git checkout master
Switched to branch 'master'
[root@manager gitdata]# git log
commit 50350e6cfbefdf09ca9db171bae9bc0ca214ac10 (HEAD -> master)
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 15:37:39 2019 +0800

    pay

commit 4892b1a314e7f2723af67f0ed5b2c55f48381f98
Author: jichengxi <948788684@qq.com>
Date:   Wed May 15 15:35:04 2019 +0800

    pay

查看在哪个分支下
[root@manager gitdata]# git branch
  licai
* master

将分支合并到主干
[root@manager gitdata]# git checkout master
Switched to branch 'master'
[root@manager gitdata]# git merge licai
Updating 50350e6..b1d23ec
Fast-forward
 licai.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 licai.html
```
### 高级管理
git reset
           --soft 缓存区和工作目录都不会改变
           --mixed 默认选项，缓存区和你指定的提交同步，但工作目录不受影响
           --hard 缓存区和工作目录都同步到你指定的提交
git reflog
### 远程管理
https://images2015.cnblogs.com/blog/801940/201607/801940-20160710190318077-864971403.png
```
git clone https://github.com/jichengxi/learning.git
git pull
git fetch
git push origin(远程仓库名) master(分支)
git remote 查看所有远程仓库名
git remote -v 查看所有远程仓库信息
git remote add xxx http://xxx 创建远程仓库
git remote show origin
git remote rename pb paul
git tag -a v1.0 -m 'abc'
```

## GitLab安装
gitlab安装教程：https://about.gitlab.com/install/#centos-7  
官方安装源：https://about.gitlab.com/install/#centos-7  
清华大学镜像源：https://mirror.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
```
安装依赖包
[root@gitlab ~]# yum install -y curl policycoreutils-python openssh-server -y
[root@gitlab ~]# systemctl enable sshd
[root@gitlab ~]# systemctl start sshd
[root@gitlab ~]# yum install postfix -y
[root@gitlab ~]# systemctl enable postfix
[root@gitlab ~]# systemctl start postfix

安装软件包
[root@gitlab ~]# wget https://mirror.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-11.9.9-ce.0.el7.x86_64.rpm
[root@gitlab ~]# rpm -ivh gitlab-ce-11.9.9-ce.0.el7.x86_64.rpm

1)配置绝对路径gitlab地址(整个域名即gitlab地址)
[root@gitlab ~]# vim /etc/gitlab/gitlab.rb
external_url 'http://192.168.1.51'
[root@gitlab ~]# gitlab-ctl reconfigure

2)配置相对路径gitlab地址(在域名下建gitlab地址)
先释放下内存
[root@gitlab ~]# gitlab-ctl stop unicorn
ok: down: unicorn: 0s, normally up
[root@gitlab ~]# gitlab-ctl stop sidekiq
ok: down: sidekiq: 1s, normally up
[root@gitlab ~]# vim /etc/gitlab/gitlab.rb
external_url 'http://192.168.1.51/gitlab'
[root@gitlab ~]# gitlab-ctl reconfigure
[root@gitlab ~]# gitlab-ctl restart
```
## GitLab使用
### gitlab组件
- nginx：静态web服务器
- gitlan-shell：用于处理git命令和修改authorized_keys列表
- gitlab-workshorse：轻量级的反向代理服务器
- logrotate：日志文件管理工具
- postgresql：数据库
- redis：缓存数据库
- sidekiq：用于在后台执行队列任务(异步执行)
- unicorn：GitLan Rails应用是托管在这个服务器上面的
### gitlab目录
- /var/opt/gitlab/git-data/repositories/：库默认存储目录
- /opt/gitlab/：应用代码和相应的依赖程序
- /var/opt/gitlab/：gitlab-ctl reconfigure命令编译后的应用数据和配置文件，不需要人为修改配置
- /etc/gitlab：配置文件目录
- /var/log/gitlab：此目录下存放了gitlab各个组件产生的日志
- /var/opt/gitlab/backups/：备份文件生成的目录










