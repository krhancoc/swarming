# For the Swarm!
Author: Kenneth R Hancock

## Purpose
<p>
This project is to aggregate the knowledge I come across while exploring Docker Swarm.  I have been enjoying using Swarm as it has some advantages over Kubernetes which is the industry flagship currently for Orchestration services.  The major advantage is its easy to pick up and start trying out.  It's easily understandable, which is pretty huge. Kubernetes on the other hand is notoriously hard to dive into and its learning curve is more of a wall then a curve.
</p>

<p>
That being said -  I found Docker's documentation on starting up rather disorganized and incoherent.  Although they talk about using swarm within production, it currently talks about using docker swarm within the Docker standalone mode which is a container runned service rather than what was introduced in version 1.12.
</p>

## Start up
To start up a swarm use the command:
```
./run.sh create 3`
```
This will create a basic swarm with 1 manager and 2 workers.  Workers are systems that can only be as well... workers.  They do not particpate in the Elective processes or belong to the "Quorum". I would highly suggest those to look at the [Raft Algorithm](https://raft.github.io/) which runs the Docker swarm.  Its quite an easy read and the Algorithm itself was designed for understandability.

## Discovery Services -- A Development Swarm.
I have been experimenting with the discovery services offered by the new internal swarm for a bit now and found it quite amazing and easy to use. Find information [here](https://docs.docker.com/docker-cloud/apps/service-links/#using-service-links-for-service-discovery).  

But in terms of a dev environment one could possibly start a swarm of VM's in the cloud or wherever you'd like ([using docker-machine and your cloud provider as a driver](https://docs.docker.com/machine/reference/create/#accessing-driver-specific-flags-in-the-help-text)).  They could then add their own developer machine to this swarm as a worker, then can use things like basic compose files deploy your in development applications into the network of the swarm but only on your machine.  Why? Service Discovery!  By plugging into the service discovery of the swarm you can immediatly have access to the other services within the swarm without having to deploy or set them up yourself.

### Notes for this idea
#### Docker for Mac/Windows
Mac and Windows currently wrap their docker daemon in an unreachable ip, so if you have some swarm deployed on the swarm you will not be able to attach your machine to it.  A currently work around is using docker-machine just create a "default" machine and using `eval $(docker-machine env default)` you can use this machine as your home base for all things docker.  You can then add this machine to your swarm as a worker.  I stress a worker -- although not confirmed just yet, but if you add it as a Manager, then you will add to the number of units that are required for the election process in Swarms internal consensus algorithm.  Meaning, if you shut off your computer, you may put the swarm into a state of being out of service as by shutting of your computer you could reduce the number of managers to less then half, this would cause the swarm not able to elect leaders. 

#### Networking - [Info](https://docs.docker.com/compose/networking/)
Docker swarm relies on its overlay network for service discovery, and for the machines to talk to each other.  The problem that I ran across is that workers do not have access networks that don't specifically effect them.  Meaning, that a worker does not know of any network in the swarm until a service has been deployed that specifically uses them as a node to host a container. [See Issue Here](https://github.com/moby/moby/issues/25456#issuecomment-238083965)



#### Labels are important!
To make sure that this common stack of services that you are deploying to the swarm doesnt start deploying containers on your dev's machines, make sure to label your machines or nodes with some label and use docker swarm's constraints to make sure that services are only deployed on nodes with this label!  I used common for example within run.sh:

```
add_labels() {

    re="^manager[0-9]$|^swarm[1-9]$"
    eval $(docker-machine env manager0)
    for machine in `docker-machine ls -q`
    do
        if [[ $machine =~ $re ]];
        then
            docker node update --label-add  machine=common $machine
        fi
    done
}
```
# Useful commands

nc -zv IP PORT # Checks to make sure ports are open -- useful when working with multiple clouds.

```
## Note
Its very important that you use the addvertise addr flag and set it to the external IP's of the VM for BOTH JOIN AND INIT. When doing multi cloud swarming.