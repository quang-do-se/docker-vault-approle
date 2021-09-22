### Installation

- If you don't have Docker, please install it: https://docs.docker.com/get-docker/

- Check if you have docker-compose on your machine

``` shell
docker-compose --version
```

- If you have Docker Desktop, you don't need to do anything. Otherwise, please follow this instruction to install: https://docs.docker.com/compose/install/

### Run

``` shell

git clone https://github.com/quang-do-se/docker-vault-approle.git

cd docker-vault-approle

docker-compose up -d --build

./run.sh

```

### Stop

``` shell

docker-compose down -v

```

### References

- https://www.hashicorp.com/blog/authenticating-applications-with-vault-approle
- https://learn.hashicorp.com/tutorials/vault/approle
- https://www.vaultproject.io/docs/auth/approle
