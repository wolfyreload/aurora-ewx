# Wolfy Bazzite-dx Custom Image

This is my own custom Universal Blue image, that is based off of the bazzite-gnome-nvidia:testing image. I have customised the <https://github.com/ublue-os/image-template> template to build this image.

I use this image for lite coding and it has a few things that I like and use for development in my free time.

# Custom software

- **Visual Studio Code** - While both flatpak and rpm-ostree options are available, the rpm-ostree version offers better integration with the system.
- **gparted** - This lightweight partition editor is my preference over the KDE alternative.
- **qdirstat** - Very useful space monitoring tool
- **nemo** - Prefer this to gnome-files
- **ghostty** - Modern terminal emulator
- **docker** - Most guides use docker and not podman

# Rebasing to this image

Feel free to use this image if you wish, but I will not be providing support for this image

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/wolfyreload/bazzite-wolfy:stable
```
