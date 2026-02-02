# 📖 Dictionnaire de Données - B2B Mobile Money DWH

## Vue d'ensemble

Ce document décrit en détail toutes les tables, colonnes et leurs relations dans le Data Warehouse.

---

## 🌟 Tables de Dimensions

### 1. `dwh.dim_date` - Dimension Temps (Calendrier)

Dimension conformée pour toutes les analyses temporelles.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `date_key` | SERIAL (PK) | Clé surrogate | 1, 2, 3... |
| `full_date` | DATE | Date complète (UNIQUE) | 2024-01-15 |
| `day_of_week` | INTEGER | Jour de la semaine (0=Dimanche) | 1 (Lundi) |
| `day_name` | VARCHAR(20) | Nom du jour | "Monday" |
| `day_of_month` | INTEGER | Jour du mois | 15 |
| `day_of_year` | INTEGER | Jour de l'année | 15 |
| `week_of_year` | INTEGER | Semaine de l'année | 3 |
| `month_number` | INTEGER | Numéro du mois | 1 |
| `month_name` | VARCHAR(20) | Nom du mois | "January" |
| `quarter` | INTEGER | Trimestre | 1 |
| `year` | INTEGER | Année | 2024 |
| `is_weekend` | BOOLEAN | Est un weekend | true/false |
| `is_holiday` | BOOLEAN | Est un jour férié | true/false |
| `fiscal_year` | INTEGER | Année fiscale | 2024 |
| `fiscal_quarter` | INTEGER | Trimestre fiscal | 1 |

**Volumétrie:** ~1,460 lignes (4 ans de données)

---

### 2. `dwh.dim_time` - Dimension Heure

Granularité minute pour analyses temporelles fines.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `time_key` | SERIAL (PK) | Clé surrogate | 1, 2, 3... |
| `hour` | INTEGER | Heure (0-23) | 14 |
| `minute` | INTEGER | Minute (0-59) | 30 |
| `time_of_day` | VARCHAR(20) | Période de la journée | "Afternoon" |
| `business_hours` | BOOLEAN | Heures de bureau (8h-18h) | true/false |

**Périodes:** Morning (6h-12h), Afternoon (12h-18h), Evening (18h-22h), Night (22h-6h)

**Volumétrie:** 1,440 lignes (24h × 60min)

---

### 3. `dwh.dim_client` - Dimension Client B2B

**Type:** SCD Type 2 (Slowly Changing Dimension)

Contient les informations sur les entreprises clientes.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `client_key` | SERIAL (PK) | Clé surrogate | 1, 2, 3... |
| `client_id` | VARCHAR(50) | ID métier du client (UNIQUE) | "CL-2024-001234" |
| `company_name` | VARCHAR(255) | Raison sociale | "Orange Sénégal SA" |
| `industry_sector` | VARCHAR(100) | Secteur d'activité | "Telecommunications" |
| `company_size` | VARCHAR(50) | Taille entreprise | "GE" |
| `registration_date` | DATE | Date d'inscription | 2023-06-15 |
| `country` | VARCHAR(100) | Pays | "Senegal" |
| `city` | VARCHAR(100) | Ville | "Dakar" |
| `region` | VARCHAR(100) | Région | "Dakar" |
| `account_manager` | VARCHAR(100) | Gestionnaire de compte | "Jean Dupont" |
| `customer_segment` | VARCHAR(50) | Segment client | "Premium" |
| `credit_score` | INTEGER | Score de crédit (0-100) | 85 |
| `risk_level` | VARCHAR(20) | Niveau de risque | "Low" |
| `is_active` | BOOLEAN | Client actif | true |
| `kyc_status` | VARCHAR(50) | Statut KYC | "Verified" |
| `valid_from` | TIMESTAMP | Date de début validité | 2023-06-15 00:00:00 |
| `valid_to` | TIMESTAMP | Date de fin validité | NULL (actuel) |
| `is_current` | BOOLEAN | Enregistrement actuel | true |

**Tailles d'entreprise:**
- **TPE** (Très Petite Entreprise): 1-10 employés
- **PME** (Petite et Moyenne Entreprise): 11-250 employés
- **ETI** (Entreprise de Taille Intermédiaire): 251-5000 employés
- **GE** (Grande Entreprise): 5001+ employés

