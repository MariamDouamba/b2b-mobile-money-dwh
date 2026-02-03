FROM python:3.11-slim

WORKDIR /app

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Installation des packages Python
RUN pip install --no-cache-dir \
    marimo \
    pandas \
    numpy \
    sqlalchemy \
    psycopg2-binary \
    plotly \
    altair \
    matplotlib \
    seaborn \
    scikit-learn

# Créer le répertoire pour les notebooks
RUN mkdir -p /app/notebooks

EXPOSE 2718

# Lancer Marimo en mode edit sans authentification
CMD ["marimo", "edit", "--host", "0.0.0.0", "--port", "2718", "--headless", "--no-token", "/app/notebooks"]
