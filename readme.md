### Installation

- If you don't have Docker, please install it: https://docs.docker.com/get-docker/

- Check if you have docker-compose on your machine

``` shell
docker-compose --version
```

- If you have Docker Desktop, you don't need to do anything. Otherwise, please follow this instruction to install: https://docs.docker.com/compose/install/

### Run

- To run this project, run following commands:

``` shell

git clone https://github.com/quang-do-se/docker-vault-approle.git

cd docker-vault-approle

# This can take a long time for the first run
docker-compose up -d --build

```

- Confirm that you have 3 containers running in your local:

``` shell
docker ps
```
- If you don't see 3 containers running, there may be something wrong. Try:

``` shell
docker-compose logs
```

- Set up SSH connection betwen `orchestrator` and `app` containers

``` shell
./setup-ssh-authentication.sh
```

### Instructions for demo

- Open separated 3 terminals so that we can see 3 containers at the same time and type:

``` shell
hostname
```

- You should see 3 different names since we're in 3 different containers

- Verify we can SSH into `app` container from `orchestrator` container

``` shell
# In `orchestrator` container
ssh app@app
```

- Type `hostname` in `orchestrator` container, now you should see the hostname changes to `app`'s hostname

### Stop

``` shell
docker-compose down -v
```

### References

- https://www.hashicorp.com/blog/authenticating-applications-with-vault-approle
- https://learn.hashicorp.com/tutorials/vault/approle
- https://www.vaultproject.io/docs/auth/approle
