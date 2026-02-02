import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Base Paths
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
PROCESSED_DATA_DIR = DATA_DIR / "processed"
DWH_DATA_DIR = DATA_DIR / "dwh"

# Create directories if they don't exist
for dir_path in [RAW_DATA_DIR, PROCESSED_DATA_DIR, DWH_DATA_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)

# Database Configuration
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 5432)),
    "database": os.getenv("DB_NAME", "b2b_mobile_money_dwh"),
    "user": os.getenv("DB_USER", "dwh_admin"),
    "password": os.getenv("DB_PASSWORD", "dwh_secure_password"),
}

# Connection String
CONNECTION_STRING = (
    f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
    f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# Data Generation Configuration
DATA_GEN_CONFIG = {
    "n_clients": 3_000_000,  # 3M+ clients comme dans le projet Orange
    "n_transactions_per_day": 50_000,
    "date_range_start": "2023-01-01",
    "date_range_end": "2024-12-31",
    "fraud_rate": 0.02,  # 2% de fraude
    "currency": "XOF",  # Franc CFA
    "countries": ["Senegal", "Ivory Coast", "Mali", "Burkina Faso"],
}

# Business Rules
BUSINESS_RULES = {
    "sectors": [
        "Retail", "Telecommunications", "Banking", "Insurance",
        "Healthcare", "Education", "Transportation", "Agriculture",
        "Manufacturing", "Services", "Technology", "Energy"
    ],
    "company_sizes": {
        "TPE": {"employees": (1, 10), "revenue_range": (0, 2_000_000)},
        "PME": {"employees": (11, 250), "revenue_range": (2_000_000, 50_000_000)},
        "ETI": {"employees": (251, 5000), "revenue_range": (50_000_000, 1_500_000_000)},
        "GE": {"employees": (5001, 50000), "revenue_range": (1_500_000_000, 50_000_000_000)},
    },
    "service_categories": {
        "Paiement Masse": {
            "types": ["Salaire", "Fournisseur", "Commission", "Remboursement"],
            "commission_rate": (0.5, 2.0),
            "amount_range": (50_000, 50_000_000)
        },
        "Encaissement": {
            "types": ["E-commerce", "Facturation", "Abonnement", "Donation"],
            "commission_rate": (1.5, 3.5),
            "amount_range": (1_000, 10_000_000)
        },
        "Paiement Marchand": {
            "types": ["POS", "QR Code", "NFC", "Online"],
            "commission_rate": (2.0, 4.0),
            "amount_range": (500, 5_000_000)
        }
    },
    "channels": ["API", "Web Portal", "Mobile App", "USSD", "Agent"],
    "transaction_statuses": {
        "SUCCESS": {"is_successful": True, "probability": 0.85},
        "PENDING": {"is_successful": False, "probability": 0.05},
        "FAILED": {"is_successful": False, "probability": 0.08},
        "CANCELLED": {"is_successful": False, "probability": 0.02},
    }
}

# ML Model Configuration
ML_CONFIG = {
    "fraud_detection": {
        "model_type": "xgboost",
        "target": "is_fraud",
        "features": [
            "transaction_amount", "hour", "day_of_week", "recipient_count",
            "client_transaction_velocity", "amount_deviation", "is_weekend",
            "is_business_hours", "service_category", "channel"
        ],
        "test_size": 0.3,
        "random_state": 42,
        "precision_target": 0.92,  # 92% comme dans le projet
    },
    "segmentation": {
        "method": "kmeans",
        "n_clusters": 5,
        "features": ["recency", "frequency", "monetary"],
    }
}

# ETL Configuration
ETL_CONFIG = {
    "batch_size": 10_000,
    "max_workers": 4,
    "log_level": "INFO",
    "enable_validation": True,
    "enable_profiling": False,
}

# Logging Configuration
LOG_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "standard": {
            "format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "level": "INFO",
            "formatter": "standard",
            "stream": "ext://sys.stdout",
        },
        "file": {
            "class": "logging.handlers.RotatingFileHandler",
            "level": "DEBUG",
            "formatter": "standard",
            "filename": BASE_DIR / "logs" / "etl.log",
            "maxBytes": 10485760,  # 10MB
            "backupCount": 5,
        },
    },
    "root": {
        "level": "INFO",
        "handlers": ["console", "file"],
    },
}

# KPIs Definition
KPI_DEFINITIONS = {
    "volume_kpis": [
        "total_transactions",
        "total_volume",
        "total_commission",
        "active_clients",
        "new_clients",
    ],
    "quality_kpis": [
        "success_rate",
        "avg_processing_time",
        "fraud_detection_rate",
        "false_positive_rate",
    ],
    "engagement_kpis": [
        "daily_active_users",
        "monthly_active_users",
        "retention_rate",
        "churn_rate",
    ],
    "business_kpis": [
        "revenue_growth",
        "avg_transaction_value",
        "commission_per_client",
        "client_lifetime_value",
    ]
}
