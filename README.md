# Useful commands

```
docker-machine create --driver google \
  --google-project $PROJECT_ID \
  --google-zone us-west1-a \
  --google-machine-type f1-micro \
  --google-tags docker-swarm \
  vm0

nc -zv IP PORT # CHECKS CONNECTIONS ARE OPEN




```

## Note
Its very important that you use the addvertise addr flag and set it to the external IP's of the VM for BOTH JOIN AND INIT.