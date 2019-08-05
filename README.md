
Reverse SSH Tunnel
------------------

Suppose you have a machine (like a Raspberry Pi) that lives behind a home router or on another inaccessible network.
Or, maybe this machine occasionally changes it's IP address.
This repo will set up a tunnel from the machine (called the `local` machine) to another machine (called `remote`) that has a reliable internet-connectible address.
You will be able to reliably connect to `local` by first connecting to `remote` and then jumping from `remote` to `local` via the configured `remote_port`.

## Remote setup ##

Make sure the `remote` machine is reliably online.
I use a server with a static IP address, but you can also use a dynamic DNS name.

Create a `remote_user` for the tunnel; here, I use `pitunnel`.
Replace `<ssh_key>` with the SSH key you create in the [Local setup](#local-setup) section. 

```bash
$ sudo useradd -m pitunnel
$ sudo su - pitunnel
$ mkdir ~/.ssh
$ echo <ssh_key> > authorized_keys
$ exit
```

You should also configure the SSH service to time out stale connections.
Edit `/etc/ssh/sshd_config` and make add a section like so:

```
# disconnect idle clients after a minute
ClientAliveInterval 20s
ClientAliveCountMax 3
```

This will cause the SSH server to ping connected clients every 20 seconds, and disconnect if 3 pings fail.
Make sure your `sshd_config` is still valid by running:

```bash
$ sshd -t && echo 'looks good' || echo 'sshd config is invalid'
```

If it outputs `looks good` then you can go ahead and restart `sshd`:

```bash
$ sudo systemctl reload sshd
```

## Local setup ##

First, install `autossh`:

```bash
$ sudo apt-get install -y autossh
```

Next, create an SSH key for your tunnel.
Don't specify a password.

```bash
$ ssh-keygen -t ed25519
$ cat ~/.ssh/id_ed25519.pub
<ssh_key>
```

Copy the output (`<ssh_key>`) and paste it into the `/home/<remote_user>/.ssh/authorized_keys` file on `remote`.

Next, clone this repo and edit `tunnel.sh`.
You will need to customize these variables:
* `remote_host` -- the hostname or IP of the `remote` server
* `remote_port` -- the port on the `remote` server where `local` will be available
* `remote_user` -- the user you created in the [remote setup](#remote-setup) section

If you're not running on a Raspberry Pi, you should also edit `tunnel.service` and customize this line:

```
User=pi
```

Replace `pi` with the local username (output of `whoami`).

Once configured, you can run `install.sh`:

```bash
$ sudo ./install.sh
```

This will begin running the SSH tunnel.

## Usage ##

To connect to the `local` machine, first connect to `remote`.
Then, on `remote`, run:

```bash
$ ssh pi@localhost -p <remote_port>
```

Replace `pi` with your `local` username (whatever you put as `User=` in [local setup](#local-setup).

## Troubleshooting ##

So long as `local` can communicate with `remote`, the tunnel will be re-created if it does for any reason.
It might take a minute or two for existing connections to time out, so keep trying if it doesn't work at first.

To check on the status of the tunnel, you can run:

```bash
$ systemctl status tunnel
```
