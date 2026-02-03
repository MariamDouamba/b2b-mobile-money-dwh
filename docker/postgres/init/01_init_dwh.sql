-- =============================================
-- B2B Mobile Money Data Warehouse
-- Schéma en étoile (Star Schema)
-- =============================================

-- Création du schéma DWH
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS staging;

-- =============================================
-- TABLES DE DIMENSIONS
-- =============================================

-- Dimension Temps
CREATE TABLE dwh.dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    day_of_month INTEGER,
    day_of_year INTEGER,
    week_of_year INTEGER,
    month_number INTEGER,
    month_name VARCHAR(20),
    quarter INTEGER,
    year INTEGER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    fiscal_year INTEGER,
    fiscal_quarter INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_date_full_date ON dwh.dim_date(full_date);
CREATE INDEX idx_dim_date_year_month ON dwh.dim_date(year, month_number);

-- Dimension Heure
CREATE TABLE dwh.dim_time (
    time_key SERIAL PRIMARY KEY,
    hour INTEGER,
    minute INTEGER,
    time_of_day VARCHAR(20), -- Morning, Afternoon, Evening, Night
    business_hours BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Client B2B (Entreprise)
CREATE TABLE dwh.dim_client (
    client_key SERIAL PRIMARY KEY,
    client_id VARCHAR(50) NOT NULL UNIQUE,
    company_name VARCHAR(255),
    industry_sector VARCHAR(100),
    company_size VARCHAR(50), -- TPE, PME, ETI, GE
    registration_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    account_manager VARCHAR(100),
    customer_segment VARCHAR(50), -- Premium, Standard, Basic
    credit_score INTEGER,
    risk_level VARCHAR(20), -- Low, Medium, High
    is_active BOOLEAN DEFAULT TRUE,
    kyc_status VARCHAR(50),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_client_id ON dwh.dim_client(client_id);
CREATE INDEX idx_dim_client_segment ON dwh.dim_client(customer_segment);
CREATE INDEX idx_dim_client_industry ON dwh.dim_client(industry_sector);

-- Dimension Service
CREATE TABLE dwh.dim_service (
    service_key SERIAL PRIMARY KEY,
    service_id VARCHAR(50) NOT NULL UNIQUE,
    service_name VARCHAR(255),
    service_category VARCHAR(100), -- Paiement Masse, Encaissement, Marchand
    service_type VARCHAR(100), -- Salaire, Fournisseur, E-commerce, POS
    commission_rate DECIMAL(5,2),
    is_premium BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_service_category ON dwh.dim_service(service_category);

-- Dimension Canal
CREATE TABLE dwh.dim_channel (
    channel_key SERIAL PRIMARY KEY,
    channel_id VARCHAR(50) NOT NULL UNIQUE,
    channel_name VARCHAR(100), -- API, Web Portal, Mobile App, USSD
    channel_type VARCHAR(50), -- Digital, Physical
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Statut Transaction
CREATE TABLE dwh.dim_transaction_status (
    status_key SERIAL PRIMARY KEY,
    status_code VARCHAR(20) NOT NULL UNIQUE,
    status_name VARCHAR(100),
    status_category VARCHAR(50), -- Success, Pending, Failed, Cancelled
    is_successful BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Géographique
CREATE TABLE dwh.dim_geography (
    geography_key SERIAL PRIMARY KEY,
    country_code VARCHAR(10),
    country_name VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_geo_country ON dwh.dim_geography(country_name);

-- =============================================
-- TABLE DE FAITS PRINCIPALE
-- =============================================

-- Fait Transactions
CREATE TABLE dwh.fact_transactions (
    transaction_key BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) NOT NULL UNIQUE,
    
    -- Foreign Keys vers les dimensions
    date_key INTEGER REFERENCES dwh.dim_date(date_key),
    time_key INTEGER REFERENCES dwh.dim_time(time_key),
    client_key INTEGER REFERENCES dwh.dim_client(client_key),
    service_key INTEGER REFERENCES dwh.dim_service(service_key),
    channel_key INTEGER REFERENCES dwh.dim_channel(channel_key),
    status_key INTEGER REFERENCES dwh.dim_transaction_status(status_key),
    geography_key INTEGER REFERENCES dwh.dim_geography(geography_key),
    
    -- Mesures
    transaction_amount DECIMAL(15,2),
    commission_amount DECIMAL(15,2),
    net_amount DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'XOF',
    
    -- Attributs dégénérés
    recipient_count INTEGER DEFAULT 1, -- Pour paiements de masse
    processing_time_seconds INTEGER,
    
    -- Indicateurs de fraude
    fraud_score DECIMAL(5,2),
    is_fraud BOOLEAN DEFAULT FALSE,
    fraud_type VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimisation des requêtes
CREATE INDEX idx_fact_trans_date ON dwh.fact_transactions(date_key);
CREATE INDEX idx_fact_trans_client ON dwh.fact_transactions(client_key);
CREATE INDEX idx_fact_trans_service ON dwh.fact_transactions(service_key);
CREATE INDEX idx_fact_trans_status ON dwh.fact_transactions(status_key);
CREATE INDEX idx_fact_trans_fraud ON dwh.fact_transactions(is_fraud);
CREATE INDEX idx_fact_trans_created ON dwh.fact_transactions(created_at);

-- Index composite pour les requêtes fréquentes
CREATE INDEX idx_fact_trans_date_client ON dwh.fact_transactions(date_key, client_key);
CREATE INDEX idx_fact_trans_date_service ON dwh.fact_transactions(date_key, service_key);

-- =============================================
-- TABLE DE FAITS AGRÉGÉE (Pour performance)
-- =============================================

-- Fait Agrégé Quotidien par Client
CREATE TABLE dwh.fact_daily_client_summary (
    summary_key BIGSERIAL PRIMARY KEY,
    date_key INTEGER REFERENCES dwh.dim_date(date_key),
    client_key INTEGER REFERENCES dwh.dim_client(client_key),
    service_key INTEGER REFERENCES dwh.dim_service(service_key),
    
    -- Métriques agrégées
    total_transactions INTEGER,
    successful_transactions INTEGER,
    failed_transactions INTEGER,
    total_amount DECIMAL(15,2),
    total_commission DECIMAL(15,2),
    avg_transaction_amount DECIMAL(15,2),
    max_transaction_amount DECIMAL(15,2),
    min_transaction_amount DECIMAL(15,2),
    
    -- Indicateurs de fraude
    fraud_transactions INTEGER DEFAULT 0,
    fraud_amount DECIMAL(15,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(date_key, client_key, service_key)
);

CREATE INDEX idx_fact_summary_date ON dwh.fact_daily_client_summary(date_key);
CREATE INDEX idx_fact_summary_client ON dwh.fact_daily_client_summary(client_key);

-- =============================================
-- TABLES DE STAGING (Zone de préparation)
-- =============================================

-- Staging pour les transactions brutes
CREATE TABLE staging.stg_transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(100),
    client_id VARCHAR(50),
    service_id VARCHAR(50),
    channel_id VARCHAR(50),
    transaction_date TIMESTAMP,
    amount DECIMAL(15,2),
    status_code VARCHAR(20),
    recipient_count INTEGER,
    country VARCHAR(100),
    city VARCHAR(100),
    raw_data JSONB,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- VUES ANALYTIQUES
-- =============================================

-- Vue pour KPIs globaux
CREATE OR REPLACE VIEW dwh.v_kpi_overview AS
SELECT 
    d.year,
    d.month_name,
    COUNT(f.transaction_key) as total_transactions,
    COUNT(DISTINCT f.client_key) as active_clients,
    SUM(f.transaction_amount) as total_volume,
    SUM(f.commission_amount) as total_revenue,
    AVG(f.transaction_amount) as avg_transaction_amount,
    SUM(CASE WHEN f.is_fraud THEN 1 ELSE 0 END) as fraud_count,
    SUM(CASE WHEN f.is_fraud THEN f.transaction_amount ELSE 0 END) as fraud_amount
FROM dwh.fact_transactions f
JOIN dwh.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_name, d.month_number
ORDER BY d.year, d.month_number;

-- Vue pour segmentation RFM
CREATE OR REPLACE VIEW dwh.v_rfm_segmentation AS
WITH client_metrics AS (
    SELECT 
        c.client_key,
        c.client_id,
        c.company_name,
        MAX(d.full_date) as last_transaction_date,
        COUNT(f.transaction_key) as frequency,
        SUM(f.transaction_amount) as monetary
    FROM dwh.fact_transactions f
    JOIN dwh.dim_client c ON f.client_key = c.client_key
    JOIN dwh.dim_date d ON f.date_key = d.date_key
    WHERE d.full_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY c.client_key, c.client_id, c.company_name
)
SELECT 
    client_key,
    client_id,
    company_name,
    last_transaction_date,
    CURRENT_DATE - last_transaction_date as recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY CURRENT_DATE - last_transaction_date DESC) as recency_score,
    NTILE(5) OVER (ORDER BY frequency) as frequency_score,
    NTILE(5) OVER (ORDER BY monetary) as monetary_score
FROM client_metrics;

-- =============================================
-- FONCTIONS UTILITAIRES
-- =============================================

-- Fonction pour populer la dimension date
CREATE OR REPLACE FUNCTION dwh.populate_dim_date(start_date DATE, end_date DATE)
RETURNS void AS $$
DECLARE
    loop_date DATE := start_date;
BEGIN
    WHILE loop_date <= end_date LOOP
        INSERT INTO dwh.dim_date (
            full_date, day_of_week, day_name, day_of_month, day_of_year,
            week_of_year, month_number, month_name, quarter, year,
            is_weekend, fiscal_year, fiscal_quarter
        )
        VALUES (
            loop_date,
            EXTRACT(DOW FROM loop_date),
            TO_CHAR(loop_date, 'Day'),
            EXTRACT(DAY FROM loop_date),
            EXTRACT(DOY FROM loop_date),
            EXTRACT(WEEK FROM loop_date),
            EXTRACT(MONTH FROM loop_date),
            TO_CHAR(loop_date, 'Month'),
            EXTRACT(QUARTER FROM loop_date),
            EXTRACT(YEAR FROM loop_date),
            EXTRACT(DOW FROM loop_date) IN (0, 6),
            EXTRACT(YEAR FROM loop_date),
            EXTRACT(QUARTER FROM loop_date)
        )
        ON CONFLICT (full_date) DO NOTHING;

        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Peupler la dimension date pour 3 ans
SELECT dwh.populate_dim_date('2022-01-01'::DATE, '2025-12-31'::DATE);

-- Fonction pour populer la dimension temps
CREATE OR REPLACE FUNCTION dwh.populate_dim_time()
RETURNS void AS $$
DECLARE
    h INTEGER;
    m INTEGER;
    time_category VARCHAR(20);
    is_business_hours BOOLEAN;
BEGIN
    FOR h IN 0..23 LOOP
        FOR m IN 0..59 LOOP
            -- Déterminer la catégorie de temps
            IF h >= 6 AND h < 12 THEN
                time_category := 'Morning';
            ELSIF h >= 12 AND h < 18 THEN
                time_category := 'Afternoon';
            ELSIF h >= 18 AND h < 22 THEN
                time_category := 'Evening';
            ELSE
                time_category := 'Night';
            END IF;
            
            -- Heures de bureau: 8h-18h en semaine
            is_business_hours := (h >= 8 AND h < 18);
            
            INSERT INTO dwh.dim_time (hour, minute, time_of_day, business_hours)
            VALUES (h, m, time_category, is_business_hours)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Peupler la dimension temps
SELECT dwh.populate_dim_time();

-- =============================================
-- GRANTS ET PERMISSIONS
-- =============================================

GRANT USAGE ON SCHEMA dwh TO dwh_admin;
GRANT USAGE ON SCHEMA staging TO dwh_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dwh TO dwh_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO dwh_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dwh TO dwh_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA staging TO dwh_admin;

-- Commentaires pour documentation
COMMENT ON SCHEMA dwh IS 'Data Warehouse principal pour B2B Mobile Money';
COMMENT ON TABLE dwh.fact_transactions IS 'Table de faits contenant toutes les transactions B2B';
COMMENT ON TABLE dwh.dim_client IS 'Dimension SCD Type 2 pour les clients entreprises';
