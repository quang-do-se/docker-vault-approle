# Create containers and network

docker network create vault-network

BASEDIR=$(cd -- "$(dirname -- "$0")" && pwd - P)

docker container run -d \
       --cap-add=IPC_LOCK \
       -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
       -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
       -e 'VAULT_TOKEN=myroot' \
       -e 'VAULT_ADDR=http://127.0.0.1:8200' \
       -p 8200:8200 \
       --name vault \
       --network vault-network \
       vault


docker build -t demo/orchestrator ./orchestrator

docker container run -d \
       -e LOCAL_UID=$(id -u $USER) \
       -e LOCAL_GID=$(id -g $USER) \
       -e 'VAULT_ADDR=http://vault:8200' \
       -v ${BASEDIR}/orchestrator/files:/data/files \
       -w /home/orchestrator \
       --name orchestrator \
       --network vault-network \
       demo/orchestrator


docker build -t demo/app ./app

docker container run -d \
       -e LOCAL_UID=$(id -u $USER) \
       -e LOCAL_GID=$(id -g $USER) \
       -e 'VAULT_ADDR=http://vault:8200' \
       -p 8888:8080 \
       -w /home/app \
       --name app \
       --network vault-network \
       --mount type=tmpfs,destination=/secrets \
       demo/app



# Stop containers and remove network

# docker container stop app orchestrator vault
# docker container rm app orchestrator vault
# docker network rm vault-network
