Here's how to install Docker on Arch Linux, build and run a Docker image from a Dockerfile, and start an interactive shell session inside the container.

### 1. Install Docker on Arch Linux

First, update your package list and install Docker:

```bash
sudo pacman -Syu docker
```

### 2. Start and Enable the Docker Service

Enable the Docker service to start on boot and start it immediately:

```bash
sudo systemctl enable --now docker
```

*Optional:* Add your user to the `docker` group to avoid using `sudo` for Docker commands (requires logout/login):
```bash
sudo usermod -aG docker $USER
```

### 3. Build the Docker Image

Navigate to the directory containing your `Dockerfile` and build the image. Replace `my-app` with your desired image name.

```bash
docker build -t my-app .
```

### 4. Run the Container with an Interactive Shell

To run the container and immediately drop into an interactive shell (usually `bash` or `sh`), use the `-it` flags. You must ensure your Dockerfile has a shell available (e.g., `bash` or `sh`).

```bash
docker run -it --rm --name my-running-container my-app sh
```

*   `-it`: Runs the container in interactive mode with a pseudo-TTY.
*   `--rm`: Automatically removes the container when you exit.
*   `my-app sh`: Runs the `sh` command inside the image. If your image uses `bash`, replace `sh` with `bash`.

If your Dockerfile sets a specific `ENTRYPOINT` or `CMD` that isn't a shell, using `sh` or `bash` at the end of the command overrides it to give you access to the shell.


---

That message indicates your system is using the legacy Docker builder, but recommends switching to **BuildKit** via the `buildx` component for better performance and modern features.

Here is how to enable BuildKit on Arch Linux so the warning goes away and you use the modern builder:

### 1. Install the Buildx Component
On Arch Linux, the `docker-buildx` package is usually available in the official repositories.

```bash
sudo pacman -S docker-buildx
```

### 2. Enable BuildKit
You can enable BuildKit by setting the `DOCKER_BUILDKIT` environment variable. You can do this temporarily for the current session:

```bash
export DOCKER_BUILDKIT=1
```

To make it permanent, add it to your shell configuration file (e.g., `~/.bashrc` or `~/.zshrc`):

```bash
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
source ~/.bashrc
```

*Alternatively, you can configure it globally in Docker by creating or editing `/etc/docker/daemon.json`:*

```json
{
  "features": {
    "buildkit": true
  }
}
```
*Note: If you edit `daemon.json`, you need to restart the Docker service (`sudo systemctl restart docker`).*

### 3. Rebuild Your Image
Now, run your build command again. The legacy warning should be gone, and it will use the BuildKit builder:

```bash
docker build -t my-app .
```

### 4. Run the Container
Once built, run it as before:

```bash
docker run -it --rm my-app sh
```

If `sh` is not available in your image, try `bash`:
```bash
docker run -it --rm my-app bash
```


> Written with [StackEdit](https://stackedit.io/).
