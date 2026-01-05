-- ============================================================================
-- SCHÉMA COMPLET DE LA BASE DE DONNÉES SUPABASE POUR DANSMONSAC
-- ============================================================================
-- Ce fichier contient tous les scripts SQL nécessaires pour créer la base
-- de données complète de l'application DansMonSac.
--
-- Exécutez ces scripts dans l'ordre dans le SQL Editor de Supabase.
-- ============================================================================

-- ============================================================================
-- SECTION 1 : CRÉATION DES TABLES
-- ============================================================================

-- Table: courses
-- Description: Stocke les cours (Mathématiques, Français, etc.)
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_courses_created_at ON courses(created_at);

-- Table: supplies
-- Description: Stocke les fournitures (Cahier, Stylo, Classeur, etc.)
CREATE TABLE supplies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_supplies_name ON supplies(name);

-- Table: course_supplies
-- Description: Table de liaison many-to-many entre courses et supplies
CREATE TABLE course_supplies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  supply_id UUID NOT NULL REFERENCES supplies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Contrainte d'unicité pour éviter les doublons
  UNIQUE(course_id, supply_id)
);

CREATE INDEX idx_course_supplies_course_id ON course_supplies(course_id);
CREATE INDEX idx_course_supplies_supply_id ON course_supplies(supply_id);

-- Table: courses_user
-- Description: Association entre les cours et les utilisateurs/appareils
CREATE TABLE courses_user (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Contrainte d'unicité : un utilisateur ne peut pas avoir le même cours deux fois
  UNIQUE(device_id, course_id)
);

CREATE INDEX idx_courses_user_device_id ON courses_user(device_id);
CREATE INDEX idx_courses_user_course_id ON courses_user(course_id);

-- Table: calendar_courses
-- Description: Stocke les cours planifiés dans le calendrier avec leurs horaires et salles
CREATE TABLE calendar_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  room_name TEXT NOT NULL,
  start_time_hour INTEGER NOT NULL CHECK (start_time_hour >= 0 AND start_time_hour <= 23),
  start_time_minute INTEGER NOT NULL CHECK (start_time_minute >= 0 AND start_time_minute <= 59),
  end_time_hour INTEGER NOT NULL CHECK (end_time_hour >= 0 AND end_time_hour <= 23),
  end_time_minute INTEGER NOT NULL CHECK (end_time_minute >= 0 AND end_time_minute <= 59),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_calendar_courses_device_id ON calendar_courses(device_id);
CREATE INDEX idx_calendar_courses_course_id ON calendar_courses(course_id);

-- Table: users_preferences
-- Description: Stocke les préférences utilisateur (heure de préparation du sac, etc.)
CREATE TABLE users_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL,
  hour INTEGER NOT NULL CHECK (hour >= 0 AND hour <= 23),
  minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 59),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_preferences_device_id ON users_preferences(device_id);

-- ============================================================================
-- SECTION 2 : TRIGGERS ET FONCTIONS
-- ============================================================================

-- Fonction: update_updated_at_column
-- Description: Met à jour automatiquement le champ updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Mise à jour automatique de updated_at pour users_preferences
CREATE TRIGGER update_users_preferences_updated_at
  BEFORE UPDATE ON users_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SECTION 3 : CONFIGURATION RLS (Row Level Security)
-- ============================================================================
--
-- CHOISISSEZ L'UNE DES DEUX OPTIONS CI-DESSOUS :
--
-- Option A : MODE DÉVELOPPEMENT (désactiver RLS)
-- Option B : MODE PRODUCTION (activer RLS avec politiques)
--
-- ============================================================================

-- ----------------------------------------------------------------------------
-- OPTION A : MODE DÉVELOPPEMENT - DÉSACTIVER RLS
-- ----------------------------------------------------------------------------
-- ⚠️ ATTENTION : Cette option est NON SÉCURISÉE !
-- À utiliser UNIQUEMENT pour le développement local.
-- NE PAS utiliser en production !
-- ----------------------------------------------------------------------------

-- Décommenter les lignes suivantes pour désactiver RLS :

-- ALTER TABLE courses DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE supplies DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE course_supplies DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE courses_user DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE calendar_courses DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE users_preferences DISABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- OPTION B : MODE PRODUCTION - ACTIVER RLS AVEC POLITIQUES
-- ----------------------------------------------------------------------------
-- Cette option est SÉCURISÉE et recommandée pour la production.
-- Décommenter les lignes suivantes pour activer RLS :
-- ----------------------------------------------------------------------------

-- Activer RLS sur toutes les tables
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_preferences ENABLE ROW LEVEL SECURITY;

-- Politiques pour la table courses
CREATE POLICY "Lecture publique des cours"
  ON courses FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique de cours"
  ON courses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Suppression publique de cours"
  ON courses FOR DELETE
  USING (true);

-- Politiques pour la table supplies
CREATE POLICY "Lecture publique des fournitures"
  ON supplies FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique de fournitures"
  ON supplies FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Suppression publique de fournitures"
  ON supplies FOR DELETE
  USING (true);

-- Politiques pour la table course_supplies
CREATE POLICY "Lecture publique des liaisons cours-fournitures"
  ON course_supplies FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique de liaisons"
  ON course_supplies FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Suppression publique de liaisons"
  ON course_supplies FOR DELETE
  USING (true);

-- Politiques pour la table courses_user
CREATE POLICY "Lecture publique de courses_user"
  ON courses_user FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique dans courses_user"
  ON courses_user FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Suppression publique de courses_user"
  ON courses_user FOR DELETE
  USING (true);

-- Politiques pour la table calendar_courses
CREATE POLICY "Lecture publique du calendrier"
  ON calendar_courses FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique dans le calendrier"
  ON calendar_courses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Suppression publique du calendrier"
  ON calendar_courses FOR DELETE
  USING (true);

-- Politiques pour la table users_preferences
CREATE POLICY "Lecture publique des préférences"
  ON users_preferences FOR SELECT
  USING (true);

CREATE POLICY "Insertion publique de préférences"
  ON users_preferences FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Mise à jour publique des préférences"
  ON users_preferences FOR UPDATE
  USING (true);

-- ============================================================================
-- SECTION 4 : DONNÉES DE TEST (OPTIONNEL)
-- ============================================================================
-- Décommenter cette section pour insérer des données de test
-- ============================================================================

-- Insertion de cours de test
-- INSERT INTO courses (course_name) VALUES
--   ('Mathématiques'),
--   ('Français'),
--   ('Histoire-Géographie'),
--   ('Anglais'),
--   ('Physique-Chimie');

-- Insertion de fournitures de test
-- INSERT INTO supplies (name) VALUES
--   ('Cahier'),
--   ('Classeur'),
--   ('Stylo bleu'),
--   ('Stylo rouge'),
--   ('Calculatrice'),
--   ('Règle'),
--   ('Compas'),
--   ('Équerre');

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================
-- La base de données est maintenant configurée et prête à l'emploi !
--
-- Prochaines étapes :
-- 1. Vérifiez que toutes les tables sont créées dans le Table Editor
-- 2. Mettez à jour les identifiants Supabase dans votre application Flutter
-- 3. Testez la connexion avec flutter run
-- ============================================================================
