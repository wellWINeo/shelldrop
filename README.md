# ShellDrop

Simple shell script to drop files using just netcat
and http. So you can download file from client just
with any http client.

## Install
By default installs to `~/.local.bin`, you can change it
in `Makefile`.

```shell
$ make install
```

## Usage

```shell
$ shelldrop image.png
```

## Configuration
Script reads `/etc/shelldrop/config` and `~/.config/shelldrop/config`.
Example config:

```shell
PORTS_RANGE_START=8100
PORTS_RANGE_END=8200
USE_FILENAME_URL=1
USE_QR=1
```

Script randomly choose port to use for drop. Make sure to open ports
in range.

## Dependencies

- nc (netcat, i tested with openbsd's nc)
- qrencode (to generate qr for download)
