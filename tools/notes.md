
# Get some info on the LibreNMS containers

This one will print the environment variables, check the SIDECAR_DISPATCHER vars, and call validate.php as librenms.

For the dispatcher-sidecar and the main container

```sh
podman exec LibreNMS-dispatcher-sidecar sh -c 'set ; echo "SIDECAR_DISPATCHER: "$SIDECAR_DISPATCHER ; su librenms -c /opt/librenms/validate.php'

```
```sh
podman exec LibreNMS-librenms sh -c 'set ; echo "SIDECAR_DISPATCHER: "$SIDECAR_DISPATCHER ; su librenms -c /opt/librenms/validate.php'
```

# Test the poller

Give it a host that you have already added
```sh
podman exec LibreNMS-dispatcher-sidecar su librenms -c '/opt/librenms/poller.php -h 192.168.101.61'
```

# Test rrdcached access from the container

```sh
podman exec LibreNMS-librenms su librenms -c 'printf "Ping RRDCACHED:"; echo 'PING' | nc $RRDCACHED_SERVER || echo " no"'
```


```sh
podman logs -f LibreNMS-rrdcached
```
