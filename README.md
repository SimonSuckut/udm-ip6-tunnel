# ip6_tunnel module for Unifi Dream Machine
The build-scripts in this repository are based on [udm-kernel-tools](https://github.com/fabianishere/udm-kernel-tools)

## Building
I recommend building this repository in a debian bullseye docker container to match the compiler and build environment version as close as possible to the dream machine. Accoring to /proc/version the kurrent udm kernel (Firmware version 3.0.20) was build with gcc version 10.2.1 20210110 (Debian 10.2.1-6)
```
debuild -uc -us -aarm64 --lintian-opts --profile debian
```

## Use-cases
This kernel module is required for setting up an ipip6 tunnel on the UDM. This is required for e.g. a DS-Lite connection which is a common connection type for many ISPs in Germany.

## License
The code is released under the GPLv2 license. See [COPYING.txt](/COPYING.txt).
