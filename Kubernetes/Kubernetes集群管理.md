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












