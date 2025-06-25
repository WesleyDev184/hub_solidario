server = wesley@ssh.bovisoft.com
project_path = $(shell basename $(shell pwd))

rsync:
	rsync -azv . $(server):$(project_path)

# First run for setup docker compose and traefik
setup: rsync
	ssh $(server) "cd ~/$(project_path) &&\
	 	docker network create proxy &&\
		docker compose up -d"

deploy: rsync
	ssh $(server) "cd $(project_path) && docker compose down && docker compose up -d"