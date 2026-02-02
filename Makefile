.PHONY: help setup start stop restart logs clean test generate-data etl ml dashboard

# Variables
PYTHON := python
PIP := pip
DOCKER_COMPOSE := docker-compose

# Couleurs pour les messages
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Afficher l'aide
	@echo "$(BLUE)B2B Mobile Money DWH - Commandes Disponibles$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

setup: ## Installation initiale du projet
	@echo "$(BLUE)Installation de l'environnement...$(NC)"
	python -m venv venv
	. venv/bin/activate && $(PIP) install --upgrade pip
	. venv/bin/activate && $(PIP) install -r requirements.txt
	@echo "$(GREEN)✓ Installation terminée$(NC)"

start: ## Démarrer l'infrastructure Docker
	@echo "$(BLUE)Démarrage de l'infrastructure Docker...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✓ Infrastructure démarrée$(NC)"
	@echo ""
	@echo "Services disponibles:"
	@echo "  - PostgreSQL DWH : localhost:5432"
	@echo "  - PgAdmin        : http://localhost:5050"
	@echo "  - Jupyter        : http://localhost:8888"
	@echo "  - Metabase       : http://localhost:3000"

stop: ## Arrêter l'infrastructure Docker
	@echo "$(BLUE)Arrêt de l'infrastructure...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✓ Infrastructure arrêtée$(NC)"

restart: ## Redémarrer l'infrastructure
	@$(MAKE) stop
	@$(MAKE) start

logs: ## Afficher les logs Docker
	$(DOCKER_COMPOSE) logs -f

status: ## Vérifier le statut des services
	@echo "$(BLUE)Statut des services Docker:$(NC)"
	$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "$(BLUE)Test de connexion PostgreSQL:$(NC)"
	@docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "SELECT 'Connexion réussie!' as status;"

db-shell: ## Ouvrir un shell PostgreSQL
	docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh

db-info: ## Afficher les informations sur les tables DWH
	@echo "$(BLUE)Tables du DWH:$(NC)"
	@docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "\dt dwh.*"
	@echo ""
	@echo "$(BLUE)Nombre de lignes:$(NC)"
	@docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "SELECT schemaname, tablename, n_tup_ins FROM pg_stat_user_tables WHERE schemaname = 'dwh';"

generate-data: ## Générer les données synthétiques
	@echo "$(BLUE)Génération des données...$(NC)"
	. venv/bin/activate && $(PYTHON) src/data_generation/generate_all.py
	@echo "$(GREEN)✓ Données générées$(NC)"

etl: ## Exécuter le pipeline ETL
	@echo "$(BLUE)Exécution du pipeline ETL...$(NC)"
	. venv/bin/activate && $(PYTHON) src/etl/run_etl.py
	@echo "$(GREEN)✓ ETL terminé$(NC)"

ml-fraud: ## Entraîner le modèle de détection de fraude
	@echo "$(BLUE)Entraînement du modèle de fraude...$(NC)"
	. venv/bin/activate && $(PYTHON) src/ml/fraud_detection.py --train
	@echo "$(GREEN)✓ Modèle entraîné$(NC)"

ml-segment: ## Effectuer la segmentation RFM
	@echo "$(BLUE)Segmentation des clients...$(NC)"
	. venv/bin/activate && $(PYTHON) src/ml/segmentation.py
	@echo "$(GREEN)✓ Segmentation terminée$(NC)"

notebook: ## Lancer Jupyter Notebook
	@echo "$(BLUE)Lancement de Jupyter...$(NC)"
	. venv/bin/activate && jupyter notebook notebooks/

test: ## Exécuter les tests
	@echo "$(BLUE)Exécution des tests...$(NC)"
	. venv/bin/activate && pytest tests/ -v --cov=src
	@echo "$(GREEN)✓ Tests terminés$(NC)"

clean-data: ## Supprimer les données générées
	@echo "$(RED)Suppression des données...$(NC)"
	rm -rf data/raw/*
	rm -rf data/processed/*
	@echo "$(GREEN)✓ Données supprimées$(NC)"

clean-models: ## Supprimer les modèles ML
	@echo "$(RED)Suppression des modèles...$(NC)"
	rm -rf models/*.pkl
	rm -rf models/*.joblib
	@echo "$(GREEN)✓ Modèles supprimés$(NC)"

clean: clean-data clean-models ## Nettoyer tous les fichiers générés
	@echo "$(RED)Nettoyage complet...$(NC)"
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

reset-db: ## Réinitialiser complètement la base de données
	@echo "$(RED)⚠ Attention: Ceci va supprimer toutes les données!$(NC)"
	@read -p "Êtes-vous sûr? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		$(DOCKER_COMPOSE) up -d postgres-dwh; \
		echo "$(GREEN)✓ Base de données réinitialisée$(NC)"; \
	fi

backup-db: ## Créer une sauvegarde de la base
	@echo "$(BLUE)Création d'une sauvegarde...$(NC)"
	@mkdir -p backups
	docker exec b2b_dwh pg_dump -U dwh_admin b2b_mobile_money_dwh > backups/dwh_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Sauvegarde créée dans backups/$(NC)"

restore-db: ## Restaurer une sauvegarde (usage: make restore-db BACKUP=backups/file.sql)
	@echo "$(BLUE)Restauration de la sauvegarde...$(NC)"
	docker exec -i b2b_dwh psql -U dwh_admin b2b_mobile_money_dwh < $(BACKUP)
	@echo "$(GREEN)✓ Sauvegarde restaurée$(NC)"

install-dev: ## Installer les outils de développement
	. venv/bin/activate && $(PIP) install black flake8 mypy pytest-cov
	@echo "$(GREEN)✓ Outils de développement installés$(NC)"

format: ## Formatter le code Python
	. venv/bin/activate && black src/ tests/
	@echo "$(GREEN)✓ Code formaté$(NC)"

lint: ## Vérifier la qualité du code
	. venv/bin/activate && flake8 src/ tests/
	@echo "$(GREEN)✓ Vérification terminée$(NC)"

full-pipeline: generate-data etl ml-fraud ml-segment ## Exécuter le pipeline complet
	@echo "$(GREEN)✓ Pipeline complet terminé!$(NC)"

demo: start generate-data etl ## Démo rapide du projet
	@echo "$(GREEN)✓ Démo terminée! Consultez les dashboards.$(NC)"
