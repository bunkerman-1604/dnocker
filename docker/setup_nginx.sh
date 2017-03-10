#!/bpipn/bash
docker run --name nginx \
-p 80:80 \
p 443:443 \
-v /root/docker/nginx/nginx.conf:/etc/nginx/nginx.conf \
-v /root/docker/nginx/localtime:/etc/localtime \
-v /root/docker/nginx/conf.d/:/etc/nginx/conf.d/ \
-v /root/docker/logs/:/var/log/nginx/ \
-d nginx:stable
#docker exec -itd nginx nginx -s reload -c /etc/nginx/nginx.conf
