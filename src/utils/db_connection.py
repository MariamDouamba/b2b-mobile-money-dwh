"""
Module de gestion de connexion à la base de données PostgreSQL
"""
import psycopg2
from psycopg2.extras import RealDictCursor
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from contextlib import contextmanager
import logging
from typing import Generator, Optional

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent.parent))

from config.config import DB_CONFIG, CONNECTION_STRING

logger = logging.getLogger(__name__)


class DatabaseConnection:
    """Gestion des connexions à la base de données"""
    
    def __init__(self):
        self.connection_string = CONNECTION_STRING
        self.engine = None
        self.SessionLocal = None
    
    def get_engine(self):
        """Créer ou retourner l'engine SQLAlchemy"""
        if self.engine is None:
            self.engine = create_engine(
                self.connection_string,
                pool_size=10,
                max_overflow=20,
                pool_pre_ping=True,
                echo=False
            )
            logger.info("Engine SQLAlchemy créé avec succès")
        return self.engine
    
    def get_session(self):
        """Créer une session SQLAlchemy"""
        if self.SessionLocal is None:
            engine = self.get_engine()
            self.SessionLocal = sessionmaker(
                autocommit=False,
                autoflush=False,
                bind=engine
            )
        return self.SessionLocal()
    
    @contextmanager
    def get_connection(self) -> Generator:
        """Context manager pour connexion psycopg2"""
        conn = None
        try:
            conn = psycopg2.connect(**DB_CONFIG)
            yield conn
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error(f"Erreur de connexion: {e}")
            raise
        finally:
            if conn:
                conn.close()
    
    @contextmanager
    def get_cursor(self, dict_cursor=True) -> Generator:
        """Context manager pour cursor psycopg2"""
        with self.get_connection() as conn:
            cursor_factory = RealDictCursor if dict_cursor else None
            cursor = conn.cursor(cursor_factory=cursor_factory)
            try:
                yield cursor
            finally:
                cursor.close()
    
    def execute_query(self, query: str, params: Optional[tuple] = None):
        """Exécuter une requête et retourner les résultats"""
        with self.get_cursor() as cursor:
            cursor.execute(query, params)
            try:
                return cursor.fetchall()
            except psycopg2.ProgrammingError:
                # Pas de résultats à récupérer (INSERT, UPDATE, etc.)
                return None
    
    def execute_many(self, query: str, data: list):
        """Exécuter une requête avec plusieurs jeux de paramètres"""
        with self.get_cursor() as cursor:
            cursor.executemany(query, data)
            logger.info(f"{len(data)} lignes insérées")
    
    def test_connection(self) -> bool:
        """Tester la connexion à la base"""
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT 1")
                    result = cursor.fetchone()
                    logger.info("✓ Connexion à la base de données réussie")
                    return True
        except Exception as e:
            logger.error(f"✗ Échec de connexion: {e}")
            return False
    
    def get_table_info(self, schema: str = 'dwh') -> list:
        """Obtenir la liste des tables dans un schéma"""
        query = """
            SELECT table_name, 
                   pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
            FROM pg_tables 
            WHERE schemaname = %s
            ORDER BY table_name;
        """
        return self.execute_query(query, (schema,))
    
    def get_row_count(self, table_name: str, schema: str = 'dwh') -> int:
        """Obtenir le nombre de lignes dans une table"""
        query = f"SELECT COUNT(*) as count FROM {schema}.{table_name}"
        result = self.execute_query(query)
        return result[0]['count'] if result else 0


class DataLoader:
    """Chargement de données dans le DWH"""
    
    def __init__(self):
        self.db = DatabaseConnection()
    
    def bulk_insert_df(self, df, table_name: str, schema: str = 'dwh', 
                       if_exists: str = 'append', chunksize: int = 10000):
        """Insérer un DataFrame dans une table"""
        try:
            engine = self.db.get_engine()
            df.to_sql(
                name=table_name,
                con=engine,
                schema=schema,
                if_exists=if_exists,
                index=False,
                chunksize=chunksize,
                method='multi'
            )
            logger.info(f"✓ {len(df)} lignes insérées dans {schema}.{table_name}")
            return True
        except Exception as e:
            logger.error(f"✗ Erreur lors de l'insertion: {e}")
            return False
    
    def truncate_table(self, table_name: str, schema: str = 'dwh'):
        """Vider une table"""
        query = f"TRUNCATE TABLE {schema}.{table_name} CASCADE"
        try:
            self.db.execute_query(query)
            logger.info(f"✓ Table {schema}.{table_name} vidée")
        except Exception as e:
            logger.error(f"✗ Erreur lors du vidage: {e}")
    
    def load_dimension_scd2(self, df, table_name: str, natural_key: str,
                           schema: str = 'dwh'):
        """
        Charger une dimension avec gestion SCD Type 2
        (Slowly Changing Dimension)
        """
        # Cette fonction sera implémentée pour gérer les changements historiques
        # dans les dimensions (ex: changement de segment client)
        pass


# Instance globale
db_connection = DatabaseConnection()
data_loader = DataLoader()


if __name__ == "__main__":
    # Test de connexion
    logging.basicConfig(level=logging.INFO)
    
    db = DatabaseConnection()
    
    # Test connexion
    if db.test_connection():
        print("\n✓ Connexion réussie!")
        
        # Afficher les tables
        print("\nTables dans le schéma DWH:")
        tables = db.get_table_info('dwh')
        for table in tables:
            print(f"  - {table['table_name']}: {table['size']}")
        
        # Compter les lignes
        print("\nNombre de lignes:")
        for table in tables:
            count = db.get_row_count(table['table_name'])
            print(f"  - {table['table_name']}: {count:,} lignes")
    else:
        print("\n✗ Échec de connexion!")
