server = wesley@ssh.core.hubsolidario.com
project_path = $(shell basename $(shell pwd))
namespace = core

rsync:
	rsync -azv . $(server):$(project_path)

# First run for setup kubernetes namespace and resources
setup: rsync
	ssh $(server) "cd ~/$(project_path) &&\
		kubectl create namespace $(namespace) --dry-run=client -o yaml | kubectl apply -f - &&\
		kubectl apply -f k8s/ -n $(namespace)"

deploy: rsync
	ssh $(server) "cd $(project_path) && kubectl apply -f k8s/ -n $(namespace)"

# Force recreate pods (useful after migrations)
redeploy: rsync
	ssh $(server) "cd $(project_path) && kubectl rollout restart deployment -n $(namespace)"

# Check migration status manually
check-migrations: rsync
	ssh $(server) "cd $(project_path) && kubectl exec -n $(namespace) deployment/api -- dotnet ef migrations list --context ApiDbContext"

# View logs
logs:
	ssh $(server) "kubectl logs -f deployment/api -n $(namespace)"

# Restart specific deployment
restart-api:
	ssh $(server) "kubectl rollout restart deployment/api -n $(namespace)"

# Get pod status
status:
	ssh $(server) "kubectl get pods -n $(namespace)"

# Get all resources
get-all:
	ssh $(server) "kubectl get all -n $(namespace)"

# Delete all resources (cleanup)
cleanup:
	ssh $(server) "kubectl delete namespace $(namespace)"