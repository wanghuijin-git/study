# Glusterfs
## Glusterfs概述
## Glusterfs安装
```
官方地址：https://www.gluster.org/

1. 安装gluterfs源
安装epel源
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

查看有哪些版本的镜像
[root@glusterfs1 ~]# yum search  centos-release-gluster   
=================================== N/S matched: centos-release-gluster ===================================
centos-release-gluster-legacy.noarch : Disable unmaintained Gluster repositories from the CentOS Storage
                                     : SIG
centos-release-gluster40.x86_64 : Gluster 4.0 (Short Term Stable) packages from the CentOS Storage SIG
                                : repository
centos-release-gluster41.noarch : Gluster 4.1 (Long Term Stable) packages from the CentOS Storage SIG
                                : repository
centos-release-gluster5.noarch : Gluster 5 packages from the CentOS Storage SIG repository
centos-release-gluster6.noarch : Gluster 6 packages from the CentOS Storage SIG repository

安装gluster6的源
[root@glusterfs1 ~]# yum install centos-release-gluster6.noarch

2. 安装glusterfs-server
[root@glusterfs1 ~]# yum install glusterfs-server -y

3. 启动glusterfs
[root@glusterfs1 ~]# systemctl start glusterd
[root@glusterfs1 ~]# systemctl enable glusterd
Created symlink from /etc/systemd/system/multi-user.target.wants/glusterd.service to /usr/lib/systemd/system/glusterd.service.

4. 将服务器加入存储池中
[root@glusterfs1 ~]# gluster peer probe glusterfs2
peer probe: success. 
[root@glusterfs1 ~]# gluster peer probe glusterfs3
peer probe: success.

[root@glusterfs2 ~]# gluster peer status
Number of Peers: 2

Hostname: glusterfs1
Uuid: c2ee8d16-04c7-48d9-a0cb-f6bdd3f96b2c
State: Peer in Cluster (Connected)

Hostname: glusterfs3
Uuid: a500fa96-c84a-42f7-802f-3b9b29887f3d
State: Peer in Cluster (Connected)
```
## glusterfs配置前的准备工作
```
格式化分区并挂载
[root@glusterfs2 ~]# mkfs.xfs /dev/glusterfs/data01
mkdir /data01meta-data=/dev/glusterfs/data01  isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@glusterfs2 ~]# mkdir /data01
[root@glusterfs2 ~]# echo "/dev/glusterfs/data01 /data01 xfs defaults 0 0" >> /etc/fstab
[root@glusterfs2 ~]# mount -a
```
## 创建volume
### GlusterFS 五种卷　　
- Distributed：分布式卷，文件通过 hash 算法随机分布到由 bricks 组成的卷上。
- Replicated: 复制式卷，类似 RAID 1，replica 数必须等于 volume 中 brick 所包含的存储服务器数，可用性高。
- Striped: 条带式卷[已弃用]，类似 RAID 0，stripe 数必须等于 volume 中 brick 所包含的存储服务器数，文件被分成数据块，以 Round Robin 的方式存储在 bricks 中，并发粒度是数据块，大文件性能好。
- Distributed Striped[已弃用]: 分布式的条带卷，volume中 brick 所包含的存储服务器数必须是 stripe 的倍数（>=2倍），兼顾分布式和条带式的功能。
- Distributed Replicated: 分布式的复制卷，volume 中 brick 所包含的存储服务器数必须是 replica 的倍数（>=2倍），兼顾分布式和复制式的功能。
- Dispersed - 分散卷，基于擦除代码，提供节省空间的磁盘或服务器故障保护。它将原始文件的编码片段存储到每个块中，其方式是仅需要片段的子集来恢复原始文件。管理员在创建卷时配置可丢失而不会丢失数据访问权限的砖块数。
- Distributed Dispersed  - 分布式分散卷，在分散的子卷中分发文件。这与分发复制卷具有相同的优点，但使用分散将数据存储到块中。

> 分布式复制卷的brick顺序决定了文件分布的位置，一般来说，先是两个brick形成一个复制关系，然后两个复制关系形成分布。
> 企业一般用后两种，大部分会用分布式复制（可用容量为 总容量/复制份数），通过网络传输的话最好用万兆交换机，万兆网卡来做。这样就会优化一部分性能。它们的数据都是通过网络来传输的。