**Segments:**
- **Premium**: Grands comptes, haut volume
- **Standard**: Comptes moyens
- **Basic**: Petits comptes

**Volumétrie:** ~3,000,000 lignes (3M clients)

---

### 4. `dwh.dim_service` - Dimension Service

Services financiers proposés aux entreprises.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `service_key` | SERIAL (PK) | Clé surrogate | 1, 2, 3... |
| `service_id` | VARCHAR(50) | ID du service (UNIQUE) | "SRV-PAY-MASS-001" |
| `service_name` | VARCHAR(255) | Nom du service | "Paiement Salaires" |
| `service_category` | VARCHAR(100) | Catégorie principale | "Paiement Masse" |
| `service_type` | VARCHAR(100) | Type spécifique | "Salaire" |
| `commission_rate` | DECIMAL(5,2) | Taux de commission (%) | 1.50 |
| `is_premium` | BOOLEAN | Service premium | false |
| `is_active` | BOOLEAN | Service actif | true |

**Catégories de services:**

1. **Paiement Masse**
   - Salaire (paie des employés)
   - Fournisseur (paiement fournisseurs)
   - Commission (paiement agents)
   - Remboursement (remboursements clients)

2. **Encaissement**
   - E-commerce (paiements en ligne)
   - Facturation (factures B2B)
   - Abonnement (paiements récurrents)
   - Donation (dons et collectes)

3. **Paiement Marchand**
   - POS (Terminal de paiement)
   - QR Code (Paiement par QR)
   - NFC (Paiement sans contact)
   - Online (Paiement web)

**Volumétrie:** ~20-30 lignes

---

### 5. `dwh.dim_channel` - Dimension Canal

Canaux de distribution des services.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `channel_key` | SERIAL (PK) | Clé surrogate | 1 |
| `channel_id` | VARCHAR(50) | ID du canal (UNIQUE) | "CH-API-001" |
| `channel_name` | VARCHAR(100) | Nom du canal | "API REST" |
| `channel_type` | VARCHAR(50) | Type de canal | "Digital" |
| `is_active` | BOOLEAN | Canal actif | true |

**Canaux disponibles:**
- **API**: Intégration programmatique
- **Web Portal**: Interface web entreprise
- **Mobile App**: Application mobile B2B
- **USSD**: Menu USSD structuré
- **Agent**: Via réseau d'agents

**Volumétrie:** ~5-10 lignes

---

### 6. `dwh.dim_transaction_status` - Dimension Statut

Statuts possibles des transactions.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `status_key` | SERIAL (PK) | Clé surrogate | 1 |
| `status_code` | VARCHAR(20) | Code statut (UNIQUE) | "SUCCESS" |
| `status_name` | VARCHAR(100) | Nom descriptif | "Transaction réussie" |
| `status_category` | VARCHAR(50) | Catégorie de statut | "Success" |
| `is_successful` | BOOLEAN | Indique succès | true |

**Statuts:**
- **SUCCESS**: Transaction réussie
- **PENDING**: En attente de traitement
- **FAILED**: Échec technique
- **CANCELLED**: Annulée par l'utilisateur
- **TIMEOUT**: Délai d'expiration dépassé
- **REJECTED**: Rejetée (solde insuffisant, etc.)

**Volumétrie:** ~10 lignes

---

### 7. `dwh.dim_geography` - Dimension Géographique

Localisation géographique des transactions.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `geography_key` | SERIAL (PK) | Clé surrogate | 1 |
| `country_code` | VARCHAR(10) | Code pays ISO | "SN" |
| `country_name` | VARCHAR(100) | Nom du pays | "Senegal" |
| `region` | VARCHAR(100) | Région/Province | "Dakar" |
| `city` | VARCHAR(100) | Ville | "Dakar" |
| `postal_code` | VARCHAR(20) | Code postal | "10000" |
| `latitude` | DECIMAL(10,8) | Latitude | 14.6928 |
| `longitude` | DECIMAL(11,8) | Longitude | -17.4467 |

**Pays couverts:** Sénégal, Côte d'Ivoire, Mali, Burkina Faso

**Volumétrie:** ~100-500 lignes

