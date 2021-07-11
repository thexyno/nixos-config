# ds9

homeserver

- Ryzen 5 2600
- 32Gb Ram
- Storage
  - 4x8 TB WD Elements

# Installation

```
$ zpool create -f -O mountpoint=none -o ashift=12 rpool raidz sdj sdk sdl sdm # create the pool
$ zfs create -o encryption=on -o mountpoint=none -o keyformat=passphrase rpool/content # encrypted root
$ zfs create -o mountpoint=none rpool/content/local # non important files
$ zfs create -o mountpoint=legacy rpool/content/local/nix # /nix
$ zfs create -o mountpoint=legacy -o acltype=posixacl -o xattr=sa rpool/content/local/journal # journald
$ zfs create -o mountpoint=legacy -o compression=zstd rpool/content/local/backups # backups for other machines
$ zfs create -o mountpoint=none rpool/content/safe # important files
$ zfs create -o mountpoint=none rpool/content/safe/vms # zvols for vms
$ zfs create -o mountpoint=legacy rpool/content/safe/persist # /persistent for ds9
$ zfs create -o mountpoint=legacy -o compression=zstd-fast rpool/content/safe/data # all sorts of data
$ zfs create -o mountpoint=legacy -o compression=off rpool/content/safe/data/media # Movies,Music,...
$ zfs list 
rpool                          4.29M  21.0T      140K  none
rpool/content                  2.50M  21.0T      256K  none
rpool/content/local            1023K  21.0T      256K  none
rpool/content/local/backups     256K  21.0T      256K  legacy
rpool/content/local/journal     256K  21.0T      256K  legacy
rpool/content/local/nix         256K  21.0T      256K  legacy
rpool/content/safe             1.25M  21.0T      256K  none
rpool/content/safe/data         512K  21.0T      256K  legacy
rpool/content/safe/data/media   256K  21.0T      256K  legacy
rpool/content/safe/persist      256K  21.0T      256K  legacy
rpool/content/safe/vms          256K  21.0T      256K  none
```
