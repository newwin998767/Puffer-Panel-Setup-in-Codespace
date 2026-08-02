sudo apt update

mkdir -p /workspaces/Puffer-Panel-Setup-in-Codespace/pufferpanel/config
mkdir -p /workspaces/Puffer-Panel-Setup-in-Codespace/pufferpanel/data

docker pull pufferpanel/pufferpanel:latest

docker run -d \
  --name pufferpanel \
  -p 8080:8080 \
  -p 5657:5657 \
  -v /workspaces/Puffer-Panel-Setup-in-Codespace/pufferpanel/config:/etc/pufferpanel \
  -v /workspaces/Puffer-Panel-Setup-in-Codespace/pufferpanel/data:/var/lib/pufferpanel \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  pufferpanel/pufferpanel:latest

docker exec -it pufferpanel sh

/pufferpanel/bin/pufferpanel user add
exit
