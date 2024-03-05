
ifneq ($(shell which docker-compose 2>/dev/null),)
    DOCKER_COMPOSE := docker-compose
else
    DOCKER_COMPOSE := docker compose
endif

install:
	$(DOCKER_COMPOSE) up -d

remove:
	@chmod +x confirm_remove.sh
	@./confirm_remove.sh

start:
	$(DOCKER_COMPOSE) start
startAndBuild: 
	$(DOCKER_COMPOSE) up -d --build

stop:
	$(DOCKER_COMPOSE) stop

update:
	# Calls the LLM update script
	chmod +x update_ollama_models.sh
	@./update_ollama_models.sh
	@git pull
	$(DOCKER_COMPOSE) down
	# Make sure the ollama-webui container is stopped before rebuilding
	@docker stop open-webui || true
	$(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) start

run-cpu:
	bash run-compose.sh --enable-api[port=11434] --webui[port=3000]

# start ollama only
run:
	bash run-compose.sh --enable-gpu[count=1] --enable-api[port=11434]

# start ollama with webui
run-gui:
	bash run-compose.sh --enable-gpu[count=1] --enable-api[port=11434] --webui[port=3000]

.PHONY: stop-ollama
stop-ollama:
	docker compose -f docker-compose.yaml down

.PHONY: stop-ollama-gui
stop-ollama-gui:
	docker compose -f docker-compose.gui.yaml down

.PHONY: stop
stop: stop-ollama stop-ollama-gui
