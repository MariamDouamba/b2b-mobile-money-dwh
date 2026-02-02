# 🚀 Guide de Démarrage Rapide

## Mise en route en 5 minutes

### Étape 1: Cloner et Configurer
```bash
# Cloner le projet
git clone <repository-url>
cd b2b-mobile-money-dwh

# Créer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r requirements.txt
```

### Étape 2: Démarrer l'Infrastructure
```bash
# Lancer Docker Compose
docker-compose up -d

# Vérifier que tout fonctionne
docker-compose ps

# Vous devriez voir:
# - b2b_dwh (PostgreSQL) - UP
# - b2b_pgadmin (PgAdmin) - UP
# - b2b_jupyter (Jupyter) - UP
# - b2b_metabase (Metabase) - UP
```

### Étape 3: Vérifier la Base de Données
```bash
# Test de connexion
docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "SELECT 'OK' as status;"

# Voir les tables créées
docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "\dt dwh.*"
```

### Étape 4: Générer les Données (optionnel pour démarrage rapide)
```bash
# Activer l'environnement virtuel si ce n'est pas déjà fait
source venv/bin/activate

# Générer un petit échantillon de données pour tester
python src/data_generation/generate_sample.py
```

### Étape 5: Accéder aux Outils

#### PgAdmin (Interface Web PostgreSQL)
- URL: http://localhost:5050
- Email: admin@b2b-dwh.com
- Password: admin_password

**Configuration de la connexion dans PgAdmin:**
1. Clic droit sur "Servers" → "Create" → "Server"
2. Onglet "General": Name = "B2B DWH"
3. Onglet "Connection":
   - Host: postgres-dwh
   - Port: 5432
   - Database: b2b_mobile_money_dwh
   - Username: dwh_admin
   - Password: dwh_secure_password

#### Jupyter Notebooks
- URL: http://localhost:8888
- Token: (pas de token requis)

#### Metabase (Visualisation)
- URL: http://localhost:3000
- Premier démarrage: Configuration initiale requise

#### DBeaver (Alternative Desktop)
- Host: localhost
- Port: 5432
- Database: b2b_mobile_money_dwh
- Username: dwh_admin
- Password: dwh_secure_password

---

## 📚 Prochaines Étapes

### Pour un projet complet:

1. **Générer les données complètes**
   ```bash
   python src/data_generation/generate_all.py
   # Cela va créer 3M clients et 2 ans de transactions
   ```

2. **Exécuter le pipeline ETL**
   ```bash
   python src/etl/run_etl.py
   ```

3. **Entraîner les modèles ML**
   ```bash
   # Détection de fraude
   python src/ml/fraud_detection.py --train
   
   # Segmentation clients
   python src/ml/segmentation.py
   ```

4. **Explorer avec Jupyter**
   - Ouvrir http://localhost:8888
   - Naviguer vers `notebooks/`
   - Commencer avec `01_exploration.ipynb`

5. **Créer les dashboards Power BI**
   - Ouvrir Power BI Desktop
   - Obtenir les données → PostgreSQL
   - Connecter à localhost:5432
   - Importer les vues: `dwh.v_kpi_overview`, `dwh.v_rfm_segmentation`

---

## 🛠️ Commandes Utiles (avec Makefile)

Si vous avez `make` installé:

```bash
# Voir toutes les commandes disponibles
make help

# Démarrer l'infrastructure
make start

# Arrêter l'infrastructure
make stop

# Voir les logs
make logs

# Générer les données
make generate-data

# Exécuter l'ETL
make etl

# Pipeline complet
make full-pipeline

# Nettoyer les données
make clean
```

---

## 🐛 Dépannage

### Docker ne démarre pas
```bash
# Vérifier que Docker est installé et en cours d'exécution
docker --version
docker-compose --version

# Arrêter et nettoyer
docker-compose down
docker system prune

# Redémarrer
docker-compose up -d
```

### Connexion PostgreSQL échoue
```bash
# Vérifier que le conteneur fonctionne
docker ps | grep b2b_dwh

# Voir les logs PostgreSQL
docker logs b2b_dwh

# Redémarrer PostgreSQL
docker-compose restart postgres-dwh
```

### Port déjà utilisé (ex: 5432)
```bash
# Modifier le port dans docker-compose.yml
# Changer "5432:5432" en "5433:5432"
# Puis redémarrer
docker-compose down
docker-compose up -d
```

### Problèmes de permissions
```bash
# Donner les permissions sur les dossiers data
chmod -R 755 data/
```

---

## 📞 Besoin d'Aide?

- **Documentation complète**: Voir [README.md](../README.md)
- **Architecture**: Voir [docs/architecture.md](architecture.md)
- **Dictionnaire de données**: Voir [docs/data_dictionary.md](data_dictionary.md)
- **Issues GitHub**: Ouvrir une issue sur le repository

---

## ✅ Checklist de Vérification

Avant de commencer à travailler, assurez-vous que:

- [ ] Docker et Docker Compose sont installés
- [ ] Python 3.11+ est installé
- [ ] Tous les conteneurs Docker sont UP
- [ ] La connexion à PostgreSQL fonctionne
- [ ] PgAdmin est accessible
- [ ] L'environnement virtuel Python est activé
- [ ] Les dépendances Python sont installées

Une fois tout vérifié, vous êtes prêt à utiliser le projet! 🎉
