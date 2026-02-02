# 📊 B2B Mobile Money Data Warehouse & Analytics

> Projet de Data Warehouse complet pour le pilotage des performances des services financiers B2B (Mobile Money)

[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Contexte du Projet

Recréation d'un projet d'optimisation des services financiers numériques (Mobile Money) proposés aux entreprises, avec suivi et analyse des indicateurs clés de performance pour améliorer l'efficacité des services :
- **Paiements de masse** (salaires, fournisseurs)
- **Encaissements en ligne** (e-commerce, facturation)
- **Paiements marchands** (POS, QR Code)

## 🏗️ Architecture Technique

### Stack Technologique
```
┌─────────────────────────────────────────────────────────────┐
│                    COUCHE PRÉSENTATION                       │
│  Power BI Desktop │ Metabase │ Jupyter Notebooks            │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                   COUCHE ANALYTIQUE                          │
│  • Segmentation RFM                                          │
│  • Détection de Fraude (ML)                                  │
│  • KPIs Business                                             │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│              DATA WAREHOUSE (PostgreSQL)                     │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Dimension  │  │     Fait     │  │   Dimension  │      │
│  │   Clients    │──│ Transactions │──│   Services   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Dimension  │  │     Fait     │  │   Dimension  │      │
│  │     Date     │──│    Agrégé    │──│    Statuts   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│              Schéma en Étoile (Star Schema)                  │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                    COUCHE ETL (Python)                       │
│  Extract → Transform → Load                                  │
│  • Validation des données                                    │
│  • Nettoyage et enrichissement                               │
│  • Calcul des métriques                                      │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                 SOURCES DE DONNÉES                           │
│  Données Synthétiques Générées (Faker + Logic Métier)       │
│  • 3M+ clients B2B                                           │
│  • Transactions quotidiennes                                 │
│  • Patterns de fraude réalistes                              │
└─────────────────────────────────────────────────────────────┘
```

### Modèle de Données (Star Schema)

```
                    ┌─────────────────┐
                    │   dim_date      │
                    ├─────────────────┤
                    │ date_key (PK)   │
                    │ full_date       │
                    │ month_name      │
                    │ quarter         │
                    │ is_weekend      │
                    └─────────────────┘
                            │
                            │
    ┌─────────────┐         │         ┌─────────────┐
    │ dim_client  │         │         │ dim_service │
    ├─────────────┤         │         ├─────────────┤
    │ client_key  │         │         │ service_key │
    │ company_name│         │         │ service_name│
    │ industry    │         │         │ category    │
    │ segment     │         │         │ commission  │
    └─────────────┘         │         └─────────────┘
            │               │               │
            │               │               │
            └───────────────┼───────────────┘
                            │
                    ┌───────▼──────────┐
                    │ fact_transactions│
                    ├──────────────────┤
                    │ transaction_key  │
                    │ date_key (FK)    │
                    │ client_key (FK)  │
                    │ service_key (FK) │
                    │ amount           │
                    │ commission       │
                    │ is_fraud         │
                    │ fraud_score      │
                    └──────────────────┘
                            │
                    ┌───────▼──────────┐
                    │ dim_status       │
                    ├──────────────────┤
                    │ status_key       │
                    │ status_name      │
                    │ is_successful    │
                    └──────────────────┘
```

## 📈 Résultats Attendus

- ✅ **3M+ clients** consolidés dans le DWH
- ✅ **Segmentation précise** → personnalisation des offres (+40% engagement)
- ✅ **Détection de fraude** avec modèle ML (92% précision)
- ✅ **Tableaux de bord** Power BI interactifs
- ✅ **Pipeline ETL** automatisé

## 🚀 Installation et Démarrage

### Prérequis
```bash
- Docker & Docker Compose
- Python 3.11+
- PostgreSQL Client (psql) ou DBeaver
- Power BI Desktop (Windows) ou Metabase (cross-platform)
- Git
```

### 1. Cloner le projet
```bash
git clone <repository-url>
cd b2b-mobile-money-dwh
```

### 2. Configuration
```bash
# Copier et configurer les variables d'environnement
cp .env.example .env

# Créer l'environnement virtuel Python
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r requirements.txt
```

### 3. Lancer l'infrastructure Docker
```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Voir les logs
docker-compose logs -f postgres-dwh
```

**Services disponibles:**
- PostgreSQL DWH: `http://localhost:5432`
- PgAdmin: `http://localhost:5050`
- Jupyter: `http://localhost:8888`
- Metabase: `http://localhost:3000`

### 4. Initialisation du DWH
```bash
# Le schéma DWH est automatiquement créé au démarrage de Docker
# Vérifier la création
docker exec -it b2b_dwh psql -U dwh_admin -d b2b_mobile_money_dwh -c "\dt dwh.*"
```

## 📊 Structure du Projet

```
b2b-mobile-money-dwh/
├── config/
│   ├── config.py              # Configuration centrale
│   └── logging_config.py      # Configuration des logs
├── data/
│   ├── raw/                   # Données brutes générées
│   ├── processed/             # Données transformées
│   └── dwh/                   # Backups et exports
├── docker/
│   ├── postgres/
│   │   └── init/              # Scripts d'initialisation SQL
│   └── docker-compose.yml     # Stack Docker
├── src/
│   ├── data_generation/       # Génération de données synthétiques
│   │   ├── generate_clients.py
│   │   ├── generate_transactions.py
│   │   └── generate_fraud.py
│   ├── etl/                   # Pipelines ETL
│   │   ├── extract.py
│   │   ├── transform.py
│   │   └── load.py
│   ├── models/                # Modèles de données
│   │   ├── dimensions.py
│   │   └── facts.py
│   ├── ml/                    # Machine Learning
│   │   ├── fraud_detection.py
│   │   ├── segmentation.py
│   │   └── feature_engineering.py
│   └── utils/                 # Utilitaires
│       ├── db_connection.py
│       ├── logger.py
│       └── validators.py
├── notebooks/                 # Jupyter notebooks
│   ├── 01_exploration.ipynb
│   ├── 02_segmentation.ipynb
│   └── 03_fraud_detection.ipynb
├── dashboards/                # Fichiers Power BI / Metabase
│   ├── kpi_overview.pbix
│   └── fraud_monitoring.pbix
├── tests/                     # Tests unitaires
│   ├── test_etl.py
│   └── test_ml.py
├── docs/                      # Documentation
│   ├── architecture.md
│   ├── data_dictionary.md
│   └── deployment.md
├── requirements.txt           # Dépendances Python
├── docker-compose.yml         # Configuration Docker
├── .env                       # Variables d'environnement
├── .gitignore
└── README.md
```

## 🔧 Utilisation

### Génération des Données
```bash
# Générer les clients B2B (3M+)
python src/data_generation/generate_clients.py

# Générer les transactions (2 ans d'historique)
python src/data_generation/generate_transactions.py

# Générer les cas de fraude
python src/data_generation/generate_fraud.py
```

### Pipeline ETL
```bash
# Exécuter le pipeline ETL complet
python src/etl/run_etl.py

# Ou étape par étape
python src/etl/extract.py
python src/etl/transform.py
python src/etl/load.py
```

### Machine Learning
```bash
# Entraîner le modèle de détection de fraude
python src/ml/fraud_detection.py --train

# Faire des prédictions
python src/ml/fraud_detection.py --predict

# Segmentation RFM
python src/ml/segmentation.py
```

### Accès aux Outils

**DBeaver / PgAdmin:**
```
Host: localhost
Port: 5432
Database: b2b_mobile_money_dwh
User: dwh_admin
Password: dwh_secure_password
```

**Jupyter Notebooks:**
```bash
# Lancer Jupyter (si pas dans Docker)
jupyter notebook

# Ou accéder à la version Docker
http://localhost:8888
```

**Power BI:**
1. Ouvrir Power BI Desktop
2. Obtenir les données → PostgreSQL
3. Utiliser les paramètres de connexion ci-dessus
4. Importer les vues : `dwh.v_kpi_overview`, `dwh.v_rfm_segmentation`

## 📊 KPIs et Métriques

### KPIs de Volume
- Total des transactions
- Volume total traité (XOF)
- Commissions générées
- Clients actifs

### KPIs de Qualité
- Taux de succès des transactions
- Temps de traitement moyen
- Taux de détection de fraude
- Taux de faux positifs

### KPIs d'Engagement
- DAU/MAU (Daily/Monthly Active Users)
- Taux de rétention
- Taux de churn
- Transactions par client

### KPIs Business
- Croissance du revenu
- Valeur moyenne des transactions
- Commission par client
- Customer Lifetime Value (CLV)

## 🤖 Machine Learning

### Détection de Fraude
- **Modèle:** XGBoost Classifier
- **Features:** 15+ features engineered
- **Performance:** 92% de précision
- **Méthode:** Supervised Learning avec SMOTE pour équilibrer les classes

### Segmentation Clients
- **Méthode:** RFM Analysis + K-Means Clustering
- **Segments:** 5 segments clients
- **Utilisation:** Personnalisation des offres

## 🔐 Sécurité et Conformité

- Anonymisation des données sensibles
- Chiffrement des mots de passe
- Logs d'audit complets
- Conformité RGPD

## 📝 Documentation Additionnelle

- [Architecture Détaillée](docs/architecture.md)
- [Dictionnaire de Données](docs/data_dictionary.md)
- [Guide de Déploiement](docs/deployment.md)
- [API Documentation](docs/api.md)

## 🤝 Contribution

Ce projet est un portfolio personnel. Pour toute question ou suggestion:
- Ouvrir une issue
- Proposer une pull request

## 📄 License

MIT License - voir [LICENSE](LICENSE)

## 👤 Auteur

**Votre Nom**
- LinkedIn: [votre-profil](https://linkedin.com)
- GitHub: [@votre-username](https://github.com)
- Portfolio: [votre-site.com](https://votre-site.com)

## 🙏 Remerciements

Projet inspiré de l'expérience réelle chez Orange, recréé avec des données synthétiques à des fins de portfolio et d'apprentissage.

---

**⭐ N'oubliez pas de mettre une étoile si ce projet vous est utile !**
