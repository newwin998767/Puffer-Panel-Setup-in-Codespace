# PufferPanel in a GitHub Codespace

Run [PufferPanel](https://pufferpanel.com/) (a game server management panel) inside a
GitHub Codespace, using Docker-in-Docker. Everything is automated: open the Codespace,
wait for setup to finish, create an admin user, and log in.

> **Read this before you start.** Codespaces are great for testing PufferPanel or
> spinning up a short-lived server, but they are **not** a real hosting solution. See
> [Limitations](#limitations) below.

## What you get

- ✅ PufferPanel web panel, fully working, in your browser
- ✅ Docker running inside the Codespace (Docker-in-Docker), so PufferPanel can spin up
  game server containers
- ✅ Setup automated via `devcontainer.json` — no manual `apt install docker.io`
- ✅ Data persisted in the workspace + a Docker volume, so it survives Codespace restarts
- ✅ A helper script for tunneling a raw TCP game port (e.g. Minecraft's 25565) to the
  outside world, since Codespaces only forwards HTTP(S) ports

## Limitations

| | |
|---|---|
| ✅ | PufferPanel web panel works |
| ✅ | Docker containers (game servers) can run inside Codespaces |
| ❌ | **Not suitable for 24/7 hosting.** Codespaces auto-stop after a period of inactivity (default ~30 min), and free/personal plans have monthly usage limits |
| ❌ | Codespaces only forwards HTTP(S) ports through its UI. Raw TCP game ports (Minecraft's 25565, etc.) need a separate tunnel (Pinggy, playit.gg, ngrok, etc.) |
| ⚠️ | Public tunnel addresses (Codespace URL, Pinggy address) can change when the Codespace or tunnel restarts, so players may need a new address periodically |

This setup is best for: testing PufferPanel, developing/debugging server templates,
short game sessions with friends, or learning how PufferPanel works — not for a
server you expect to stay online continuously.

## Quick start

1. **Create the Codespace.** Click the green "Code" button on this repo → **Codespaces**
   → **Create codespace on main**. If you're offered a machine-size choice, pick at
   least **4 cores / 8 GB RAM**.
2. **Wait for setup to finish.** The first boot runs `.devcontainer/scripts/setup-pufferpanel.sh`
   automatically (via `onCreateCommand`), which:
   - installs/starts Docker (via the Docker-in-Docker devcontainer feature)
   - pulls the `pufferpanel/pufferpanel:latest` image
   - creates a Docker volume for config and a folder in the workspace for server data
   - starts the PufferPanel container
3. **Create your admin user:**
   ```bash
   bash scripts/create-admin.sh
   ```
   You'll be prompted for:
   ```
   Username:
   Email:
   Password:
   Admin? (y/n)   <- answer y
   ```
4. **Open the panel.** Go to the **Ports** tab (bottom panel in VS Code / the
   Codespaces web UI), find port **8080**, set its visibility to **Public**, then click
   the forwarded address. It looks like:
   ```
   https://YOUR-CODESPACE-NAME-8080.app.github.dev
   ```
   Log in with the account you just created.
5. **Create a server.** Inside PufferPanel: **Templates** → import the Minecraft
   template if it isn't already there → **Create Server** → pick e.g. Paper → choose a
   version → set RAM → **Start**.
6. **Expose the game port to players.** Codespaces doesn't forward arbitrary TCP ports,
   so once your server is running, open a tunnel:
   ```bash
   bash scripts/tunnel-game-port.sh 25565
   ```
   Pinggy will print a public `tcp://...` address — give that (not the Codespace URL)
   to players.

## Repo layout

```
.
├── .devcontainer/
│   ├── devcontainer.json          # Docker-in-Docker feature, forwarded ports, lifecycle hooks
│   └── scripts/
│       ├── setup-pufferpanel.sh   # runs once on Codespace creation
│       └── start-pufferpanel.sh   # runs on every Codespace start/resume
├── scripts/
│   ├── create-admin.sh            # interactive: creates a PufferPanel user
│   └── tunnel-game-port.sh        # opens a free Pinggy TCP tunnel to a local port
├── docker-compose.yml             # optional alternative to the raw `docker run` setup
├── .gitignore
└── README.md
```

## Does Docker survive a Codespace restart?

**Yes, mostly automatically** — two things need to happen, and both are handled here:

1. **The Docker daemon itself** needs to start. GitHub Codespaces normally starts it
   automatically when using the Docker-in-Docker devcontainer feature. `postStartCommand`
   also explicitly waits for it, just in case.
2. **The `pufferpanel` container** needs to be restarted. It was created with
   `--restart unless-stopped`, so once the Docker daemon is up, Docker restarts it on its
   own. The `postStartCommand` script (`start-pufferpanel.sh`) double-checks this on every
   Codespace start and starts the container manually if it isn't already running.

Verify manually any time with:

```bash
docker ps                 # should show pufferpanel as "Up ..."
docker ps -a               # if it's not running, check it still exists
docker start pufferpanel   # start it manually if needed
docker info                 # confirms the Docker daemon itself is up
```

**Important:** stopping the *Codespace* stops the container. Files in
`pufferpanel-data/` (this workspace) and the `pufferpanel-config` Docker volume persist
across restarts of the same Codespace. If you **delete** the Codespace entirely, that
data is gone — it's not pushed to the git repo (see `.gitignore`).

## Manual setup (no devcontainer)

If you'd rather run the commands by hand inside a plain Codespace instead of using the
devcontainer, here's the full sequence:

```bash
# 1. Update packages
sudo apt update

# 3. Create folders
mkdir -p /pufferpanel/config /pufferpanel/data

# 4. Pull the image
docker pull pufferpanel/pufferpanel:latest

# 5. Create the config volume
docker volume create pufferpanel-config

# 6. Run the container
docker run -d \
  --name pufferpanel \
  -p 8080:8080 \
  -p 5657:5657 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v pufferpanel-config:/etc/pufferpanel \
  -v "$(pwd)/pufferpanel/data:/var/lib/pufferpanel" \
  --restart unless-stopped \
  pufferpanel/pufferpanel:latest

# 7. Create the admin user
docker exec -it pufferpanel pufferpanel user add
```

Then forward port 8080 (Ports tab → 8080 → Visibility → Public) and open the URL.

### If you hit "permission denied" talking to Docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

or just prefix Docker commands with `sudo`.

## Troubleshooting

- **`docker: command not found`** — the Docker-in-Docker feature may still be
  installing; wait a moment, or check `.devcontainer/devcontainer.json` is present and
  the Codespace was rebuilt after adding it.
- **Container exists but isn't running** — `docker start pufferpanel`.
- **Port 8080 shows "not found" / blank page** — make sure the port's visibility is set
  to Public in the Ports tab, and that you're using the forwarded `*.app.github.dev` URL,
  not `localhost`.
- **Players can't connect to the Minecraft server** — the game port itself (25565) isn't
  forwarded by Codespaces; you need the Pinggy tunnel (`scripts/tunnel-game-port.sh`) or
  a similar TCP tunnel, and must give players that address, not the Codespace URL.
- **Codespace stopped after inactivity and everything's gone** — the *container* stops,
  but data in `pufferpanel-data/` and the `pufferpanel-config` volume is still there.
  Just restart the Codespace; `postStartCommand` brings the container back up.

## Credits / references

- [PufferPanel](https://pufferpanel.com/) — [Docker installation docs](https://docs.pufferpanel.com/en/2.x/installing-docker.html)
- [Pinggy](https://pinggy.io/) — free TCP tunnel used for exposing game ports
- [Dev Container Docker-in-Docker feature](https://github.com/devcontainers/features/tree/main/src/docker-in-docker)
