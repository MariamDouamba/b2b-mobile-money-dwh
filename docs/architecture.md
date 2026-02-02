# 🏗️ Architecture Technique Détaillée

## Vue d'Ensemble

Ce document décrit en détail l'architecture technique du Data Warehouse B2B Mobile Money, incluant les choix technologiques, les patterns utilisés et les justifications.

---

## 🎯 Principes de Conception

### 1. Séparation des Préoccupations
- **Extraction** (Extract): Lecture des données sources
- **Transformation** (Transform): Nettoyage, validation, enrichissement
- **Chargement** (Load): Insertion dans le DWH
- **Analytics**: Analyses et ML séparés du pipeline ETL

### 2. Idempotence
- Toutes les opérations ETL peuvent être rejouées sans effet de bord
- Utilisation de clés naturelles pour détecter les doublons
- Gestion des SCD Type 2 pour l'historique

### 3. Scalabilité
- Traitement par batch pour grandes volumétries
- Index optimisés sur les FK et colonnes de filtrage
- Tables agrégées pour requêtes fréquentes

### 4. Observabilité
- Logs détaillés à chaque étape
- Métriques de qualité des données
- Monitoring des performances

---

## 🗄️ Architecture du Data Warehouse

### Schéma en Étoile (Star Schema)

**Avantages:**
- ✅ Requêtes simples et performantes
- ✅ Compréhension intuitive pour les analystes
- ✅ Optimisé pour les outils BI (Power BI, Tableau, Metabase)
- ✅ Agrégations rapides

**Alternatives considérées:**
- ❌ **Schéma en Flocon** (Snowflake): Trop de jointures, moins performant
- ❌ **Modèle Data Vault**: Trop complexe pour ce cas d'usage
- ❌ **One Big Table**: Pas assez flexible, redondance excessive

### Tables de Faits

#### fact_transactions (Grain: Transaction)
- **Grain**: Une ligne = une transaction individuelle
- **Type**: Fact Table transactionnelle
- **Volumétrie**: ~36M lignes (2 ans)
- **Partitionnement**: Envisageable par `date_key` si > 100M lignes

#### fact_daily_client_summary (Grain: Client-Service-Jour)
- **Grain**: Une ligne = un client × service × jour
- **Type**: Aggregate Fact Table
- **Utilité**: Accélération des requêtes récurrentes (dashboards)
- **Refresh**: Quotidien via job ETL

### Tables de Dimensions

#### Dimensions Conformées
- **dim_date**: Partagée par tous les faits temporels
- **dim_time**: Granularité minute
- Permet le drill-down temporel cohérent

#### SCD Type 2: dim_client
- **Historisation**: Changement de segment, taille, risque
- **Colonnes de gestion**:
  - `valid_from`: Date de début de validité
  - `valid_to`: Date de fin (NULL pour actuel)
  - `is_current`: Boolean pour version actuelle
- **Avantage**: Analyses historiques précises

---

## 🔄 Pipeline ETL

### Architecture ETL

```
┌─────────────────────────────────────────┐
│         SOURCES (CSV/Parquet)           │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│     EXTRACT (src/etl/extract.py)        │
│  • Lecture fichiers                     │
│  • Validation schéma                    │
│  • Détection encodage                   │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   TRANSFORM (src/etl/transform.py)      │
│  • Nettoyage données                    │
│  • Lookup dimensions                    │
│  • Feature engineering                  │
│  • Calcul métriques                     │
│  • Détection anomalies                  │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│       STAGING (staging.stg_*)           │
│  • Zone de préparation                  │
│  • Validation finale                    │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│      LOAD (src/etl/load.py)             │
│  • Bulk insert optimisé                 │
│  • Gestion SCD Type 2                   │
│  • Update agrégats                      │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│      DATA WAREHOUSE (dwh.*)             │
│  • Dimensions + Faits                   │
│  • Vues analytiques                     │
└─────────────────────────────────────────┘
```

### Patterns ETL Utilisés

#### 1. Bulk Insert avec Pandas
```python
df.to_sql(
    name='table_name',
    con=engine,
    schema='dwh',
    if_exists='append',
    index=False,
    chunksize=10000,
    method='multi'  # INSERT avec plusieurs VALUES
)
```
**Performance**: ~10-50k lignes/seconde selon la machine

#### 2. Upsert pour Dimensions
```python
# Pseudo-code
ON CONFLICT (natural_key) DO UPDATE SET
    column1 = EXCLUDED.column1,
    updated_at = CURRENT_TIMESTAMP
```

#### 3. Dimension Lookup Cache
```python
# Cache des dimensions en mémoire pour éviter les requêtes répétées
dim_cache = {
    'client': {client_id: client_key},
    'service': {service_id: service_key}
}
```

---

## 🐳 Infrastructure Docker

### Services Docker Compose

#### 1. PostgreSQL (postgres-dwh)
```yaml
Image: postgres:15-alpine
Role: Data Warehouse principal
Port: 5432
Volume: Persistance des données
```

