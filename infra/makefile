server = wesley@ssh.bovisoft.com
project_path = $(shell basename $(shell pwd))

rsync:
	rsync -azv . $(server):$(project_path)

# First run for setup docker compose and traefik
setup: rsync
	ssh $(server) "cd ~/$(project_path) &&\
	 	docker swarm init --advertise-addr $$(hostname -I | awk '{print $$1}') || true && \
    docker network create --driver overlay --attachable proxy || true && \
    docker stack deploy -c compose.yml rotary"

deploy: rsync
	ssh $(server) "cd $(project_path) &&  docker stack deploy -c compose.yml rotary --with-registry-auth --resolve-image=always"