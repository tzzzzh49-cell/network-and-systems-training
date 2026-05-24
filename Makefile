.PHONY: bootstrap check build up down logs test ansible-check diagnostic clean

bootstrap:
	./scripts/bootstrap_fedora_vm.sh

check:
	./scripts/check_reproducibility.sh

build:
	docker compose build

up:
	docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f

test:
	curl -f http://127.0.0.1:8000/health || curl -f http://127.0.0.1:8000/

ansible-check:
	ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

diagnostic:
	./scripts/diagnostic_local.sh

clean:
	docker compose down --remove-orphans
