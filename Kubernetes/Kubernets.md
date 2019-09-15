# Kubernetes
## Kubernetes 概念
### Kubernetes 介绍
Kubernetes是容器集群管理系统，是一个开源的平台，可以实现容器集群的自动化部署、自动扩缩容、维护等功能。

通过Kubernetes你可以：
- 快速部署应用
- 快速扩展应用
- 无缝对接新的应用功能
- 节省资源，优化硬件资源的使用

Kubernetes 特点
- 可移植: 支持公有云，私有云，混合云，多重云（multi-cloud）
- 可扩展: 模块化, 插件化, 可挂载, 可组合
- 自动化: 自动部署，自动重启，自动复制，自动伸缩/扩展

### Kuberneter 架构
![](https://feisky.gitbooks.io/kubernetes/architecture/images/architecture.png)

Kubernetes能提供一个以“**容器为中心的基础架构**”，满足在生产环境中运行应用的一些常见需求，如：
- 多个进程（作为容器运行）协同工作。（Pod）
- 存储系统挂载
- Distributing secrets
- 应用健康检测
- 应用实例的复制
- Pod自动伸缩/扩展
- Naming and discovering
- 负载均衡
- 滚动更新
- 资源监控
- 日志访问
- 调试应用程序
- 提供认证和授权

### Kuberneter 工作流程
![gongzuoliucheng](https://www.kubernetes.org.cn/img/2018/12/f58fdff5900a44af26d3cad562dbc584.png)

## Kubernetes 组件
### Master 组件
Master组件提供集群的管理控制中心。  
Master组件可以在集群中任何节点上运行。但是为了简单起见，通常在一台VM/机器上启动所有Master组件，并且不会在此VM/机器上运行用户容器。
![master](https://feisky.gitbooks.io/kubernetes/architecture/images/14791969222306.png)

- kube-apiserver  
kube-apiserver用于暴露Kubernetes API。任何的资源请求/调用操作都是通过kube-apiserver提供的接口进行。Kubernetes API服务器验证和配置api对象的数据，包括pod，服务，复制控制器等。 API服务器为REST操作提供服务，并为集群的共享状态提供前端，所有其他组件通过该状态进行交互。

- ETCD  
etcd是一个一致且高度可用的键值存储，用作Kubernetes对所有集群数据的后备存储。etcd是Kubernetes提供默认的存储系统，保存所有集群数据，使用时需要为etcd数据提供备份计划。

- cloud-controller-manager  
云控制器管理器负责与底层云提供商的平台交互。云控制器管理器是Kubernetes版本1.6中引入的，目前还是Alpha的功能。  
云控制器管理器仅运行云提供商特定的（controller loops）控制器循环。可以通过将--cloud-provider flag设置为external启动kube-controller-manager ，来禁用控制器循环。  
cloud-controller-manager 具体功能：
    - 节点（Node）控制器
    - 路由（Route）控制器
    - Service控制器
    - 卷（Volume）控制器 

- kube-scheduler  
kube-scheduler 监视新创建没有分配到Node的Pod，为Pod选择一个Node。

- 插件 addons  
插件（addon）是实现集群pod和Services功能的 。Pod由Deployments，ReplicationController等进行管理。Namespace 插件对象是在kube-system Namespace中创建。

- kube-dns  
虽然不严格要求使用插件，但Kubernetes集群都应该具有集群 DNS。  
群集 DNS是一个DNS服务器，能够为 Kubernetes services提供 DNS记录。  
由Kubernetes启动的容器自动将这个DNS服务器包含在他们的DNS searches中。  

- kube-ui  
kube-ui 提供集群状态基础信息查看。

- 容器资源监测  
容器资源监控提供一个UI浏览监控数据。

- Cluster-level Logging  
Cluster-level logging，负责保存容器日志，搜索/查看日志。

### Node 组件
节点组件运行在Node，提供Kubernetes运行时环境，以及维护Pod。  
kubelet是主要的节点代理，它会监视已分配给节点的pod，具体功能：  
1.安装Pod所需的volume。  
2.下载Pod的Secrets。  
3.Pod中运行的 docker（或experimentally，rkt）容器。  
4.定期执行容器健康检查。  
5.通过在必要时创建镜像pod，将pod状态报告回系统。  
6.将节点的状态报告回系统。 
![node](https://feisky.gitbooks.io/kubernetes/architecture/images/14791969311297.png)

- kube-proxy  
kube-proxy通过在主机上维护网络规则并执行连接转发来实现Kubernetes服务抽象。

- docker  
docker用于运行容器。

- rkt  
rkt运行容器，作为docker工具的替代方案。

- supervisord  
supervisord是一个轻量级的监控系统，用于保障kubelet和docker运行。

- fluentd  
fluentd是一个守护进程，可提供cluster-level logging.。

## Kubernetes对象
Kubernetes对象是Kubernetes系统中的持久实体。Kubernetes使用这些实体来表示集群的状态。具体来说，他们可以描述：
- 容器化应用正在运行(以及在哪些节点上)
- 这些应用可用的资源
- 关于这些应用如何运行的策略，如重新策略，升级和容错

Kubernetes对象是“record of intent”，一旦创建了对象，Kubernetes系统会确保对象存在。通过创建对象，可以有效地告诉Kubernetes系统你希望集群的工作负载是什么样的。  
要使用Kubernetes对象（无论是创建，修改还是删除），都需要使用Kubernetes API。例如，当使用kubectl命令管理工具时，CLI会为提供Kubernetes API调用。你也可以直接在自己的程序中使用Kubernetes API
### 对象（Object）规范和状态
每个Kubernetes对象都包含两个嵌套对象字段，用于管理Object的配置：Object Spec和Object Status。Spec描述了对象所需的状态 - 希望Object具有的特性，Status描述了对象的实际状态，并由Kubernetes系统提供和更新。

例如，通过Kubernetes Deployment 来表示在集群上运行的应用的对象。创建Deployment时，可以设置Deployment Spec，来指定要运行应用的三个副本。Kubernetes系统将读取Deployment Spec，并启动你想要的三个应用实例 - 来更新状态以符合之前设置的Spec。如果这些实例中有任何一个失败（状态更改），Kuberentes系统将响应Spec和当前状态之间差异来调整，这种情况下，将会开始替代实例。

### 描述Kubernetes对象
在Kubernetes中创建对象时，必须提供描述其所需Status的对象Spec，以及关于对象（如name）的一些基本信息。当使用Kubernetes API创建对象（直接或通过kubectl）时，该API请求必须将该信息作为JSON包含在请求body中。通常，可以将信息提供给kubectl .yaml文件，在进行API请求时，kubectl将信息转换为JSON。

以下示例是一个.yaml文件，显示Kubernetes Deployment所需的字段和对象Spec：
```
nginx-deployment.yaml

apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```
使用上述.yaml文件创建Deployment，是通过在kubectl中使用kubectl create命令来实现。将该.yaml文件作为参数传递。如下例子：
```
$ kubectl create -f docs/user-guide/nginx-deployment.yaml --record
```
其输出与此类似:
```
deployment "nginx-deployment" created
```

必填字段

对于要创建的Kubernetes对象的yaml文件，需要为以下字段设置值：
- apiVersion - 创建对象的Kubernetes API 版本
- kind - 要创建什么样的对象？
- metadata - 具有唯一标示对象的数据，包括 name（字符串）、UID和Namespace（可选项）

还需要提供对象Spec字段，对象Spec的精确格式（对于每个Kubernetes 对象都是不同的），以及容器内嵌套的特定于该对象的字段。  
Kubernetes API reference可以查找所有可创建Kubernetes对象的Spec格式。

### Kubernetes Names
Kubernetes REST API中的所有对象都用Name和UID来明确地标识。
#### Name
Name在一个对象中同一时间只能拥有单个Name，如果对象被删除，也可以使用相同Name创建新的对象，Name用于在资源引用URL中的对象，例如/api/v1/pods/some-name。通常情况，Kubernetes资源的Name能有最长到253个字符（包括数字字符、-和.），但某些资源可能有更具体的限制条件
#### UIDs
UIDs是由Kubernetes生成的，在Kubernetes集群的整个生命周期中创建的每个对象都有不同的UID（即它们在空间和时间上是唯一的）。

### Kubernetes Namespaces
命名空间将对象逻辑上分配到不通的namespaces。可以是不同的项目，用户等区分管理，并设定控制策略，从而实现多租户。  
Kubernetes可以使用Namespaces（命名空间）创建多个虚拟集群。  
Namespace为名称提供了一个范围。资源的Names在Namespace中具有唯一性。   
Namespace是一种将集群资源划分为多个用途(通过 resource quota)的方法。    

### Kubernetes Labels 和 Selectors
Labels其实就一对 key/value ，被关联到对象上，标签的使用我们倾向于能够标示对象的特殊特点，并且对用户而言是有意义的（就是一眼就看出了这个Pod是数据库），但是标签对内核系统是没有直接意义的。标签可以用来划分特定组的对象（比如，所有女的），标签可以在创建一个对象的时候直接给与，也可以在后期随时修改，每一个对象可以拥有多个标签，但是，key值必须是唯一的。
```
"labels": {
  "key1" : "value1",
  "key2" : "value2"
}
```
### Kubernetes Volume
数据卷，共享pod中容器使用的数据

### Kubernetes Annotations
可以使用Kubernetes Annotations将任何非标识metadata附加到对象。客户端（如工具和库）可以检索此metadata。

### Kubernetes Nodes
Node是Kubernetes中的工作节点，最开始被称为minion。一个Node可以是VM或物理机。每个Node（节点）具有运行pod的一些必要服务，并由Master组件进行管理，Node节点上的服务包括Docker、kubelet和kube-proxy。

### Kubernetes Pod
Pod是Kubernetes创建或部署的最小/最简单的基本单位，一个Pod代表集群上正在运行的一个进程。

一个Pod封装一个应用容器（也可以有多个容器），存储资源、一个独立的网络IP以及管理控制容器运行方式的策略选项。Pod代表部署的一个单位：Kubernetes中单个应用的实例，它可能由单个容器或多个容器共享组成的资源。

Kubernetes中的Pod使用可分两种主要方式：
- Pod中运行一个容器。“one-container-per-Pod”模式是Kubernetes最常见的用法; 在这种情况- 你可以将Pod视为单个封装的容器，但是Kubernetes是直接管理Pod而不是容器。- Pods中运行多个需要一起工作的容器。Pod可以封装紧密耦合的应用，它们需要由多个容器组成，- 之间能够共享资源，这些容器可以形成一个单一的内部service单位 - 一个容器共享文件，另- “sidecar”容器来更新这些文件。Pod将这些容器的存储资源作为一个实体来管理。

### Kubernetes Replica Sets
ReplicaSet（RS）是Replication Controller（RC）的升级版本。ReplicaSet 和  Replication Controller之间的唯一区别是对Label selector的支持。ReplicaSet支持新的基于集合的标签， 而Replication Controller仅支持基于等式的标签。

### Kubernetes Deployment
Deployment为Pod和Replica Set（升级版的 Replication Controller）提供声明式更新。

你只需要在 Deployment 中描述您想要的目标状态是什么，Deployment controller 就会帮您将 Pod 和ReplicaSet 的实际状态改变到您的目标状态。您可以定义一个全新的 Deployment 来创建 ReplicaSet 或者删除已有的 Deployment 并创建一个新的来替换。

注意：您不该手动管理由 Deployment 创建的 Replica Set，否则您就篡越了 Deployment controller 的职责！下文罗列了 Deployment 对象中已经覆盖了所有的用例。如果未有覆盖您所有需要的用例，请直接在 Kubernetes 的代码库中提 issue。  

典型的用例如下：
- 使用Deployment来创建ReplicaSet。ReplicaSet在后台创建pod。检查启动状态，看它是成功- 失败。
- 然后，通过更新Deployment的PodTemplateSpec字段来声明Pod的新状态。这会创建一个- ReplicaSet，Deployment会按照控制的速率将pod从旧的ReplicaSet移动到新的ReplicaSet中。
- 如果当前状态不稳定，回滚到之前的Deployment revision。每次回滚都会更新Deploymen- revision。
- 扩容Deployment以满足更高的负载。
- 暂停Deployment来应用PodTemplateSpec的多个修复，然后恢复上线。
- 根据Deployment 的状态判断上线是否hang住了。
- 清除旧的不必要的 ReplicaSet。

### Kubernetes StatefulSets
在具有以下特点时使用StatefulSets：
-稳定性，唯一的网络标识符。
-稳定性，持久化存储。
-有序的部署和扩展。
-有序的删除和终止。
- 有序的自动滚动更新。

### Kubernetes Ingress
- 节点：Kubernetes集群中的一台物理机或者虚拟机。
- 集群：位于Internet防火墙后的节点，这是kubernetes管理的主要计算资源。
- 边界路由器：为集群强制执行防火墙策略的路由器。 这可能是由云提供商或物理硬件管理的网关。
- 集群网络：一组逻辑或物理链接，可根据Kubernetes网络模型实现群集内的通信。 集群网络的实现包- 括Overlay模型的 flannel 和基于SDN的OVS。
- 服务：使用标签选择器标识一组pod成为的Kubernetes服务。 除非另有说明，否则服务假定在集群网- 络内仅可通过虚拟IP访问。

通常情况下，service和pod仅可在集群内部网络中通过IP地址访问。所有到达边界路由器的流量或被丢弃或被转发到其他地方。从概念上讲，可能像下面这样：
```
    internet
        |
  ------------
  [ Services ]
```
Ingress是授权入站连接到达集群服务的规则集合。
```
    internet
        |
   [ Ingress ]
   --|-----|--
   [ Services ]
```
你可以给Ingress配置提供外部可访问的URL、负载均衡、SSL、基于名称的虚拟主机等。用户通过POST Ingress资源到API server的方式来请求ingress。 Ingress controller负责实现Ingress，通常使用负载平衡器，它还可以配置边界路由和其他前端，这有助于以HA方式处理流量。

### Kubernetes Service
Kubernetes Service 定义了这样一种抽象：一个 Pod 的逻辑分组，一种可以访问它们的策略 —— 通常称为微服务。 这一组 Pod 能够被 Service 访问到，通常是通过 Label Selector实现的。

对 Kubernetes 集群中的应用，Kubernetes 提供了简单的 Endpoints API，只要 Service 中的一组 Pod 发生变更，应用程序就会被更新。 对非 Kubernetes 集群中的应用，Kubernetes 提供了基于 VIP 的网桥的方式访问 Service，再由 Service 重定向到 backend Pod。

### Kubernetes 垃圾收集
Kubernetes 垃圾收集器的角色是删除指定的对象，这些对象曾经有但以后不再拥有 Owner 了。

## Kubernetes 安装
![](https://www.kubernetes.org.cn/img/2018/12/de5fa3d5ed0eb5392add3d703a4bf7db.png)
### 软件
您需要以下二进制文件：
- etcd
- 以下 Container 运行工具之一:
    - docker
    - rkt
- Kubernetes
    - kubelet
    - kube-proxy
    - kube-apiserver
    - kube-controller-manager
    - kube-scheduler
### 部署 Etcd
#### 创建集群 CA 与 Certificates
```
[root@dockerm1 ~]# mkdir /tools/kubernetes/{bin,config,ssl} -p
# 下载cfssl工具用于创建自签证书
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O  /tools/kubernetes/bin/cfssl
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O  /tools/kubernetes/bin/cfssljson
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O  /tools/kubernetes/bin/cfssl-certinfo
[root@dockerm1 ]# echo "export PATH=$PATH:/tools/kubernetes/bin/" >> /etc/profile
[root@dockerm1 ]# source /etc/profile
[root@dockerm1 ]# cd /tools/kubernetes/ssl/

# 创建 etcd和kubernetes CA 证书
[root@dockerm1 ssl]# cfssl print-defaults config > ca-config.json
[root@dockerm1 ssl]# cfssl print-defaults csr > ca-csr.json
[root@dockerm1 ssl]# cfssl print-defaults csr > server-csr.json
[root@dockerm1 ssl]# cat ca-config.json 
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}

[root@dockerm1 ssl]# cat ca-csr.json 
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shanghai",
            "ST": "Shanghai"
        }
    ]
}

[root@dockerm1 ssl]# cat server-csr.json 
{
    "CN": "etcd",
    "hosts": [
    "127.0.0.1",
    "192.168.1.35",
    "192.168.1.31",
    "192.168.1.32",
    "dockerm1",
    "docker1",
    "docker2",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shanghai",
            "ST": "Shanghai"，
            "O": "k8s",
            "OU": "System"
        }
    ]
}

[root@dockerm1 ssl]# cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
2019/09/07 10:34:58 [INFO] generating a new CA key and certificate from CSR
2019/09/07 10:34:58 [INFO] generate received request
2019/09/07 10:34:58 [INFO] received CSR
2019/09/07 10:34:58 [INFO] generating key: rsa-2048
2019/09/07 10:34:58 [INFO] encoded CSR
2019/09/07 10:34:58 [INFO] signed certificate with serial number 87988083519067223218684933522101970528950574111

[root@dockerm1 ssl]# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
2019/09/07 10:41:15 [INFO] generate received request
2019/09/07 10:41:15 [INFO] received CSR
2019/09/07 10:41:15 [INFO] generating key: rsa-2048
2019/09/07 10:41:15 [INFO] encoded CSR
2019/09/07 10:41:15 [INFO] signed certificate with serial number 593487504404727640714185272564436409444430737690
2019/09/07 10:41:15 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").

# 创建 Kubernetes Proxy 证书
[root@dockerm1 ssl]# cfssl print-defaults csr > kube-proxy-csr.json

[root@dockerm1 ssl]# cat kube-proxy-csr.json 
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Shanghai",
      "ST": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}

[root@dockerm1 ssl]# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www kube-proxy-csr.json | cfssljson -bare kube-proxy
2019/09/07 10:49:37 [INFO] generate received request
2019/09/07 10:49:37 [INFO] received CSR
2019/09/07 10:49:37 [INFO] generating key: rsa-2048
2019/09/07 10:49:37 [INFO] encoded CSR
2019/09/07 10:49:37 [INFO] signed certificate with serial number 693863076890767957808520050883111819319381650116
2019/09/07 10:49:37 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
```
#### master和node互信
```
[root@dockerm1 ~]# ssh-keygen 
[root@dockerm1 ~]# ssh-copy-id root@192.168.1.31
[root@dockerm1 ~]# ssh-copy-id root@192.168.1.32
```
#### 部署etcd集群
```
[root@dockerm1 ~]# cd /tools/packages/
[root@dockerm1 packages]# tar zxf etcd-v3.3.10-linux-amd64.tar.gz -C ../
[root@dockerm1 packages]# cd ../etcd-v3.3.10-linux-amd64/
[root@dockerm1 etcd-v3.3.10-linux-amd64]# cp etcd etcdctl /tools/kubernetes/bin/
[root@dockerm1 etcd-v3.3.10-linux-amd64]# cd
[root@dockerm1 ~]# mkdir -p /data/kubernetes/etcd/

# 编写etcd的配置文件
[root@dockerm1 ~]# vim /tools/kubernetes/config/etcd
#[Member]
ETCD_NAME="etcd01"
ETCD_DATA_DIR="/data/kubernetes/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.1.35:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.1.35:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.1.35:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.1.35:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://192.168.1.35:2380,etcd02=https://192.168.1.31:2380,etcd03=https://192.168.1.32:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"

# 编写etcd的启动文件
[root@dockerm1 ~]# vim /usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/tools/kubernetes/config/etcd
ExecStart=/tools/kubernetes/bin/etcd \
--name=${ETCD_NAME} \
--data-dir=${ETCD_DATA_DIR} \
--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=new \
--cert-file=/tools/kubernetes/ssl/server.pem \
--key-file=/tools/kubernetes/ssl/server-key.pem \
--peer-cert-file=/tools/kubernetes/ssl/server.pem \
--peer-key-file=/tools/kubernetes/ssl/server-key.pem \
--trusted-ca-file=/tools/kubernetes/ssl/ca.pem \
--peer-trusted-ca-file=/tools/kubernetes/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

[root@dockerm1 ~]# systemctl daemon-reload
[root@dockerm1 ~]# systemctl enable etcd
Created symlink from /etc/systemd/system/multi-user.target.wants/etcd.service to /usr/lib/systemd/system/etcd.service.
[root@dockerm1 ~]# systemctl start etcd

# 拷贝配置文件和密钥到docker1和docker2上
[root@dockerm1 ~]# scp /tools/kubernetes/config/etcd 192.168.1.31:/tools/kubernetes/config/   
[root@dockerm1 ~]# scp /tools/kubernetes/config/etcd 192.168.1.32:/tools/kubernetes/config/
[root@dockerm1 ~]# scp /usr/lib/systemd/system/etcd.service 192.168.1.31:/usr/lib/systemd/system/etcd.service   
[root@dockerm1 ~]# scp /usr/lib/systemd/system/etcd.service 192.168.1.32:/usr/lib/systemd/system/etcd.service
[root@dockerm1 ~]# scp /tools/kubernetes/ssl/*.pem 192.168.1.31:/tools/kubernetes/ssl/
[root@dockerm1 ~]# scp /tools/kubernetes/ssl/*.pem 192.168.1.32:/tools/kubernetes/ssl/
[root@dockerm1 ~]# scp /tools/kubernetes/bin/etcd 192.168.1.31:/tools/kubernetes/bin/
[root@dockerm1 ~]# scp /tools/kubernetes/bin/etcd 192.168.1.32:/tools/kubernetes/bin/

# 配置docker1
[root@dockerm1 ~]# ssh 192.168.1.31
[root@docker1 ~]# cat /tools/kubernetes/config/etcd
#[Member]
ETCD_NAME="etcd02"
ETCD_DATA_DIR="/data/kubernetes/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.1.31:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.1.31:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.1.31:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.1.31:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://192.168.1.35:2380,etcd02=https://192.168.1.31:2380,etcd03=https://192.168.1.32:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
[root@docker1 ~]# systemctl daemon-reload
[root@docker1 ~]# systemctl enable etcd.service
[root@docker1 ~]# systemctl start etcd.service

# 配置docker2
[root@dockerm1 ~]# ssh 192.168.1.32
[root@docker2 ~]# cat /tools/kubernetes/config/etcd 
#[Member]
ETCD_NAME="etcd03"
ETCD_DATA_DIR="/data/kubernetes/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.1.32:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.1.32:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.1.32:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.1.32:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://192.168.1.35:2380,etcd02=https://192.168.1.31:2380,etcd03=https://192.168.1.32:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
[root@docker2 ~]# systemctl daemon-reload
[root@docker2 ~]# systemctl enable etcd.service
[root@docker2 ~]# systemctl start etcd.service

# 重启一次dockerm1的etcd
[root@dockerm1 ~]# systemctl restart etcd

# 使用etcdctl验证连接
[root@dockerm1 ssl]# etcdctl \
> --ca-file=/tools/kubernetes/ssl/ca.pem \
> --cert-file=/tools/kubernetes/ssl/server.pem \
> --key-file=/tools/kubernetes/ssl/server-key.pem \
> --endpoints="https://192.168.1.35:2379,\
> https://192.168.1.31:2379,\
> https://192.168.1.32:2379" cluster-health
member 49cc7ce5639c4e1a is healthy: got healthy result from https://192.168.1.32:2379
member a155000d15c5b5b6 is healthy: got healthy result from https://192.168.1.31:2379
member afdb491c59ce63ff is healthy: got healthy result from https://192.168.1.35:2379
cluster is healthy
```
### 部署flannel网络
#### 向 etcd 写入集群 Pod 网段信息
```
[root@dockerm1 ~]# cd /tools/kubernetes/ssl/
[root@dockerm1 ssl]# /tools/kubernetes/bin/etcdctl \
--ca-file=ca.pem --cert-file=server.pem \
--key-file=server-key.pem \
--endpoints="https://192.168.1.35:2379,\
https://192.168.1.31:2379,https://192.168.1.32:2379" \
set /coreos.com/network/config  '{ "Network": "172.17.0.0/16", "Backend": {"Type":"vxlan"}}'

{ "Network": "172.17.0.0/16", "Backend": {"Type": "vxlan"}}
```
#### 安装master flannel网络
```
[root@datastore packages]# wget https://github.com/coreos/flannel/releases/download/v0.11.0/flannel-v0.11.0-linux-amd64.tar.gz
[root@dockerm1 ssl]# cd /tools/packages/
[root@dockerm1 packages]# tar zxf flannel-v0.11.0-linux-amd64.tar.gz -C ../
[root@dockerm1 packages]# cp ../flanneld ../mk-docker-opts.sh /tools/kubernetes/bin/

[root@dockerm1 ~]# vim /tools/kubernetes/config/flanneld
FLANNEL_OPTIONS="--etcd-endpoints=https://192.168.1.35:2379,https://192.168.1.31:2379,https://192.168.1.32:2379 -etcd-cafile=/tools/kubernetes/ssl/ca.pem -etcd-certfile=/tools/kubernetes/ssl/server.pem -etcd-keyfile=/tools/kubernetes/ssl/server-key.pem"

[root@dockerm1 ~]# vim /usr/lib/systemd/system/flanneld.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/tools/kubernetes/config/flanneld
ExecStart=/tools/kubernetes/bin/flanneld --ip-masq $FLANNEL_OPTIONS
ExecStartPost=/tools/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target

[root@dockerm1 ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target

[root@dockerm1 ~]# systemctl daemon-reload 
[root@dockerm1 ~]# systemctl start flanneld.service
[root@dockerm1 ~]# systemctl restart docker.service
```
#### 安装node flanneld网络
```
# 将配置文件拷贝过去
[root@dockerm1 ~]# scp /tools/kubernetes/config/flanneld 192.168.1.31:/tools/kubernetes/config/
[root@dockerm1 ~]# scp /tools/kubernetes/config/flanneld 192.168.1.32:/tools/kubernetes/config/
[root@dockerm1 ~]# scp /usr/lib/systemd/system/flanneld.service 192.168.1.31:/usr/lib/systemd/system/flanneld.service
[root@dockerm1 ~]# scp /usr/lib/systemd/system/flanneld.service 192.168.1.32:/usr/lib/systemd/system/flanneld.service
[root@dockerm1 ~]# scp /usr/lib/systemd/system/docker.service 192.168.1.31:/usr/lib/systemd/system/docker.service
[root@dockerm1 ~]# scp /usr/lib/systemd/system/docker.service 192.168.1.32:/usr/lib/systemd/system/docker.service 
[root@dockerm1 ~]# scp /tools/kubernetes/bin/flanneld /tools/kubernetes/bin/mk-docker-opts.sh 192.168.1.31:/tools/kubernetes/bin/
[root@dockerm1 ~]# scp /tools/kubernetes/bin/flanneld /tools/kubernetes/bin/mk-docker-opts.sh 192.168.1.32:/tools/kubernetes/bin/

[root@docker1 ~]# systemctl daemon-reload 
[root@docker1 ~]# systemctl start flanneld.service 
[root@docker1 ~]# systemctl restart docker.service

[root@docker2 ~]# systemctl daemon-reload 
[root@docker2 ~]# systemctl start flanneld.service 
[root@docker2 ~]# systemctl restart docker.service 
```
### 部署master节点
kubernetes master 节点运行如下组件：
- kube-apiserver
- kube-scheduler
- kube-controller-manager

kube-scheduler 和 kube-controller-manager 可以以集群模式运行，通过 leader 选举产生一个工作进程，其它进程处于阻塞模式。
#### 创建 kubelet bootstrap kubeconfig 文件
1. 解压kubernetes-server包，并复制命令
```
[root@dockerm1 tools]# mkdir kubernetes-server
[root@dockerm1 tools]# tar zxf packages/kubernetes-server-linux-amd64.tar.gz -C kubernetes-server/
[root@dockerm1 tools]# cd /tools/kubernetes-server/kubernetes/server/bin/
[root@dockerm1 bin]# cp kube-scheduler kube-apiserver kube-controller-manager kubelet kubectl /tools/kubernetes/bin/
```
2. 创建 TLS Bootstrapping Token
```
[root@dockerm1 ~]# export Bootstrap_Token=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
[root@dockerm1 ~]# cat > /tools/kubernetes/config/token.csv <<EOF
$Bootstrap_Token,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

[root@dockerm1 ]# cat /tools/kubernetes/config/token.csv
cee5834007d1d4be5fd465ae75ea3ffc,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
```
3. 创建 kubelet bootstrap kubeconfig
```
[root@dockerm1 ]# cd /tools/kubernetes/config/
[root@dockerm1 config]# vim bootstrap_kubeconfig.sh
# 创建kubelet bootstrapping kubeconfig 
BOOTSTRAP_TOKEN=cee5834007d1d4be5fd465ae75ea3ffc
KUBE_APISERVER="https://192.168.1.35:6443"
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=../ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

#----------------------

# 创建kube-proxy kubeconfig文件

kubectl config set-cluster kubernetes \
  --certificate-authority=../ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=../ssl/kube-proxy.pem \
  --client-key=../ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
[root@dockerm1 config]# sh bootstrap_kubeconfig.sh

[root@dockerm1 config]# scp bootstrap.kubeconfig kube-proxy.kubeconfig 192.168.1.31:/tools/kubernetes/config/
[root@dockerm1 config]# scp bootstrap.kubeconfig kube-proxy.kubeconfig 192.168.1.32:/tools/kubernetes/config/
```
#### 部署kube-apiserver组件
1.  创建apiserver配置文件
```
[root@dockerm1 ~]# vim /tools/kubernetes/config/kube-apiserver
KUBE_APISERVER_OPTS="--logtostderr=true \
--v=4 \
--etcd-servers=https://192.168.1.35:2379,https://192.168.1.31:2379,https://192.168.1.32:2379 \
--bind-address=192.168.1.35 \   # 安全的监听地址
--secure-port=6443 \
--advertise-address=192.168.1.35 \  # 集群通信地址
--allow-privileged=true \     # 允许授权
--service-cluster-ip-range=10.10.10.0/24 \  # 分配集群中service负载均衡中的网段
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction \    # 准入模块
--authorization-mode=RBAC,Node \    # 认证模块
--enable-bootstrap-token-auth \
--token-auth-file=/tools/kubernetes/config/token.csv \
--service-node-port-range=30000-50000 \
--tls-cert-file=/tools/kubernetes/ssl/server.pem  \
--tls-private-key-file=/tools/kubernetes/ssl/server-key.pem \
--client-ca-file=/tools/kubernetes/ssl/ca.pem \
--service-account-key-file=/tools/kubernetes/ssl/ca-key.pem \
--etcd-cafile=/tools/kubernetes/ssl/ca.pem \
--etcd-certfile=/tools/kubernetes/ssl/server.pem \
--etcd-keyfile=/tools/kubernetes/ssl/server-key.pem"
```
2. 创建 kube-apiserver systemd unit 文件
```
[root@dockerm1 ~]# vim /usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/tools/kubernetes/config/kube-apiserver
ExecStart=/tools/kubernetes/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
3. 启动服务
```
[root@dockerm1 ~]# systemctl daemon-reload
[root@dockerm1 ~]# systemctl enable kube-apiserver
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-apiserver.service to /usr/lib/systemd/system/kube-apiserver.service.
[root@dockerm1 ~]# systemctl restart kube-apiserver
[root@dockerm1 ~]# ps -ef |grep kube-apiserver
root      92089      1 47 19:14 ?        00:00:05 /tools/kubernetes/bin/kube-apiserver --logtostderr=true --v=4 --etcd-servers=https://192.168.1.35:2379,https://192.168.1.31:2379,https://192.168.1.32:2379 --bind-address=192.168.1.35 --secure-port=6443 --advertise-address=192.168.1.35 --allow-privileged=true --service-cluster-ip-range=10.10.10.0/24 --enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction --authorization-mode=RBAC,Node --enable-bootstrap-token-auth --token-auth-file=/tools/kubernetes/config/token.csv --service-node-port-range=30000-50000 --tls-cert-file=/tools/kubernetes/ssl/server.pem --tls-private-key-file=/tools/kubernetes/ssl/server-key.pem --client-ca-file=/tools/kubernetes/ssl/ca.pem --service-account-key-file=/tools/kubernetes/ssl/ca-key.pem --etcd-cafile=/tools/kubernetes/ssl/ca.pem --etcd-certfile=/tools/kubernetes/ssl/server.pem --etcd-keyfile=/tools/kubernetes/ssl/server-key.pem
root      92112  88968  0 19:14 pts/0    00:00:00 grep --color=auto kube-apiserver
```
#### 部署kube-controller-manager组件
1. 创建kube-controller-manager配置文件
```
[root@dockerm1 ~]# vim /tools/kubernetes/config/kube-controller-manager
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true \
--v=4 \
--master=127.0.0.1:8080 \
--leader-elect=true \
--address=127.0.0.1 \
--service-cluster-ip-range=10.10.10.0/24 \
--cluster-name=kubernetes \
--cluster-signing-cert-file=/tools/kubernetes/ssl/ca.pem \
--cluster-signing-key-file=/tools/kubernetes/ssl/ca-key.pem  \
--root-ca-file=/tools/kubernetes/ssl/ca.pem \
--service-account-private-key-file=/tools/kubernetes/ssl/ca-key.pem"
```
2. 创建kube-controller-manager systemd unit 文件
```
[root@dockerm1 ~]# vim /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/tools/kubernetes/config/kube-controller-manager
ExecStart=/tools/kubernetes/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
3. 启动kube-controller-manager
```
[root@dockerm1 ~]# systemctl daemon-reload
[root@dockerm1 ~]# systemctl enable kube-controller-manager
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-controller-manager.service to /usr/lib/systemd/system/kube-controller-manager.service.
[root@dockerm1 ~]# systemctl restart kube-controller-manager
[root@dockerm1 ~]# ps -ef |grep kube-controller-manager
root      92589      1  2 19:20 ?        00:00:01 /tools/kubernetes/bin/kube-controller-manager --logtostderr=true --v=4 --master=127.0.0.1:8080 --leader-elect=true --address=127.0.0.1 --service-cluster-ip-range=10.10.10.0/24 --cluster-name=kubernetes --cluster-signing-cert-file=/tools/kubernetes/ssl/ca.pem --cluster-signing-key-file=/tools/kubernetes/ssl/ca-key.pem --root-ca-file=/tools/kubernetes/ssl/ca.pem --service-account-private-key-file=/tools/kubernetes/ssl/ca-key.pem
root      92707  88968  0 19:21 pts/0    00:00:00 grep --color=auto kube-controller-manager
```
#### 部署kube-scheduler组件
1. 创建kube-scheduler配置文件
```
[root@dockerm1 ~]# vim /tools/kubernetes/config/kube-scheduler
KUBE_SCHEDULER_OPTS="--logtostderr=true --v=4 --master=127.0.0.1:8080 --leader-elect"
```
2. 创建kube-scheduler systemd unit 文件
```
[root@dockerm1 ~]# vim /usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/tools/kubernetes/config/kube-scheduler
ExecStart=/tools/kubernetes/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
3. 启动kube-scheduler
```
[root@dockerm1 ~]# systemctl daemon-reload
[root@dockerm1 ~]# systemctl enable kube-scheduler.service 
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-scheduler.service to /usr/lib/systemd/system/kube-scheduler.service.
[root@dockerm1 ~]# systemctl restart kube-scheduler.service
[root@dockerm1 ~]# ps -ef |grep kube-scheduler
root      93057      1  8 19:25 ?        00:00:01 /tools/kubernetes/bin/kube-scheduler --logtostderr=true --v=4 --master=127.0.0.1:8080 --leader-elect
root      93079  88968  0 19:25 pts/0    00:00:00 grep --color=auto kube-scheduler
```
4. 查看master集群状态
```
[root@dockerm1 ~]# kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-2               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"} 
```

### 部署node节点
kubernetes node 节点运行如下组件：
- docker 前面已经部署
- kubelet
- kube-proxy
```
[root@dockerm1 ~]# cd /tools/kubernetes-server/kubernetes/server/bin/
[root@dockerm1 bin]# scp kubelet kube-proxy kubectl 192.168.1.31:/tools/kubernetes/bin/
[root@dockerm1 bin]# scp kubelet kube-proxy kubectl 192.168.1.32:/tools/kubernetes/bin/
```
#### 部署kubelet组件
- kublet 运行在每个 node 节点上，接收 kube-apiserver 发送的请求，管理 Pod 容器，执行交互式命令，如exec、run、logs 等;
- kublet 启动时自动向 kube-apiserver 注册节点信息，内置的 cadvisor 统计和监控节点的资源使用情况;

1. 创建kubelet 参数配置文件拷贝到所有 nodes节点  
创建kubelet 参数配置模板文件：
```
[root@dockerm1 config]# vim /tools/kubernetes/config/kubelet.config
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 192.168.1.31
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.10.10.2"]
clusterDomain: cluster.local.
failSwapOn: false
authentication:
  anonymous:
    enabled: true

[root@dockerm1 config]# scp kubelet.config 192.168.1.31:/tools/kubernetes/config/
[root@dockerm1 config]# scp kubelet.config 192.168.1.32:/tools/kubernetes/config/
```
2. 创建kubeletr配置文件
```
[root@docker1 ~]# cat  /tools/kubernetes/config/kubelet.config
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 192.168.1.31
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.10.10.2"]
clusterDomain: cluster.local.
failSwapOn: false
authentication:
  anonymous:
    enabled: true

[root@docker1 ~]# vim /tools/kubernetes/config/kubelet
KUBELET_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=192.168.1.31 \
--kubeconfig=/tools/kubernetes/config/kubelet.kubeconfig \
--bootstrap-kubeconfig=/tools/kubernetes/config/bootstrap.kubeconfig \
--config=/tools/kubernetes/config/kubelet.config \
--cert-dir=/tools/kubernetes/ssl \
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"
```
2. 创建kubelet systemd unit 文件
```
[root@docker1 ~]# vim /usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=/tools/kubernetes/config/kubelet
ExecStart=/tools/kubernetes/bin/kubelet $KUBELET_OPTS
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target

```
3. 将kubelet-bootstrap用户绑定到系统集群角色
```
[root@dockerm1 config]# kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
clusterrolebinding.rbac.authorization.k8s.io/kubelet-bootstrap created
```
4. 启动kubelet
```
[root@docker1 ~]# systemctl daemon-reload
[root@docker1 ~]# systemctl enable kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.
[root@docker1 ~]# systemctl restart kubelet
```

5. approve kubelet CSR 请求

可以手动或自动 approve CSR 请求。推荐使用自动的方式，因为从 v1.8 版本开始，可以自动轮转approve csr 后生成的证书。  
手动 approve CSR 请求   
查看 CSR 列表：
```
[root@dockerm1 ]# kubectl get csr
NAME                                                   AGE   REQUESTOR           CONDITION
node-csr-9KjeEJiZiMPVJvNko4DXyxJCt7w6nBD6bCEAqDdRbI0   78s   kubelet-bootstrap   Pending
[root@dockerm1 ]# kubectl certificate approve node-csr-9KjeEJiZiMPVJvNko4DXyxJCt7w6nBD6bCEAqDdRbI0
certificatesigningrequest.certificates.k8s.io/node-csr-9KjeEJiZiMPVJvNko4DXyxJCt7w6nBD6bCEAqDdRbI0 approved
[root@dockerm1 ~]# kubectl certificate approve node-csr-wHfAoxSFqKgmbtQhiTJBwPnp3gYaC4V6LzKEMbHUbtA
certificatesigningrequest.certificates.k8s.io/node-csr-wHfAoxSFqKgmbtQhiTJBwPnp3gYaC4V6LzKEMbHUbtA approved
[root@dockerm1 ~]# kubectl get csr
NAME                                                   AGE     REQUESTOR           CONDITION
node-csr-9KjeEJiZiMPVJvNko4DXyxJCt7w6nBD6bCEAqDdRbI0   13m     kubelet-bootstrap   Approved,Issued
node-csr-wHfAoxSFqKgmbtQhiTJBwPnp3gYaC4V6LzKEMbHUbtA   4m42s   kubelet-bootstrap   Approved,Issued

[root@dockerm1 ~]# kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
192.168.1.31   Ready    <none>   24s   v1.15.3
192.168.1.32   Ready    <none>   11m   v1.15.3
```
- Requesting User：请求 CSR 的用户，kube-apiserver 对它进行认证和授权；
- Subject：请求签名的证书信息；
- 证书的 CN 是 system:node:kube-node2， Organization 是 system:nodes，kube-apiserver - 的 Node 授权模式会授予该证书的相关权限；
#### 部署kube-proxy组件
kube-proxy 运行在所有 node节点上，它监听 apiserver 中 service 和 Endpoint 的变化情况，创建路由规则来进行服务负载均衡。
1. 创建 kube-proxy 配置文件

```
[root@docker1 ~]# vim /tools/kubernetes/config/kube-proxy
KUBE_PROXY_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=192.168.1.31 \
--cluster-cidr=10.10.10.0/24 \
--kubeconfig=/tools/kubernetes/config/kube-proxy.kubeconfig"
```
- bindAddress: 监听地址；
- clientConnection.kubeconfig: 连接 apiserver 的 kubeconfig 文件；
- clusterCIDR: kube-proxy 根据 –cluster-cidr 判断集群内部和外部流量，指定 –cluster-cidr 或 –masquerade-all 选项后 kube-proxy 才会对访问 Service IP 的请求做 SNAT；
- hostnameOverride: 参数值必须与 kubelet 的值一致，否则 kube-proxy 启动后会找不到该 Node，从而不会创建任何 ipvs 规则；
- mode: 使用 ipvs 模式；
2. 创建kube-proxy systemd unit 文件
```
[root@docker1 ~]# vim /usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/tools/kubernetes/config/kube-proxy
ExecStart=/tools/kubernetes/bin/kube-proxy $KUBE_PROXY_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
3. 启动kube-proxy
```
[root@docker1 ~]# systemctl daemon-reload
[root@docker1 ~]# systemctl enable kube-proxy
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-proxy.service to /usr/lib/systemd/system/kube-proxy.service.
[root@docker1 ~]# systemctl restart kube-proxy
```
### 集群状态
#### 打master或者node节点的标签
```
kubectl label node 192.168.1.35  node-role.kubernetes.io/master='master'
kubectl label node 192.168.1.31  node-role.kubernetes.io/node='node'
kubectl label node 192.168.1.32  node-role.kubernetes.io/node='node'

[root@dockerm1 ~]# kubectl get node,cs
NAME                STATUS   ROLES   AGE   VERSION
node/192.168.1.31   Ready    node    13m   v1.15.3
node/192.168.1.32   Ready    node    24m   v1.15.3

NAME                                 STATUS    MESSAGE             ERROR
componentstatus/controller-manager   Healthy   ok                  
componentstatus/scheduler            Healthy   ok                  
componentstatus/etcd-1               Healthy   {"health":"true"}   
componentstatus/etcd-2               Healthy   {"health":"true"}   
componentstatus/etcd-0               Healthy   {"health":"true"} 
```
## 部署Kubernetes dashboard
文件下载地址:https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dashboard
```
[root@dockerm1 ~]# mkdir /tools/kubernetes/UI
[root@dockerm1 ~]# cd /tools/kubernetes/UI/
```
```
[root@dockerm1 UI]# vim dashboard-controller.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    addonmanager.kubernetes.io/mode: Reconcile
  name: kubernetes-dashboard
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      priorityClassName: system-cluster-critical
      containers:
      - name: kubernetes-dashboard
        image: registry.cn-hangzhou.aliyuncs.com/google-containers/kubernetes-dashboard-amd64:v1.10.1
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 50m
            memory: 100Mi
        ports:
        - containerPort: 8443
          protocol: TCP
        args:
          # PLATFORM-SPECIFIC ARGS HERE
          - --auto-generate-certificates
        volumeMounts:
        - name: kubernetes-dashboard-certs
          mountPath: /certs
        - name: tmp-volume
          mountPath: /tmp
        livenessProbe:
          httpGet:
            scheme: HTTPS
            path: /
            port: 8443
          initialDelaySeconds: 30
          timeoutSeconds: 30
      volumes:
      - name: kubernetes-dashboard-certs
        secret:
          secretName: kubernetes-dashboard-certs
      - name: tmp-volume
        emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
```
```
[root@dockerm1 UI]# vi dashboard-rbac.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    addonmanager.kubernetes.io/mode: Reconcile
  name: kubernetes-dashboard-minimal
  namespace: kube-system
rules:
  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]
  verbs: ["get", "update", "delete"]
  # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["kubernetes-dashboard-settings"]
  verbs: ["get", "update"]
  # Allow Dashboard to get metrics from heapster.
- apiGroups: [""]
  resources: ["services"]
  resourceNames: ["heapster"]
  verbs: ["proxy"]
- apiGroups: [""]
  resources: ["services/proxy"]
  resourceNames: ["heapster", "http:heapster:", "https:heapster:"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubernetes-dashboard-minimal
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    addonmanager.kubernetes.io/mode: Reconcile
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard-minimal
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
```
```
[root@dockerm1 UI]# cat dashboard-configmap.yaml 
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    # Allows editing resource and makes sure it is created first.
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kubernetes-dashboard-settings
  namespace: kube-system
```
```
[root@dockerm1 UI]# cat dashboard-secret.yaml 
apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    # Allows editing resource and makes sure it is created first.
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kubernetes-dashboard-certs
  namespace: kube-system
type: Opaque
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
    # Allows editing resource and makes sure it is created first.
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kubernetes-dashboard-key-holder
  namespace: kube-system
type: Opaque
```
```
[root@dockerm1 UI]# vi dashboard-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
  ports:
  - port: 443
    targetPort: 8443
```
```
[root@dockerm1 UI]# kubectl create -f dashboard-rbac.yaml 
[root@dockerm1 UI]# kubectl create -f dashboard-controller.yaml 
[root@dockerm1 UI]# kubectl create -f dashboard-configmap.yaml  
[root@dockerm1 UI]# kubectl create -f dashboard-secret.yaml 
[root@dockerm1 UI]# kubectl create -f dashboard-service.yaml

[root@dockerm1 UI]# kubectl get pod -n kube-system
NAME                                    READY   STATUS    RESTARTS   AGE
kubernetes-dashboard-756b84b78d-xv8ws   1/1     Running   7          12m

[root@dockerm1 config]# kubectl get all -n kube-system -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/kubernetes-dashboard-756b84b78d-xv8ws   1/1     Running   7          31m   172.17.73.3   192.168.1.31   <none>           <none>

NAME                           TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE   SELECTOR
service/kubernetes-dashboard   NodePort   10.10.10.135   <none>        443:47825/TCP   16m   k8s-app=kubernetes-dashboard
```
```
访问网页https://192.168.1.31:47825
```
### 创建一个管理员用户
```
[root@dockerm1 UI]# vim admin-user.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile

# 通过执行如下命令创建admin-user
[root@dockerm1 UI]# kubectl create -f admin-user.yaml 
clusterrolebinding.rbac.authorization.k8s.io/admin created
serviceaccount/admin created

# 获取管理员用户的Token
[root@dockerm1 UI]# kubectl describe  secret admin --namespace=kube-system
Name:         admin-token-fgmnq
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin
              kubernetes.io/service-account.uid: e3126460-959c-416d-8055-7a359f1b2d62

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1281 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi1mZ21ucSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImUzMTI2NDYwLTk1OWMtNDE2ZC04MDU1LTdhMzU5ZjFiMmQ2MiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.Mc--vIoKFPF8VPZ85br6M27tLNR8n0fteknREJo7I1lhbsFTHqOTFZ2vk4aozDqm9NQtTlZ-D3MByQQwZSt9oGN0wmcvyBLtfJQLeQJs3dsEd1ZUM3mU6S3LxaXm5Ug4OcbpnVAW1GXKlYR3T4JdZZlZROOF8V7pYx0BFKIn4XotJ65gqUhnWmra1j4Mav6JNpsiN416eukGn7aoq9zFVXMLiv5s5ldrQb2BS9RLm76tw1fOq03cDxWfN-iifgrPs4uXTh6tJrwrWwSEEtOwdHILNkHqwAb621yv8mEN3opp4vUO_IoKYOLDNcq-qTcs4yJxXdnf6A_vB4wEmL_mFw
```




