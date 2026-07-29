# PufferPanel setup in GitHub Codespaces

This repository contains a simple setup script for running [PufferPanel](https://pufferpanel.com/) inside a GitHub Codespace. The current workflow uses a root-level script, [setup.sh](setup.sh), to[...]

## What the current setup does

- Installs package updates in the Codespace
- Creates persistent folders for PufferPanel data at [pufferpanel/config](pufferpanel/config) and [pufferpanel/data](pufferpanel/data)
- Pulls the official PufferPanel Docker image
- Creates a Docker volume named `pufferpanel-config`
- Starts a container named `pufferpanel` exposing ports `8080` and `5657`
- Opens an interactive shell inside the container so you can create an administrator user

## Quick start

1. Open this repository in GitHub Codespaces.
2. Run the setup script:
   ```bash
   bash setup.sh
   ```
3. When the script finishes, it will open a shell inside the container. Create your admin account with:
   ```bash
   /pufferpanel/bin/pufferpanel user add
   ```
4. In the VS Code or Codespaces Ports panel, make port `8080` public and open the forwarded URL.
5. Log in to PufferPanel with the account you created.

## Repository layout

```text
.
├── README.md
├── setup.sh
└── pufferpanel/
    ├── config/
    └── data/
```

- [setup.sh](setup.sh): main setup script for preparing the environment
- [pufferpanel/config](pufferpanel/config): persistent PufferPanel configuration directory
- [pufferpanel/data](pufferpanel/data): persistent server data directory

## Notes

- This setup is intended for testing and short-term use inside a Codespace.
- Codespaces are not meant to be a permanent hosting platform for production game servers.
- If the container stops, you can restart it with:
  ```bash
  docker start pufferpanel
  ```

## Troubleshooting

- If Docker is not available, wait a moment and run the setup script again.
- If the PufferPanel web UI does not load, verify that port `8080` is published and public.
- If the container is not running, start it manually with `docker start pufferpanel`.

## Useful commands

- Check running containers:
  ```bash
  docker ps
  ```

- View logs:
  ```bash
  docker logs pufferpanel
  ```

- Restart PufferPanel:
  ```bash
  docker restart pufferpanel
  ```

- Stop PufferPanel:
  ```bash
  docker stop pufferpanel
  ```

- Start PufferPanel:
  ```bash
  docker start pufferpanel
  ```

- Remove PufferPanel:
  ```bash
  docker rm -f pufferpanel
  ```

- Enter the container again:
  ```bash
  docker exec -it pufferpanel sh
  ```
