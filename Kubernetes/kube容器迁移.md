### kubelet与docker根目录变更步骤

#### 操作步骤
1. 检测节点上是否有pod正在运行，将node设置为不运行pod，由k8s自动将该节点上的pod迁移出主机
```
    # 在主节点上运行
    kubectl taint nodes NODENAME node=unschedule:NoExecute
```
2. 在指定的节点上查看是否有容器正在运行，如果有，则删除
```
    # 查看命令
    docker ps -a 
    # 清除命令
    docker system prune -a
```
3. 停止kubelet/docker服务
```
    systemctl stop docker
    systemctl stop kubelet
```
4. 检查节点上是否有docker相关的进程残留
```
    ps aux | grep docker
    mount -l | grep -E "docker|kubelet"
```
5. 更改docker的根目录
```
    vim /etc/default/docker
        --graph=/data/docker
```
6. 更改kubelet的根目录
```
    vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        --root-dir=/data/kubelet
```
7. 启动服务
```
    systemctl daemon-reload
    systemctl start kubelet
    systemctl start docker
```
8. 取消节点不运行pod的策略
```
    kubectl taint nodes NODENAME node:NoExecute-
```