-- Création de la base de données pour Metabase
CREATE DATABASE metabase;

-- Accorder les permissions à l'utilisateur dwh_admin sur la base metabase
GRANT ALL PRIVILEGES ON DATABASE metabase TO dwh_admin;
