# Custom Aurora DX

This is my own custom Universal Blue image, that is based off of the aurora-dx:daily-stable which I use for work. I have customised the <https://github.com/ublue-os/image-template> template to build this image.

# Rebasing to this image

Feel free to use this image if you wish, but I will not be providing support for this image

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/wolfyreload/aurora-ewx:daily-stable
```

# Setup dotnet

Install latest dotnet sdk with `dotnet-install --channel 9.0` if you want to install the dotnet runtime `dotnet-install --runtime dotnet --version 6.0.0`

Allow all users to use the dotnet runtime and sdk

```bash
echo "export DOTNET_ROOT=$HOME/.dotnet" | sudo tee /etc/profile.d/dotnet.sh
echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' | sudo tee --append /etc/profile.d/dotnet.sh
```

# Setup nvm and nodejs

run `install-nvm`

```
echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' | sudo tee /etc/profile.d/nvm.sh
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' | sudo tee --append /etc/profile.d/nvm.sh
```

Run `nvm install --lts` to install the latest lts version of nodejs
