# cloud-tools
Tools to make clouds

# Setup docker swarm

Start new nodes on the CERN cloud by running:
```
./create_instances.sh 1 2 3
```
which will start three machines called `thead-everware1`,
`thead-everware2`, and `thead-everware3`.

Once ready get each host setup with:
```
ssh root@thead-everware12 "bash -s" < configure-workers.sh
```

On any computer with the swarm image run `docker run --rm swarm create`,
make a note of the returned `<cluster_id>`.

On all machines edit `/etc/sysconfig/docker` and set `OPTIONS="-H 0.0.0.0:2375"`, then
restart the docker daemon: `service docker restart`

On a machine you want to be a swarm node run:
```
docker run -d swarm join --addr=`hostname`:2375 token://<cluster_id>
```
A machine can be simultaneously the manager and a swarm node.

On the host you want to be the swarm manager:
```
docker run -d -p 127.0.0.1:2376:2375 swarm manage token://<cluster_id>
```
Now set `DOCKER_HOST=127.0.0.1:2376` and run `docker info`. You
should see your newly made docker swarm.


# Docker swarm with TLS

Setup with TLS, this is required, otherwise anyone can send commands
to the docker daemon!

To generate certificates follow the [https instructions](https://docs.docker.com/v1.5/articles/https/) in the docker documentation.
They are not particularly clear, and some of the input files already exist
in this repo, so take care not to blindly overwrite them.

Copy all the certificates and keys to all the machines.

On all nodes modify `/etc/sysconfig/docker`:
```
OPTIONS='--selinux-enabled --tlsverify --tlscacert=/root/ca.pem --tlscert=/root/server-cert.pem --tlskey=/root/server-key.pem -H tcp://0.0.0.0:2375'
```
restart the docker daemon with `service docker restart`.

On each swarm node:
```
DOCKER_HOST=`hostname`:2375 docker --tlsverify --tlscacert=/root/ca.pem --tlscert=/root/cert.pem --tlskey=/root/key.pem run -d swarm join --addr=`hostname`:2375 token://...
```

Copy all the certificates into `/root/certs` so we can mount it inside the `swarm manage` image. On the machine that should be the swarm master:
```
DOCKER_HOST=thead-everware10.cern.ch:2375 docker --tlsverify --tlscacert=/root/ca.pem --tlscert=/root/cert.pem --tlskey=/root/key.pem run -v /root/certs:/certs -p 2537:2375 -d swarm manage --tls --tlscert=/certs/cert.pem --tlskey=/certs/key.pem token://...
```

Check that the swarm is working:
```
DOCKER_HOST=thead-everware10.cern.ch:2537 docker --tls --tlscacert=/root/ca.pem --tlscert=/root/cert.pem --tlskey=/root/key.pem info
```