**Configuration optimisée:**
- `shared_buffers`: 25% RAM
- `effective_cache_size`: 75% RAM
- `work_mem`: Ajusté selon volumétrie
- `maintenance_work_mem`: Pour VACUUM et index

#### 2. PgAdmin (pgadmin)
```yaml
Image: dpage/pgadmin4
Role: Interface web PostgreSQL
Port: 5050
```

**Utilité:**
- Visualisation du schéma
- Requêtes ad-hoc
- Monitoring

#### 3. Jupyter (jupyter)
```yaml
Image: jupyter/scipy-notebook
Role: Analyse exploratoire et ML
Port: 8888
```

**Librairies incluses:**
- NumPy, Pandas, Scikit-learn
- Matplotlib, Seaborn
- Accès au code source via volume

#### 4. Metabase (metabase)
```yaml
Image: metabase/metabase
Role: Dashboards web (alternative Power BI)
Port: 3000
```

**Avantages:**
- Open source, gratuit
- Interface drag-and-drop
- Alerte automatique
- Export vers Slack, email

### Réseau Docker
```yaml
networks:
  b2b_network:
    driver: bridge
```
- Communication inter-conteneurs
- Isolation du réseau externe

### Volumes Docker
```yaml
volumes:
  postgres_data:  # Données PostgreSQL
  pgadmin_data:   # Config PgAdmin
  metabase_data:  # Config Metabase
```
- Persistance après `docker-compose down`
- Backups facilités

---

## 🤖 Machine Learning

### Architecture ML

```
┌─────────────────────────────────────────┐
│         DATA WAREHOUSE (dwh.*)          │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   FEATURE ENGINEERING (ml/features.py)  │
│  • Création features temporelles        │
│  • Agrégations client                   │
│  • Encodage catégorielles               │
│  • Normalisation                        │
└────────────────┬────────────────────────┘
                 │
         ┌───────┴──────┐
         ▼              ▼
┌──────────────┐ ┌──────────────┐
│  Fraude ML   │ │ Segmentation │
│  (XGBoost)   │ │  (K-Means)   │
└──────┬───────┘ └──────┬───────┘
       │                │
       ▼                ▼
┌──────────────────────────────┐
│     Prédictions / Scores     │
│  • fraud_score (0-1)         │
│  • client_segment (1-5)      │
└──────────────────────────────┘
```

### Modèle de Détection de Fraude

**Algorithme**: XGBoost Classifier

**Raisons du choix:**
- ✅ Gestion native des valeurs manquantes
- ✅ Robuste au déséquilibre de classes
- ✅ Feature importance intégrée
- ✅ Rapide en prédiction
- ✅ Excellentes performances (92% précision)

**Features Principales:**
1. **Temporelles**:
   - Heure de la transaction
   - Jour de la semaine
   - Est weekend
   - Est heures de bureau

2. **Montant**:
   - Montant de la transaction
   - Écart à la moyenne client
   - Écart-type des montants

3. **Comportementales**:
   - Vélocité (transactions/heure)
   - Nombre de bénéficiaires
   - Changement de canal habituel

4. **Géographiques**:
   - Distance par rapport à localisation habituelle
   - Pays différent

**Gestion du déséquilibre:**
- SMOTE (Synthetic Minority Over-sampling)
- Class weights
- Métrique: F1-score (balance précision/recall)

### Segmentation RFM

**Algorithme**: K-Means Clustering (k=5)

**Features:**
- **R**ecency: Jours depuis dernière transaction
- **F**requency: Nombre de transactions (12 mois)
- **M**onetary: Volume total transacté

**Segments:**
1. **Champions** (R:5, F:5, M:5)
   - Action: Programmes VIP, early access

2. **Loyal** (R:4-5, F:4-5, M:3-4)
   - Action: Upsell, cross-sell

3. **At Risk** (R:2-3, F:3-4, M:3-4)
   - Action: Win-back campaigns

4. **Hibernating** (R:1-2, F:2-3, M:2-3)
   - Action: Réactivation agressive

5. **Lost** (R:1, F:1, M:1)
   - Action: Analyse de churn, enquête

---

## 📊 Tableaux de Bord Power BI

### Architecture de Connexion

```
Power BI Desktop
      │
      ▼
DirectQuery / Import
      │
      ▼
PostgreSQL DWH
  (localhost:5432)
      │
      ▼
Vues Analytiques
  (dwh.v_*)
```

### Modes de Connexion

#### Import Mode
- **Avantages**: Rapide, fonctionne hors ligne
- **Inconvénients**: Données non temps réel
- **Utilisation**: Dashboards historiques

#### DirectQuery Mode
- **Avantages**: Données en temps réel
- **Inconvénients**: Dépendant de la DB
- **Utilisation**: Monitoring opérationnel

### Dashboards Recommandés

1. **KPI Overview**
   - Volume de transactions
   - Revenu (commissions)
   - Clients actifs
   - Taux de succès

2. **Fraud Monitoring**
   - Transactions frauduleuses (carte chaleur)
   - Évolution fraude par jour
   - Top clients à risque
   - Montant sauvé

