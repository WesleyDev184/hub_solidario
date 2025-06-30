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

# Force recreate containers (useful after migrations)
redeploy: rsync
	ssh $(server) "cd $(project_path) && docker compose down && docker compose up -d --force-recreate"

# Check migration status manually
check-migrations: rsync
	ssh $(server) "cd $(project_path) && docker compose exec api dotnet ef migrations list --context ApiDbContext"

# View logs
logs:
	ssh $(server) "cd $(project_path) && docker compose logs -f api"

# Pull latest images
pull:
	ssh $(server) "cd $(project_path) && docker compose pull"