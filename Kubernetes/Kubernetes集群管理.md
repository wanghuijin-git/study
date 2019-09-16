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


















