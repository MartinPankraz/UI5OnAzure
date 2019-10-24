docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker build -t mynginximage1 .
docker run --name mynginx1 -P -d mynginximage1