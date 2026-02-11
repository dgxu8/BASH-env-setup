# Initial setup
Finding an edid: https://www.azdanov.dev/articles/2025/how-to-create-a-virtual-display-for-sunshine-on-arch-linux
Note: don't use mkinitcpio.conf, stop following instructions

# Edit kernel parameters
https://discovery.endeavouros.com/installation/systemd-boot/2022/12/

# Rebuilding dracut to include path to edid
## Configure Dracut to Include the File
Create a new configuration file in /etc/dracut.conf.d/ to ensure the file is added to the initramfs image:
`$ echo 'install_items+=" /usr/lib/firmware/edid/edid.bin "' | sudo tee /etc/dracut.conf.d/edid.conf`

## Rebuild the initramfs
`$ sudo dracut -f`