3. **Client Segmentation**
   - Distribution RFM
   - Lifetime value par segment
   - Migration de segments
   - Clients à risque de churn

4. **Service Performance**
   - Volume par service
   - Commission par service
   - Temps de traitement moyen
   - Taux d'échec

---

## 🔒 Sécurité et Conformité

### Données Sensibles

1. **Anonymisation**
   ```python
   # Hashing des données PII
   client_id_hash = hashlib.sha256(real_id.encode()).hexdigest()
   ```

2. **Encryption at Rest**
   - Volumes Docker chiffrés
   - PostgreSQL: pgcrypto extension

3. **Access Control**
   ```sql
   -- Rôles PostgreSQL
   GRANT SELECT ON dwh.* TO analyst_role;
   GRANT ALL ON dwh.* TO etl_role;
   ```

### Audit Trail

```sql
-- Logs d'accès
CREATE TABLE audit.access_log (
    user_name VARCHAR(100),
    access_time TIMESTAMP,
    table_name VARCHAR(100),
    action VARCHAR(20)
);
```

### RGPD

- **Droit à l'oubli**: Fonction de suppression complète
- **Portabilité**: Export en CSV/JSON
- **Minimisation**: Seulement données nécessaires

---

## 📈 Performance et Optimisation

### Index Stratégiques

```sql
-- Fact table
CREATE INDEX idx_fact_date_client ON fact_transactions(date_key, client_key);
CREATE INDEX idx_fact_service ON fact_transactions(service_key);

-- Dimensions
CREATE INDEX idx_client_segment ON dim_client(customer_segment);
CREATE INDEX idx_date_year_month ON dim_date(year, month_number);
```

### Partitionnement (si > 100M lignes)

```sql
-- Partitionnement par range sur date_key
CREATE TABLE fact_transactions (
    ...
) PARTITION BY RANGE (date_key);

CREATE TABLE fact_trans_2023 PARTITION OF fact_transactions
    FOR VALUES FROM (1) TO (365);

CREATE TABLE fact_trans_2024 PARTITION OF fact_transactions
    FOR VALUES FROM (366) TO (730);
```

### Materialized Views

```sql
-- Pour dashboards temps réel
CREATE MATERIALIZED VIEW dwh.mv_daily_kpi AS
SELECT ...
WITH DATA;

-- Refresh quotidien
REFRESH MATERIALIZED VIEW CONCURRENTLY dwh.mv_daily_kpi;
```

### Query Optimization

1. **EXPLAIN ANALYZE**: Identifier les goulets
2. **Vacuum régulier**: Maintenir les stats à jour
3. **Connection pooling**: PgBouncer pour haute concurrence

---

## 🔄 Orchestration et Scheduling

### Airflow (Optionnel)

```python
# DAG ETL quotidien
from airflow import DAG
from airflow.operators.python import PythonOperator

dag = DAG('b2b_etl_daily', schedule_interval='@daily')

extract = PythonOperator(task_id='extract', python_callable=extract_data)
transform = PythonOperator(task_id='transform', python_callable=transform_data)
load = PythonOperator(task_id='load', python_callable=load_data)

extract >> transform >> load
```

### Cron Alternative

```bash
# crontab -e
0 2 * * * cd /path/to/project && ./venv/bin/python src/etl/run_etl.py
```

---

## 🧪 Tests et Qualité

### Tests Unitaires

```python
# pytest
def test_dimension_lookup():
    client_key = get_client_key('CL-001')
    assert client_key is not None
    assert isinstance(client_key, int)
```

### Data Quality Tests

```python
# Great Expectations
expect_column_values_to_not_be_null('transaction_amount')
expect_column_values_to_be_between('commission_rate', 0, 5)
expect_table_row_count_to_be_between(min_value=1000, max_value=1000000)
```

---

## 📦 Déploiement

### Environnements

1. **Development** (local Docker)
2. **Staging** (Cloud VM)
3. **Production** (Kubernetes / Cloud SQL)

### CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          python -m pytest tests/
      - name: Build Docker
        run: docker-compose build
```

---

## 🎓 Bonnes Pratiques Appliquées

1. ✅ **Code modulaire**: Chaque composant isolé
2. ✅ **Configuration externalisée**: `.env`, `config.py`
3. ✅ **Logging centralisé**: Tous les logs dans `/logs`
4. ✅ **Documentation**: README, docstrings, comments
5. ✅ **Version control**: Git avec .gitignore
6. ✅ **Idempotence**: Pipelines rejouables
7. ✅ **Monitoring**: Métriques à chaque étape
8. ✅ **Tests**: Unitaires et d'intégration

---

## 📚 Références

- **Kimball Methodology**: Data Warehouse design
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **XGBoost**: https://xgboost.readthedocs.io/
- **Docker Compose**: https://docs.docker.com/compose/
- **Power BI**: https://docs.microsoft.com/power-bi/

---

**Auteur**: Votre Nom  
**Date**: 2024  
**Version**: 1.0
