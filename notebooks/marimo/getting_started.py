import marimo

__generated_with = "0.19.7"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md("""
    # B2B Mobile Money Data Warehouse

    Bienvenue dans l'interface Marimo pour l'analyse du Data Warehouse.

    ## Connexion à la base de données
    """)
    return


@app.cell
def _():
    import pandas as pd
    from sqlalchemy import create_engine
    import os

    # Connexion à PostgreSQL
    DATABASE_URL = os.environ.get(
        "DATABASE_URL",
        "postgresql://dwh_admin:dwh_secure_password@postgres-dwh:5432/b2b_mobile_money_dwh"
    )
    engine = create_engine(DATABASE_URL)
    return engine, pd


@app.cell
def _(mo):
    mo.md("""
    ## Aperçu de la dimension Date
    """)
    return


@app.cell
def _(engine, pd):
    # Charger les données de la dimension date
    df_dates = pd.read_sql(
        "SELECT * FROM dwh.dim_date ORDER BY full_date LIMIT 100",
        engine
    )
    df_dates
    return


@app.cell
def _(mo):
    mo.md("""
    ## Statistiques des tables
    """)
    return


@app.cell
def _(engine, pd):
    # Compter les enregistrements par table
    tables_stats = pd.read_sql("""
        SELECT
            'dim_date' as table_name, COUNT(*) as row_count FROM dwh.dim_date
        UNION ALL
        SELECT
            'dim_time', COUNT(*) FROM dwh.dim_time
        UNION ALL
        SELECT
            'dim_client', COUNT(*) FROM dwh.dim_client
        UNION ALL
        SELECT
            'dim_service', COUNT(*) FROM dwh.dim_service
        UNION ALL
        SELECT
            'fact_transactions', COUNT(*) FROM dwh.fact_transactions
    """, engine)
    tables_stats
    return


if __name__ == "__main__":
    app.run()
