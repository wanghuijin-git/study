# Kubernetes集群管理
## Kubectl管理工具
### 创建
- kubectl run nginx --replicas=3 --labels="app=nginx" --image=reg.jcx.com/jcx/nginx:0.1 --port=80
- kubectl run test --replicas=2 --labels="base=test" --image=reg.jcx.com/jcx/centos_base:0.2 --command -- ping 127.0.0.1

### 查看
- 查看pod所有信息
    - kubectl get all
- 查看pod详细信息(包括创建过程)
    - kubectl describe pod/nginx-54459467d4-gfqqq
- 查看get命令所支持的所有资源
    - kubectl api-resources
- 查看pods所有的标签
    - kubectl get pods --show-labels
- 通过标签来查看pods
    - kubectl get pods -l app=nginx
- 查看具体的详细信息
    - kubectl get pods -o wide

### 发布
- 发布服务并暴露端口
    - kubectl expose deployment nginx --port=88 --type=NodePort --target-port=80 --name=nginx-test
- 查看服务的具体信息
    - kubectl describe service nginx-test

### 故障排查
- 查看具体状态
    - kubectl describe pods pod/nginx-54459467d4-gfqqq
    - kubectl describe deployment nginx
    - kubectl describe service nginx-test
- 查看pod日志
    - kubectl logs pod/nginx-54459467d4-gfqqq
- 进入容器查看
    - kubectl exec -it pod/nginx-54459467d4-gfqqq sh

### 更新
- 更新pod镜像
    - kubectl set image deployment/nginx nginx=nginx:1.11
    - kubectl edit deployment.apps/nginx
- 发布状态
    - kubectl rollout status deployment nginx
- 发布记录
    - kubectl rollout history deployment nginx

### 回滚
- 回滚到上一个状态
    - kubectl rollout undo deployment nginx

### 扩容/缩容
- 扩容/缩容pod数量
    - kubectl scale deployment nginx --replicas=5

### 删除
- 删除资源
    - kubectl delete deployment,svc nginx

## YAML配置示例
### pods
```
[root@dockerm1 k8s]# cat nginx-deployment.yaml 
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
  labels:
    web: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: reg.jcx.com/jcx/nginx:0.1
        ports:
        - containerPort: 80

[root@dockerm1 k8s]# kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-54459467d4-5hqbv   1/1     Running   0          19s
nginx-deployment-54459467d4-5wpw5   1/1     Running   0          19s
nginx-deployment-54459467d4-mgdcm   1/1     Running   0          19s
```
### service
```
[root@dockerm1 k8s]# cat nginx-service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: NodePort
  ports:
  - port: 8081
    targetPort: 80
  selector:
    app: nginx

[root@dockerm1 k8s]# kubectl get service
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
nginx-service   NodePort    10.10.10.140   <none>        8081:43120/TCP   59s

[root@dockerm1 k8s]# kubectl describe service nginx-service
Name:                     nginx-service
Namespace:                default
Labels:                   app=nginx
Annotations:              <none>
Selector:                 app=nginx
Type:                     NodePort
IP:                       10.10.10.140
Port:                     <unset>  8081/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  43120/TCP
Endpoints:                172.17.62.2:80,172.17.62.3:80,172.17.73.2:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### 查看apiVersion/kind相关选项
- 查看所有支持的API版本(apiVersion/kind）
```
kubectl api-versions
```
- 查看所有支持的API资源
```
kubectl api-resources
```
- 查看具体某个API组所支持的API资源
```
kubectl api-resources --api-group=apps
```

## pod管理
### pod基本管理
```
[root@dockerm1 k8s]# cat nginx-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: reg.jcx.com/jcx/nginx:0.1
```
#### 创建pod资源
```
kubectl create -f nginx-pod.yaml
```
#### 查看pod资源
```
kubectl get pod nginx-pod

kubectl describe pod nginx-pod
```
#### 更新镜像
```
kubectl replace -f nginx-pod.yaml --force

kubectl apply -f nginx-pod.yaml
```
> 对pod是先删除再创建
#### 删除镜像
```
kubectl delete -f nginx-pod.yaml

kubectl delete pod nginx-pod
```
### pod资源限制
```
[root@dockerm1 k8s]# cat nginx-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-test
    image: reg.jcx.com/jcx/nginx:0.1
    resources:
      requests:         # 保证最小使用资源情况
        cpu: "250m"
        memory: "64Mi"
      limits:           # 容器的硬性限制
        cpu: "500m"
        memory: "128Mi"

[root@dockerm1 k8s]# kubectl describe pod nginx-pod
Name:         nginx-pod
...
Containers:
  nginx-test:
  ...
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        250m
      memory:     64Mi
    ...
```
### pod调度约束
- Pod.spec.nodeName  强制约束pod调度到指定node节点上
- pod.spec.nodeSelector  通过label-selector机制选择节点
```
# 创建一个属于docker2主机的标签
[root@dockerm1 k8s]# kubectl label nodes 192.168.1.32 test1=nginx-pod
node/192.168.1.32 labeled

[root@dockerm1 k8s]# cat nginx-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
#  nodeName: 192.168.1.32
  nodeSelector:
    test1: nginx-pod
  containers:
  - name: nginx-test
    image: reg.jcx.com/jcx/nginx:0.1

[root@dockerm1 k8s]# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx-pod                           1/1     Running   0          3s    172.17.62.4   192.168.1.32   <none>           <none>

```
### pod重启策略
三种重启策略
- Always：当容器停止，总是重建容器，默认策略
- OnFailure：当容器异常退出(退出状态码非0)时，才重启容器
- Nerver：当容器终止退出，从不重启容器
```
[root@dockerm1 k8s]# cat nginx-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-test
    image: reg.jcx.com/jcx/nginx:0.1
  restartPolicy: OnFailure
```











