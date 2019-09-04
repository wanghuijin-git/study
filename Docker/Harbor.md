# Harbor
## Harbor介绍
Harbor是VMware公司开源的企业级Docker Registry项目  
Githup项目地址：https://github.com/goharbor/harbor/

## Harbor核心组件解释
- Proxy：他是一个nginx的前端代理，代理Harbor的registry,UI, token等服务。
- db：负责储存用户权限、审计日志、Dockerimage分组信息等数据。
- UI：提供图形化界面，帮助用户管理registry上的镜像, 并对用户进行授权。
- jobsevice：jobsevice是负责镜像复制工作的，他和registry通信，从一个registry pull镜像然- 后push到另一个registry，并记录job_log。
- Adminserver：是系统的配置管理中心附带检查存储用量，ui和jobserver启动时候回需要加载- adminserver的配置。
- Registry：镜像仓库，负责存储镜像文件。
- Log：为了帮助监控Harbor运行，负责收集其他组件的log，供日后进行分析。

## Harbor安装
### harbor安装
- Harbor包
- docker-compose
- openssl
```
1. 解压harbor离线包
[root@datastore packages]# tar zxf harbor-offline-installer-v1.8.2.tgz -C /tools/
[root@datastore packages]# cd /tools/harbor/

2. 下载docker-compose
curl -L https://github.com/docker/compose/releases/download/1.23.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose 
ln -s /usr/local/bin/docker-compose /usr/sbin/

3. 自签https证书
证书安装步骤：https://github.com/goharbor/harbor/blob/master/docs/configure_https.md
[root@datastore ]# yum install openssl -y
[root@datastore harbor]# mkdir ssl
[root@datastore harbor]# cd ssl/

# 获得证书授权
[root@datastore ssl]# openssl genrsa -out ca.key 4096

[root@datastore ssl]# openssl req -x509 -new -nodes -sha512 -days 3650 \
   -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=reg.jcx.com" \
   -key ca.key \
   -out ca.crt

# 获得服务器证书
1)创建自己的私钥
[root@datastore ssl]# openssl genrsa -out reg.jcx.com.key 4096

2)生成证书签名请求
[root@datastore ssl]# openssl req -sha512 -new \
   -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=reg.jcx.com" \
   -key reg.jcx.com.key \
   -out reg.jcx.com.csr

3)生成注册表主机的证书
[root@datastore ssl]# cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names

[alt_names]
DNS.1=reg.jcx.com       # FQDN要写全
DNS.2=datastore
EOF

[root@datastore ssl]# openssl x509 -req -sha512 -days 365 \
   -extfile v3.ext \
   -CA ca.crt -CAkey ca.key -CAcreateserial \
   -in reg.jcx.com.csr \
   -out reg.jcx.com.crt

3)Docker守护程序将.crt文件解释为CA证书，将.cert文件解释为客户端证书
[root@datastore ssl]# openssl x509 -inform PEM -in reg.jcx.com.crt -out reg.jcx.com.cert

4. 配置harbor配置文件
[root@datastore ssl]# cd ../
[root@datastore harbor]# vim harbor.yml
hostname: reg.jcx.com
https:
  port: 443
  certificate: ./ssl/reg.jcx.com.cert
  private_key: ./ssl/reg.jcx.com.key
harbor_admin_password: 123456
database:
  password: 123456
data_volume: /data/harbor

5. 安装
[root@datastore harbor]# ./prepare 
[root@datastore harbor]# ./install.sh
[root@datastore harbor]# docker-compose ps
      Name                     Command                       State                            Ports                  
---------------------------------------------------------------------------------------------------------------------
harbor-core         /harbor/start.sh                 Up (health: starting)                                           
harbor-db           /entrypoint.sh postgres          Up (health: starting)   5432/tcp                                
harbor-jobservice   /harbor/start.sh                 Up                                                              
harbor-log          /bin/sh -c /usr/local/bin/ ...   Up (health: starting)   127.0.0.1:1514->10514/tcp               
harbor-portal       nginx -g daemon off;             Up (health: starting)   80/tcp                                  
nginx               nginx -g daemon off;             Up (health: starting)   0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
redis               docker-entrypoint.sh redis ...   Up                      6379/tcp                                
registry            /entrypoint.sh /etc/regist ...   Up (health: starting)   5000/tcp                                
registryctl         /harbor/start.sh                 Up (health: starting)  
```
### harbor验证
```
# 拷贝证书
[root@dockerm1 ~]# echo "192.168.1.253 reg.jcx.com" >> /etc/hosts
[root@dockerm1 ~]# mkdir /etc/docker/certs.d/reg.jcx.com -p
[root@dockerm1 ~]# scp reg.jcx.com:/tools/harbor/ssl/reg.jcx.com.crt /etc/docker/certs.d/reg.jcx.com/
root@reg.jcx.com's password: 
reg.jcx.com.crt                        100% 1842     1.2MB/s   00:00

# 验证上传镜像
[root@dockerm1 ~]# docker images
REPOSITORY                                TAG                 IMAGE ID            CREATED             SIZE
jcx/nginx                                 0.1                 65a97db263ba        12 days ago         510MB
192.168.1.35:5000/jichengxi/centos_base   0.1                 71a005ba468a        12 days ago         229MB
jcx/centos_base                           0.2                 71a005ba468a        12 days ago         229MB
centos                                    latest              67fa590cfc1c        2 weeks ago         202MB
registry                                  latest              f32a97de94e1        6 months ago        25.8MB
[root@dockerm1 ~]# docker login reg.jcx.com
Username: jichengxi
Password: 
[root@dockerm1 ~]# docker tag jcx/nginx:0.1 reg.jcx.com/jcx/nginx:0.1
[root@dockerm1 ~]# docker push reg.jcx.com/jcx/nginx:0.1
The push refers to repository [reg.jcx.com/jcx/nginx]
aea801da3325: Pushed 
b52eff8b5dbb: Pushed 
eba7fe69fda1: Pushed 
de4b19ef1c84: Pushed 
938040fd78a2: Pushed 
c626f125658d: Pushed 
5b1f77f673b7: Pushed 
f5b5263afc6f: Pushed 
15ab97e98c2e: Pushed 
a0839fd8706f: Pushed 
1e1e4630e1d4: Pushed 
877b494a9f30: Pushed 
0.1: digest: sha256:34b9ffb406ceac7d0b23323ec3183eece7347d76af8b664d84837de8fcc6d702 size: 2830
```