---

## 📊 Tables de Faits

### 8. `dwh.fact_transactions` - Fait Principal

Table de faits centrale contenant toutes les transactions.

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `transaction_key` | BIGSERIAL (PK) | Clé surrogate | 1 |
| `transaction_id` | VARCHAR(100) | ID métier transaction (UNIQUE) | "TXN-2024-001234567" |
| `date_key` | INTEGER (FK) | Référence dim_date | 365 |
| `time_key` | INTEGER (FK) | Référence dim_time | 870 (14h30) |
| `client_key` | INTEGER (FK) | Référence dim_client | 12345 |
| `service_key` | INTEGER (FK) | Référence dim_service | 5 |
| `channel_key` | INTEGER (FK) | Référence dim_channel | 2 |
| `status_key` | INTEGER (FK) | Référence dim_transaction_status | 1 |
| `geography_key` | INTEGER (FK) | Référence dim_geography | 10 |
| `transaction_amount` | DECIMAL(15,2) | Montant transaction | 500000.00 |
| `commission_amount` | DECIMAL(15,2) | Commission prélevée | 7500.00 |
| `net_amount` | DECIMAL(15,2) | Montant net | 492500.00 |
| `currency_code` | VARCHAR(3) | Devise | "XOF" |
| `recipient_count` | INTEGER | Nombre de bénéficiaires | 150 |
| `processing_time_seconds` | INTEGER | Temps de traitement | 5 |
| `fraud_score` | DECIMAL(5,2) | Score de risque fraude | 0.15 |
| `is_fraud` | BOOLEAN | Fraude détectée | false |
| `fraud_type` | VARCHAR(50) | Type de fraude | NULL |

**Granularité:** Une ligne = Une transaction

**Volumétrie estimée:** 
- Transactions quotidiennes: ~50,000
- Transactions annuelles: ~18,250,000
- Sur 2 ans: ~36,500,000 lignes

**Types de fraude:**
- `velocity_fraud`: Trop de transactions en peu de temps
- `amount_fraud`: Montant anormalement élevé
- `time_fraud`: Transactions à heures inhabituelles
- `duplicate_fraud`: Transactions dupliquées
- `geo_fraud`: Localisation incohérente

---

### 9. `dwh.fact_daily_client_summary` - Fait Agrégé

Agrégations quotidiennes par client et service (pour performance).

| Colonne | Type | Description | Exemple |
|---------|------|-------------|---------|
| `summary_key` | BIGSERIAL (PK) | Clé surrogate | 1 |
| `date_key` | INTEGER (FK) | Référence dim_date | 365 |
| `client_key` | INTEGER (FK) | Référence dim_client | 12345 |
| `service_key` | INTEGER (FK) | Référence dim_service | 5 |
| `total_transactions` | INTEGER | Nombre total de transactions | 25 |
| `successful_transactions` | INTEGER | Transactions réussies | 22 |
| `failed_transactions` | INTEGER | Transactions échouées | 3 |
| `total_amount` | DECIMAL(15,2) | Volume total | 12500000.00 |
| `total_commission` | DECIMAL(15,2) | Commissions totales | 187500.00 |
| `avg_transaction_amount` | DECIMAL(15,2) | Montant moyen | 500000.00 |
| `max_transaction_amount` | DECIMAL(15,2) | Montant maximum | 2000000.00 |
| `min_transaction_amount` | DECIMAL(15,2) | Montant minimum | 100000.00 |
| `fraud_transactions` | INTEGER | Nombre de fraudes | 0 |
| `fraud_amount` | DECIMAL(15,2) | Montant frauduleux | 0.00 |

**Contrainte:** UNIQUE(date_key, client_key, service_key)

**Volumétrie:** ~1,000,000 lignes (beaucoup moins que fact_transactions)

---

## 🔍 Vues Analytiques

### 10. `dwh.v_kpi_overview` - Vue KPIs Globaux

Indicateurs clés de performance agrégés par mois.

```sql
SELECT 
    year,
    month_name,
    total_transactions,
    active_clients,
    total_volume,
    total_revenue,
    avg_transaction_amount,
    fraud_count,
    fraud_amount
FROM dwh.v_kpi_overview
WHERE year = 2024;
```

