sudo apt update
mkdir -p pufferpanel/config pufferpanel/data
docker pull pufferpanel/pufferpanel:latest
docker volume create pufferpanel-config
docker run -d \
  --name pufferpanel \
  -p 8080:8080 \
  -p 5657:5657 \
  -v pufferpanel-config:/etc/pufferpanel \
  -v /pufferpanel/data:/var/lib/pufferpanel \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  pufferpanel/pufferpanel:latest
docker exec -it pufferpanel sh


/pufferpanel/bin/pufferpanel user add
exit
