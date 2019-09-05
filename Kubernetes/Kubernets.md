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
### 安装 Etcd
#### 创建集群 CA 与 Certificates
```
[root@dockerm1 ~]# mkdir /tools/kubernetes/{bin,config,ssl} -p
# 下载cfssl工具用于创建自签证书
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O  /tools/kubernetes/bin/cfssl
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O  /tools/kubernetes/bin/cfssljson
[root@dockerm1 ~]# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O  /tools/kubernetes/bin/cfssl-certinfo