### 分布式卷
![分布式卷](https://cloud.githubusercontent.com/assets/10970993/7412364/ac0a300c-ef5f-11e4-8599-e7d06de1165c.png)
```
1. 创建分布式卷
[root@glusterfs1 ~]# gluster volume create gv1 glusterfs1:/data01 glusterfs2:/data01 force
volume create: gv1: success: please start the volume to access data

2. 启动卷gv1
[root@glusterfs1 ~]# gluster volume start gv1
volume start: gv1: success

3. 查看gv1卷信息
[root@glusterfs3 ~]# gluster volume info 
Volume Name: gv1
Type: Distribute     # 分布式卷
Volume ID: c6bdbac2-eb32-4b75-9cdb-ee5cba8f6a98
Status: Started
Snapshot Count: 0
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: glusterfs1:/data01
Brick2: glusterfs2:/data02
Options Reconfigured:
transport.address-family: inet
nfs.disable: on

4. 挂载目录
[root@glusterfs3 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt     # 挂载目录
[root@glusterfs3 ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/jcxvg-root         20G  1.7G   18G   9% /
/dev/sda2                     497M  123M  375M  25% /boot
/dev/mapper/glusterfs-data01   10G   33M   10G   1% /data01
tmpfs                          98M     0   98M   0% /run/user/0
127.0.0.1:/gv1                 20G  270M   20G   2% /mnt        # 卷大小为两台机器盘的和
```
### 复制卷
![复制卷](https://cloud.githubusercontent.com/assets/10970993/7412379/d75272a6-ef5f-11e4-869a-c355e8505747.png)
```
1. 创建复制卷
[root@glusterfs1 ~]# gluster volume create gv1 replica 2 glusterfs1:/data01 glusterfs2:/data01 force
volume create: gv1: success: please start the volume to access data

2. 启动卷
[root@glusterfs1 ~]# gluster volume start gv1
volume start: gv1: success

3. 查看gv1卷信息
[root@glusterfs1 ~]# gluster volume info
Volume Name: gv1
Type: Replicate         # 复制卷
Volume ID: a185549a-620b-4930-b3ca-b8ad170fc3ed
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: glusterfs1:/data01
Brick2: glusterfs2:/data01
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off

4. 挂载目录
[root@glusterfs1 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt
[root@glusterfs1 ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/jcxvg-root         20G  2.0G   18G  10% /
/dev/mapper/glusterfs-data01   10G   33M   10G   1% /data01
tmpfs                          98M     0   98M   0% /run/user/0
127.0.0.1:/gv1                 10G  135M  9.9G   2% /mnt        # 容量为1/2，相当于raid1
```
### 分布式复制卷
![分布式复制卷](https://cloud.githubusercontent.com/assets/10970993/7412402/23a17eae-ef60-11e4-8813-a40a2384c5c2.png)
```
1. 创建复制卷
[root@glusterfs1 ~]# gluster volume create gv1 replica 2 glusterfs1:/data01 glusterfs2:/data01 force        # 也可以一次性创建
volume create: gv1: success: please start the volume to access data

2. 加入两块卷
[root@glusterfs1 ~]# gluster volume add-brick gv1 replica 2 glusterfs1:/data02 glusterfs2:/data02 force
volume add-brick: success

3. 查看gv1信息
[root@glusterfs1 ~]# gluster volume info
Volume Name: gv1
Type: Distributed-Replicate     # 分布式复制卷
Volume ID: f7349958-3622-4681-ac22-727b1d6f2aad
Status: Created
Snapshot Count: 0
Number of Bricks: 2 x 2 = 4
Transport-type: tcp
Bricks:
Brick1: glusterfs1:/data01
Brick2: glusterfs2:/data01
Brick3: glusterfs1:/data02
Brick4: glusterfs2:/data02
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```
### 分散卷
```
1. 创建分散卷
[root@glusterfs1 ~]# gluster volume create gv1 disperse 4 glusterfs1:/data01 glusterfs2:/data01 glusterfs1:/data02 glusterfs2:/data02 force
There isn't an optimal redundancy value for this configuration. Do you want to create the volume with redundancy 1 ? (y/n) y
volume create: gv1: success: please start the volume to access data

2. 启动分散卷
[root@glusterfs1 ~]# gluster volume start gv1
volume start: gv1: success

3. 查看gv1信息
[root@glusterfs1 ~]# gluster volume info
Volume Name: gv1
Type: Disperse      # 分散卷
Volume ID: 6e64eddf-6dcb-4cb8-9fa4-dd31db88f94f
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x (3 + 1) = 4
Transport-type: tcp
Bricks:
Brick1: glusterfs1:/data01
Brick2: glusterfs2:/data01
Brick3: glusterfs1:/data02
Brick4: glusterfs2:/data02
Options Reconfigured:
transport.address-family: inet
nfs.disable: on

4. 挂载分区
[root@glusterfs1 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt/
[root@glusterfs1 ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/jcxvg-root         20G  2.0G   18G  10% /
/dev/mapper/glusterfs-data02  5.0G   33M  5.0G   1% /data02
/dev/mapper/glusterfs-data01  5.0G   33M  5.0G   1% /data01
127.0.0.1:/gv1                 15G  250M   15G   2% /mnt        # 容量为3/4，相当于raid5
```
### 分布式分散卷
```
1. 创建分布式分散卷
[root@glusterfs1 ~]# gluster volume create gv1 disperse 3 glusterfs1:/data01 glusterfs2:/data01 glusterfs3:/data01 glusterfs1:/data02 glusterfs2:/data02 glusterfs3:/data02 force
volume create: gv1: success: please start the volume to access data

2. 启动分布式分散卷
[root@glusterfs1 ~]# gluster volume start gv1
volume start: gv1: success

3. 查看gv1信息
[root@glusterfs1 ~]# gluster volume info 
Volume Name: gv1
Type: Distributed-Disperse
Volume ID: 89667be1-29fa-4362-a704-aed85e238345
Status: Created
Snapshot Count: 0
Number of Bricks: 2 x (2 + 1) = 6
Transport-type: tcp
Bricks:
Brick1: glusterfs1:/data01
Brick2: glusterfs2:/data01
Brick3: glusterfs3:/data01
Brick4: glusterfs1:/data02
Brick5: glusterfs2:/data02
Brick6: glusterfs3:/data02
Options Reconfigured:
transport.address-family: inet
nfs.disable: on

4. 挂载分区
[root@glusterfs1 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt/
[root@glusterfs1 ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/jcxvg-root         20G  2.0G   18G  10% /
/dev/mapper/glusterfs-data02  5.0G   33M  5.0G   1% /data02
/dev/mapper/glusterfs-data01  5.0G   33M  5.0G   1% /data01
127.0.0.1:/gv1                 20G  334M   20G   2% /mnt    # 容量为3/4，相当于raid5
```

## 磁盘存储的平衡
平衡布局是很有必要的，因为布局结构是静态的，当新的 bricks 加入现有卷，新创建的文件会分布到旧的 bricks 中，所以需要平衡布局结构，使新加入的 bricks 生效。布局平衡只是使新布局生效，并不会在新的布局中移动老的数据，如果你想在新布局生效后，重新平衡卷中的数据，还需要对卷中的数据进行平衡。
```
# 创建一个分散卷
[root@glusterfs1 ~]# gluster volume create gv1 disperse 3 glusterfs1:/data01 glusterfs2:/data01 glusterfs3:/data01 force   
volume create: gv1: success: please start the volume to access data
[root@glusterfs1 ~]# gluster volume start gv1
volume start: gv1: success
[root@glusterfs1 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt
# 创建三个10M的文件
[root@glusterfs1 mnt]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-1.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 2.3449 s, 4.4 MB/s
[root@glusterfs1 mnt]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-2.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 2.66975 s, 3.8 MB/s
[root@glusterfs1 mnt]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-3.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 2.11298 s, 4.8 MB/s

[root@glusterfs1 mnt]# ll -h /data01/
total 15M
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-1.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-2.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-3.file

[root@glusterfs2 ~]# ll -h /data01/
total 15M
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-1.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-2.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-3.file

[root@glusterfs3 ~]# ll -h /data01/
total 15M
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-1.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-2.file
-rw-r--r-- 2 root root 4.9M Aug 19 17:27 10M-3.file

# 新加三个盘进来做分布式分散卷
[root@glusterfs1 /]# umount /mnt/
[root@glusterfs1 ~]# gluster volume stop gv1
Stopping volume will make its data inaccessible. Do you want to continue? (y/n) y
volume stop: gv1: success
[root@glusterfs1 ~]# gluster volume add-brick gv1 glusterfs1:/data02 glusterfs2:/data02 glusterfs3:/data02 force
volume add-brick: success
[root@glusterfs1 ~]# gluster volume start gv1 
volume start: gv1: success
[root@glusterfs1 ~]# mount -t glusterfs 127.0.0.1:/gv1 /mnt

# 再创建三个文件
[root@glusterfs1 ~]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-4.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 1.90685 s, 5.4 MB/s
[root@glusterfs1 ~]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-5.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 1.99968 s, 5.1 MB/s
[root@glusterfs1 ~]# dd if=/dev/zero bs=1024 count=10000 of=/mnt/10M-6.file
10000+0 records in
10000+0 records out
10240000 bytes (10 MB) copied, 2.3427 s, 4.4 MB/s

# 文件分布不均匀
[root@glusterfs1 ~]# ll /data01/
total 25000
-rw-r--r-- 2 root root 5120000 Aug 19 17:27 10M-1.file
-rw-r--r-- 2 root root 5120000 Aug 19 17:27 10M-2.file
-rw-r--r-- 2 root root 5120000 Aug 19 17:27 10M-3.file
-rw-r--r-- 2 root root 5120000 Aug 19 17:39 10M-4.file
-rw-r--r-- 2 root root 5120000 Aug 19 17:40 10M-5.file
[root@glusterfs1 ~]# ll /data02/
total 5000
-rw-r--r-- 2 root root 5120000 Aug 19 17:40 10M-6.file
```




