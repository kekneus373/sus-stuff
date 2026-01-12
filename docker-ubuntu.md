Docker ubuntu

To install Docker on Ubuntu, ensure you are using a supported version such as Ubuntu 25.10, 25.04, 24.04 (LTS), or 22.04 (LTS), as Docker Engine is compatible with these releases  The installation supports x86_64 (amd64), armhf, arm64, s390x, and ppc64le (ppc64el) architectures  While derivative distributions like Linux Mint may work, they are not officially supported 

Before installing, uninstall any conflicting packages such as `docker.io`, `docker-compose`, `docker-compose-v2`, `docker-doc`, `podman-docker`, `containerd`, and `runc` to avoid conflicts with Docker Engine’s bundled dependencies  Use the command `sudo apt remove $( dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1 )` to remove these packages 

To install Docker Engine, set up Docker’s official apt repository by adding the GPG key and repository source. Run the following commands:

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Then, add the repository to APT sources using:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Update the package index with `sudo apt update` and install Docker Engine using:

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

The Docker service starts automatically after installation. Verify it is running with `sudo systemctl status docker`  To test the installation, run the `hello-world` image with `sudo docker run hello-world`, which downloads a test image and confirms Docker is working correctly 

For non-root users to run Docker commands without `sudo`, add the user to the `docker` group using `sudo usermod -aG docker ${USER}` and log out and back in to apply the change  Note that Docker may bypass firewall rules set by `ufw` or `firewalld` when exposing container ports, so ensure firewall rules are configured using `iptables` or `ip6tables` and added to the `DOCKER-USER` chain 

Alternative installation methods include using Docker Desktop for Linux , installing manually via `.deb` files from the Docker download site , or using the convenience script at `https://get.docker.com/`, though this is not recommended for production environments  For beginners, Ubuntu LTS versions are recommended due to their stability and widespread tutorial support 