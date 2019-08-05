#!/bin/bash

remote_host="moomers.org"
remote_user="pitunnel"
remote_port=2222

# some helpful debug info
echo "Connecting to '${remote_host}' as user '${remote_user}'..."
echo "Tunnel will be created on '${remote_host}'s port '${remote_port}'"

# actually run autossh
autossh -M 0 -o ServerAliveInterval=20 -o "ExitOnForwardFailure=yes" -nNT -R ${remote_port}:localhost:22 ${remote_user}@${remote_host}

