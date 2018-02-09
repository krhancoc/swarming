# Useful commands

```
docker-machine create --driver google \
  --google-project $PROJECT_ID \
  --google-zone us-west1-a \
  --google-machine-type f1-micro \
  --google-tags docker-swarm \
  vm0


```