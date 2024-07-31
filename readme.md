#### ssh into the instance

```
ssh -i redis-ha-instance.pem ubuntu@<Public-Address-EC2>
sudo su
```

#### Build the Docker Image

```
sudo docker build -t redis-sentinel:v3 .
```

#### Docker Compose Up

```
docker-compose up -d
```

#### Check for the Docker Compose

```
docker-compose ps
```

- WE will get the entries like as follows

```
     Name                    Command               State                    Ports
---------------------------------------------------------------------------------------------------
redis-master      docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp,:::6379->6379/tcp
redis-sentinel1   redis-sentinel /etc/redis/ ...   Up      26379/tcp, 6379/tcp
redis-sentinel2   redis-sentinel /etc/redis/ ...   Up      26379/tcp, 6379/tcp
redis-sentinel3   redis-sentinel /etc/redis/ ...   Up      26379/tcp, 6379/tcp
redis-slave       docker-entrypoint.sh redis ...   Up      6379/tcp
redis-slave2      docker-entrypoint.sh redis ...   Up      6379/tcp
```

#### Enter into the redis-master

```
docker exec -it redis-master ash  #ash as we are using the alpine image

# Enter into Redis CLI

redis-cli

# Enter the `INFO REPLICATION` command in the Redis CLI to get the metadetails about the `master` and `slave`

INFO REPLICATION

# Check for the role here setted as `master`



```

- #### **NOTE:** We need to add the IP Address of Master to the sentinel.conf file as DNS cant be resolved using the Docker (on going issue)

#### Enter into the redis-slave

```
docker exec -it redis-slave ash

# Enter into Redis CLI

redis-cli

# Enter the `INFO REPLICATION` command in the Redis CLI to get the metadetails about the `master` and `slave`

INFO REPLICATION

# Check for the role here setted as `master`
```

#### Stop the redis-master to make the switch happen

```
docker stop redis-master
```

#### Check for the Logs in the Redis-Sentinel Instance; Check for the switch happening

```
 docker logs -f redis-sentinel1
```

#### Log into the Redis Slave container to check `role` in the meta-details

```
docker exec -it redis-slave ash
```

#### Now again we can start the `redis-master` but the initial master will not be the master now it would be ideally the `redis-slave` and the new master is the `redis-slave`

```
docker start redis-master
```

#### SOme steps we can follow to make it as follows:

```
docker-compose down

docker-compose up -d

docker-compose ps

docker inspect redis-master

# Replace the  Redis Master IP Address into the sentinel.conf => <YOUR IP>


```

- In docker-compose (Change the redis version for sentinel image from v3 to v4)

```
version: '3.8'

services:
  redis-master:
    image: redis:7.0-alpine
    container_name: redis-master
    ports:
      - "6379:6379"

  redis-slave:
    image: redis:7.0-alpine
    container_name: redis-slave
    depends_on:
      - redis-master
    command: ["redis-server", "--slaveof", "redis-master", "6379"]

  redis-slave2:
    image: redis:7.0-alpine
    container_name: redis-slave2
    depends_on:
      - redis-master
    command: ["redis-server", "--slaveof", "redis-master", "6379"]

  redis-sentinel1:
    image: redis-sentinel:v4
    container_name: redis-sentinel1
    depends_on:
      - redis-master

  redis-sentinel2:
    image: redis-sentinel:v4
    container_name: redis-sentinel2
    depends_on:
      - redis-master

  redis-sentinel3:
    image: redis-sentinel:v4
    container_name: redis-sentinel3
    depends_on:
      - redis-master
```

- Build the image using `docker build`

```
docker build -t redis-sentinel:v4 .
```

- We can up the redis-sentinel containers

```
docker-compose up -d redis-sentinel1 redis-sentinel2 redis-sentinel3
```

- Output shown as

```
redis-master is up-to-date
Recreating redis-sentinel1 ... done
Recreating redis-sentinel3 ... done
Recreating redis-sentinel2 ... done
```

- Check for all container running

```
docker-compose ps
```

- Now WE can manually check in the `redis-master` or the `redis-slave` by `exec` into the containers.

```
docker exec -it redis-master ash => redis-cli => INFO REPLICATION
```
