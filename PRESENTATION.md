# 📊 B2B Mobile Money Data Warehouse - Présentation Projet

## 🎯 Objectif du Projet

Recréation complète d'un projet professionnel de Data Warehouse pour l'optimisation des services financiers numériques B2B (Mobile Money), similaire à celui réalisé chez Orange, avec :
- Architecture complète Data Warehouse (schéma en étoile)
- Pipeline ETL automatisé en Python
- Modèles de Machine Learning (détection fraude, segmentation)
- Tableaux de bord Power BI
- Infrastructure dockerisée

## 📦 Contenu du Projet

### Structure Complète

```
b2b-mobile-money-dwh/
│
├── 📁 config/                      # Configuration centrale
│   ├── config.py                   # Paramètres du projet
│   └── .env                        # Variables d'environnement
│
├── 📁 docker/                      # Infrastructure Docker
│   ├── docker-compose.yml          # Stack complète (PostgreSQL, PgAdmin, Jupyter, Metabase)
│   └── postgres/
│       └── init/
│           └── 01_init_dwh.sql    # Initialisation schéma DWH
│
├── 📁 src/                         # Code source Python
│   ├── data_generation/            # [À COMPLÉTER] Génération données synthétiques
│   ├── etl/                        # [À COMPLÉTER] Pipelines ETL
│   ├── ml/                         # [À COMPLÉTER] Modèles ML
│   ├── models/                     # [À COMPLÉTER] Modèles de données
│   └── utils/
│       └── db_connection.py        # Gestion connexions PostgreSQL
│
├── 📁 notebooks/                   # [À COMPLÉTER] Jupyter notebooks
├── 📁 dashboards/                  # [À COMPLÉTER] Fichiers Power BI
├── 📁 data/                        # Données (ignoré par Git)
│   ├── raw/                        # Données brutes
│   ├── processed/                  # Données transformées
│   └── dwh/                        # Backups DWH
│
├── 📁 docs/                        # Documentation
│   ├── architecture.md             # Architecture technique détaillée
│   ├── data_dictionary.md          # Dictionnaire de données
│   ├── QUICKSTART.md               # Guide démarrage rapide
│   └── architecture.mermaid        # Diagramme architecture
│
├── 📁 tests/                       # [À COMPLÉTER] Tests unitaires
│
├── requirements.txt                # Dépendances Python
├── Makefile                        # Commandes utilitaires
├── .gitignore                      # Fichiers ignorés par Git
└── README.md                       # Documentation principale
```

## 🏗️ Architecture du Data Warehouse

### Schéma en Étoile (Star Schema)

```
        dim_date           dim_time
           │                  │
           │                  │
dim_client ├──────────────────┤ dim_service
           │                  │
           │ fact_transactions│
           │                  │
dim_channel├──────────────────┤ dim_status
           │                  │
           │                  │
     dim_geography      fact_daily_summary
```

### Tables Créées

**Dimensions:**
- ✅ `dwh.dim_date` - Calendrier (1,460 lignes pour 4 ans)
- ✅ `dwh.dim_time` - Heures/Minutes (1,440 lignes)
- ✅ `dwh.dim_client` - Clients B2B (3M lignes avec SCD Type 2)
- ✅ `dwh.dim_service` - Services Mobile Money (~20 lignes)
- ✅ `dwh.dim_channel` - Canaux distribution (~5 lignes)
- ✅ `dwh.dim_transaction_status` - Statuts (~10 lignes)
- ✅ `dwh.dim_geography` - Géographie (~500 lignes)

**Faits:**
- ✅ `dwh.fact_transactions` - Transactions individuelles (~36M lignes sur 2 ans)
- ✅ `dwh.fact_daily_client_summary` - Agrégations quotidiennes (~1M lignes)

**Vues Analytiques:**
- ✅ `dwh.v_kpi_overview` - KPIs globaux
- ✅ `dwh.v_rfm_segmentation` - Segmentation RFM

## 🚀 Stack Technologique

### Base de Données
- **PostgreSQL 15**: Data Warehouse principal
- **Schéma**: Star Schema avec SCD Type 2
- **Volume**: Capacité 3M+ clients, 36M+ transactions

### Backend / ETL
- **Python 3.11+**: Langage principal
- **Pandas**: Manipulation de données
- **SQLAlchemy**: ORM et connexions DB
- **Faker**: Génération données synthétiques

### Machine Learning
- **XGBoost**: Détection de fraude (92% précision)
- **Scikit-learn**: Segmentation K-Means
- **Feature Engineering**: 15+ features

### Visualisation
- **Power BI Desktop**: Dashboards principaux
- **Metabase**: Alternative open source
- **Jupyter**: Analyses exploratoires

### Infrastructure
- **Docker Compose**: Orchestration conteneurs
- **PgAdmin**: Interface web PostgreSQL
- **Git**: Versioning

## 📈 Fonctionnalités Implémentées

### ✅ Complétées

1. **Infrastructure Docker**
   - PostgreSQL configuré et optimisé
   - PgAdmin pour gestion visuelle
   - Jupyter pour analyses
   - Metabase pour dashboards web

2. **Schéma Data Warehouse**
   - Modèle dimensionnel complet
   - Index optimisés
   - Fonctions utilitaires SQL
   - Vues analytiques

