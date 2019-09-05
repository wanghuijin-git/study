#### docker macvlan ipv6实现测试
```
# 创建支持IPv6的macvlan网络
docker network create -d macvlan \
    --subnet=192.168.0.0/24 --gateway=192.168.0.1 \
    --subnet=fd00:192:168:0::/64 --gateway=fd00:192:168:0::254 \
    -o parent=eth0 \
    --ipv6 \
    macvlan-ipv6

# 查看创建的Macvlan网络
docker network ls

# 创建容器并使用刚才创建的Macvlan网络
# 自动分配IPv4，IPv6地址
docker run \
  -td \
  --name='container0' \
  --hostname='container0' \
  --net=macvlan-ipv6 \
  --entrypoint=bash \
  mysql:mdi

# 手动指定ipv4、ipv6地址
docker run \
  -td \
  --name='container1' \
  --hostname='container1' \
  --net=macvlan-ipv6 \
  --ip=192.168.0.67 \
  --ip6=fd00:192:168:0::67 \
  --entrypoint=bash \
  mysql:mdi
```