#!/bin/bash

# Will create a 1+ node swarm on your virtualbox or whatever driver you are using.
create_swarm_worker() {

    docker-machine create swarm$i

    docker-machine ssh swarm$i -- \
        docker swarm join --token $1 $2
}

create_swarm() {

    echo "Creating Swarm Manager"
    docker-machine create manager0

    docker-machine ssh manager0 -- \
        docker swarm init --advertise-addr $(docker-machine ip manager0)

    JOIN_TOKEN=$(docker-machine ssh manager0 -- docker swarm join-token worker -q)
    ADDR=$(docker-machine ip manager0):2377

    for ((i=1; i<=$1-1; i++))
        do
            echo "Spawning swarm worker creation $i"
            create_swarm_worker $JOIN_TOKEN $ADDR &
        done
    echo "Finished spawning worker creation"
    FAIL=0

    for job in `jobs -p`
        do
            wait $job || let "FAIL+=1"
        done
    if [ $FAIL == 0 ];
    then
        echo "Completed"
    else
        echo "A failure occured while spawning workers, removing created machines"
        re='^worker[1-9]$|^manager[0-9]$'
        for machine in `docker-machine ls -q`
        do
            if [$machine ~= re];
            then
                docker-machine rm $machine -f
            fi
        done
    fi
}

remove_swarm() {

    re="^manager[0-9]$|^swarm[1-9]$"
    for machine in `docker-machine ls -q`
    do
        if [[ $machine =~ $re ]];
        then
            docker-machine rm $machine -f
        fi
    done

    docker swarm leave -f
}

#Add own docker daemon as a manager!
add_self() {

    TOKEN=$(docker-machine ssh manager0 -- docker swarm join-token manager -q)
    ADDR=$(docker-machine ip manager0):2377
    docker swarm join --token $TOKEN $ADDR
}

re="^[1-9]$"
if [[ $1 == "create" ]];
then
    if ! [[ $2 =~ $re ]] ; then
        echo "error: Not a number or not betwen 1-9 inclusively" >&2; exit 1
    else
        create_swarm $2
    fi
elif [[ $1 == "rm" ]];
then
    remove_swarm
elif [[ $1 == "join" ]];
then
    add_self
else
    echo "Couldn't recognize command  -- $1"
fi