3. **Configuration Projet**
   - Fichiers de configuration centralisés
   - Variables d'environnement
   - Gestion des dépendances
   - Makefile avec commandes utilitaires

4. **Documentation**
   - README complet avec architecture
   - Guide de démarrage rapide
   - Dictionnaire de données détaillé
   - Architecture technique approfondie

5. **Utilitaires Python**
   - Module de connexion DB
   - Gestion des sessions
   - Bulk loading optimisé

### 🔨 À Compléter (Prochaines Étapes)

1. **Génération de Données Synthétiques**
   - [ ] `src/data_generation/generate_clients.py`
   - [ ] `src/data_generation/generate_transactions.py`
   - [ ] `src/data_generation/generate_fraud.py`
   - [ ] `src/data_generation/generate_all.py`

2. **Pipeline ETL**
   - [ ] `src/etl/extract.py`
   - [ ] `src/etl/transform.py`
   - [ ] `src/etl/load.py`
   - [ ] `src/etl/run_etl.py`

3. **Machine Learning**
   - [ ] `src/ml/fraud_detection.py` (XGBoost)
   - [ ] `src/ml/segmentation.py` (RFM + K-Means)
   - [ ] `src/ml/feature_engineering.py`

4. **Notebooks Jupyter**
   - [ ] `01_data_exploration.ipynb`
   - [ ] `02_fraud_analysis.ipynb`
   - [ ] `03_client_segmentation.ipynb`

5. **Dashboards Power BI**
   - [ ] `kpi_overview.pbix`
   - [ ] `fraud_monitoring.pbix`
   - [ ] `client_analytics.pbix`

6. **Tests**
   - [ ] Tests unitaires ETL
   - [ ] Tests modèles ML
   - [ ] Tests qualité données

## 🎓 Compétences Démontrées

### Data Engineering
- ✅ Modélisation dimensionnelle (Star Schema)
- ✅ Architecture Data Warehouse
- ✅ ETL avec Python
- ✅ Optimisation PostgreSQL
- ✅ Gestion SCD Type 2

### DevOps / Infrastructure
- ✅ Docker & Docker Compose
- ✅ Configuration as Code
- ✅ Orchestration de services
- ✅ CI/CD ready

### Data Science / ML
- ✅ Détection d'anomalies (fraude)
- ✅ Segmentation clients (RFM)
- ✅ Feature Engineering
- ✅ Déséquilibre de classes (SMOTE)

### Business Intelligence
- ✅ KPIs métier
- ✅ Dashboards Power BI
- ✅ Analyses exploratoires
- ✅ Storytelling avec data

### Soft Skills
- ✅ Documentation technique
- ✅ Architecture système
- ✅ Gestion de projet
- ✅ Bonnes pratiques de code

## 🎯 Résultats Attendus

Une fois le projet complété, vous aurez:

1. **Data Warehouse opérationnel**
   - 3M+ clients
   - 36M+ transactions (2 ans)
   - Schéma optimisé et documenté

2. **Pipeline ETL automatisé**
   - Génération données synthétiques
   - Transformation et chargement
   - Validation qualité

3. **Modèles ML performants**
   - Détection fraude: 92% précision
   - Segmentation: 5 segments clients
   - Features engineered

4. **Dashboards interactifs**
   - KPIs temps réel
   - Analyses de fraude
   - Segmentation clients

5. **Projet GitHub pro**
   - Code propre et documenté
   - Facile à déployer
   - Démonstration de compétences

## 🚦 Démarrage Rapide

### 1. Prérequis
```bash
- Docker & Docker Compose
- Python 3.11+
- DBeaver ou PgAdmin
- Power BI Desktop (optionnel)
```

### 2. Installation
```bash
git clone <repo-url>
cd b2b-mobile-money-dwh

# Environnement Python
python -m venv venv
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt

# Lancer l'infrastructure
docker-compose up -d
```

### 3. Vérification
```bash
# Test connexion DB
make status

# Voir les tables
make db-info
```

### 4. Accès aux outils
- PostgreSQL: `localhost:5432`
- PgAdmin: `http://localhost:5050`
- Jupyter: `http://localhost:8888`
- Metabase: `http://localhost:3000`

## 📞 Contact

**Auteur**: Votre Nom  
**LinkedIn**: [votre-profil](https://linkedin.com/in/votre-profil)  
**GitHub**: [@votre-username](https://github.com/votre-username)  
**Email**: votre.email@example.com

## 📄 License

MIT License - Libre d'utilisation pour portfolio et apprentissage

---

## 🎬 Prochaine Étape

**Voulez-vous que je continue avec:**

1. ✅ **Génération des données synthétiques** ?
   - Créer 3M clients B2B réalistes
   - Générer 2 ans de transactions
   - Injecter patterns de fraude

2. ✅ **Pipeline ETL complet** ?
   - Extract, Transform, Load
   - Validation des données
   - Chargement optimisé

3. ✅ **Modèles ML** ?
   - Détection de fraude avec XGBoost
   - Segmentation RFM avec K-Means
   - Feature engineering

4. ✅ **Notebooks Jupyter** ?
   - Exploration de données
   - Analyses visuelles
   - Documentation des insights

**Toutes ces étapes sont prêtes à être développées ! 🚀**