---

### 11. `dwh.v_rfm_segmentation` - Vue Segmentation RFM

Analyse RFM (Recency, Frequency, Monetary) pour segmentation clients.

```sql
SELECT 
    client_id,
    company_name,
    recency_days,      -- Jours depuis dernière transaction
    frequency,          -- Nombre de transactions
    monetary,           -- Volume total
    recency_score,      -- Score 1-5
    frequency_score,    -- Score 1-5
    monetary_score      -- Score 1-5
FROM dwh.v_rfm_segmentation;
```

**Interprétation des scores:**
- **5**: Meilleur (ex: très récent, très fréquent, très élevé)
- **1**: Le moins bon (ex: ancien, rare, faible)

**Segments résultants:**
- **Champions** (5-5-5): Meilleurs clients
- **Loyal** (4-5-4): Clients fidèles
- **At Risk** (2-4-4): Risque de perte
- **Lost** (1-1-1): Clients perdus

---

## 📋 Tables de Staging

### 12. `staging.stg_transactions` - Staging Transactions

Zone de préparation avant chargement dans le DWH.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | SERIAL (PK) | ID auto-incrémenté |
| `transaction_id` | VARCHAR(100) | ID transaction source |
| `client_id` | VARCHAR(50) | ID client source |
| `service_id` | VARCHAR(50) | ID service source |
| `channel_id` | VARCHAR(50) | ID canal source |
| `transaction_date` | TIMESTAMP | Date/heure transaction |
| `amount` | DECIMAL(15,2) | Montant |
| `status_code` | VARCHAR(20) | Code statut |
| `recipient_count` | INTEGER | Nombre bénéficiaires |
| `country` | VARCHAR(100) | Pays |
| `city` | VARCHAR(100) | Ville |
| `raw_data` | JSONB | Données brutes JSON |
| `loaded_at` | TIMESTAMP | Date de chargement |

---

## 🔗 Relations entre Tables

```
dim_date ──────────┐
                   │
dim_time ──────────┤
                   │
dim_client ────────┤
                   │
dim_service ───────┼──── fact_transactions
                   │
dim_channel ───────┤
                   │
dim_status ────────┤
                   │
dim_geography ─────┘

fact_transactions ──── fact_daily_client_summary
```

---

## 📊 Métriques Calculées

### Taux de Succès
```sql
successful_transactions / total_transactions * 100
```

### Taux de Fraude
```sql
fraud_transactions / total_transactions * 100
```

### Commission Moyenne
```sql
total_commission / total_transactions
```

### ARPU (Average Revenue Per User)
```sql
total_commission / active_clients
```

---

## 🎯 Exemples de Requêtes Analytiques

### Top 10 Clients par Volume
```sql
SELECT 
    c.company_name,
    COUNT(f.transaction_key) as nb_transactions,
    SUM(f.transaction_amount) as total_volume,
    SUM(f.commission_amount) as revenue
FROM dwh.fact_transactions f
JOIN dwh.dim_client c ON f.client_key = c.client_key
GROUP BY c.company_name
ORDER BY total_volume DESC
LIMIT 10;
```

### Évolution Mensuelle
```sql
SELECT 
    d.year,
    d.month_name,
    COUNT(*) as transactions,
    SUM(f.transaction_amount) as volume
FROM dwh.fact_transactions f
JOIN dwh.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_name, d.month_number
ORDER BY d.year, d.month_number;
```

### Performance par Service
```sql
SELECT 
    s.service_category,
    COUNT(*) as transactions,
    SUM(f.commission_amount) as revenue,
    AVG(f.processing_time_seconds) as avg_time
FROM dwh.fact_transactions f
JOIN dwh.dim_service s ON f.service_key = s.service_key
GROUP BY s.service_category;
```

---

## 📝 Notes Importantes

1. **Devise:** Toutes les transactions sont en XOF (Franc CFA)
2. **Timezone:** UTC (à convertir selon les besoins)
3. **SCD Type 2:** La dimension client conserve l'historique des modifications
4. **Index:** Des index sont créés sur toutes les clés étrangères pour optimiser les performances
5. **Partitionnement:** Envisager un partitionnement par date pour fact_transactions si volume > 100M lignes
