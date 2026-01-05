-- ============================================================================
-- MISE À JOUR DU SCHÉMA POUR SUPPORTER LES SEMAINES A/B
-- ============================================================================
-- Ce fichier contient les migrations pour ajouter le support des semaines A/B

-- ============================================================================
-- ÉTAPE 1 : Modification de la table calendar_courses
-- ============================================================================

-- Ajouter la colonne pour le type de semaine (A, B, ou les deux)
ALTER TABLE calendar_courses
ADD COLUMN week_type TEXT NOT NULL DEFAULT 'BOTH'
CHECK (week_type IN ('A', 'B', 'BOTH'));

-- Ajouter la colonne pour le jour de la semaine (1=Lundi, 7=Dimanche)
ALTER TABLE calendar_courses
ADD COLUMN day_of_week INTEGER NOT NULL DEFAULT 1
CHECK (day_of_week >= 1 AND day_of_week <= 7);

-- Créer un index pour améliorer les performances des requêtes par jour et semaine
CREATE INDEX idx_calendar_courses_day_week ON calendar_courses(day_of_week, week_type);

-- ============================================================================
-- ÉTAPE 2 : Modification de la table users_preferences
-- ============================================================================

-- Ajouter la date de début de l'année scolaire (première semaine A)
ALTER TABLE users_preferences
ADD COLUMN school_year_start_date DATE NOT NULL DEFAULT CURRENT_DATE;

-- ============================================================================
-- ÉTAPE 3 : Fonction utilitaire pour calculer la semaine A ou B
-- ============================================================================

-- Cette fonction calcule si une date donnée est en semaine A ou B
-- basée sur la date de début de l'année scolaire
CREATE OR REPLACE FUNCTION get_current_week_type(
  start_date DATE,
  check_date DATE DEFAULT CURRENT_DATE
) RETURNS TEXT AS $$
DECLARE
  weeks_diff INTEGER;
BEGIN
  -- Calculer le nombre de semaines écoulées depuis le début de l'année scolaire
  weeks_diff := FLOOR(EXTRACT(DAYS FROM (check_date - start_date)) / 7);

  -- Si le nombre de semaines est pair, c'est semaine A, sinon semaine B
  IF weeks_diff % 2 = 0 THEN
    RETURN 'A';
  ELSE
    RETURN 'B';
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- ÉTAPE 4 : Vue pour simplifier les requêtes de cours
-- ============================================================================

-- Cette vue facilite la récupération des cours avec toutes les informations nécessaires
CREATE OR REPLACE VIEW v_calendar_courses_detailed AS
SELECT
  cc.id,
  cc.device_id,
  cc.course_id,
  cc.room_name,
  cc.start_time_hour,
  cc.start_time_minute,
  cc.end_time_hour,
  cc.end_time_minute,
  cc.week_type,
  cc.day_of_week,
  c.course_name,
  cc.created_at
FROM calendar_courses cc
JOIN courses c ON c.id = cc.course_id;

-- ============================================================================
-- FONCTION UTILITAIRE : Récupérer les cours d'un jour spécifique
-- ============================================================================

-- Cette fonction retourne les cours pour un jour donné en tenant compte de la semaine A/B
CREATE OR REPLACE FUNCTION get_courses_for_date(
  p_device_id TEXT,
  p_date DATE,
  p_school_year_start DATE
) RETURNS TABLE (
  id UUID,
  course_name TEXT,
  room_name TEXT,
  start_time_hour INTEGER,
  start_time_minute INTEGER,
  end_time_hour INTEGER,
  end_time_minute INTEGER,
  week_type TEXT
) AS $$
DECLARE
  v_day_of_week INTEGER;
  v_current_week_type TEXT;
BEGIN
  -- Calculer le jour de la semaine (1=Lundi, 7=Dimanche)
  v_day_of_week := EXTRACT(ISODOW FROM p_date);

  -- Calculer la semaine actuelle (A ou B)
  v_current_week_type := get_current_week_type(p_school_year_start, p_date);

  -- Retourner les cours correspondants
  RETURN QUERY
  SELECT
    v.id,
    v.course_name,
    v.room_name,
    v.start_time_hour,
    v.start_time_minute,
    v.end_time_hour,
    v.end_time_minute,
    v.week_type
  FROM v_calendar_courses_detailed v
  WHERE v.device_id = p_device_id
    AND v.day_of_week = v_day_of_week
    AND (v.week_type = 'BOTH' OR v.week_type = v_current_week_type)
  ORDER BY v.start_time_hour, v.start_time_minute;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FONCTION UTILITAIRE : Récupérer les fournitures pour le lendemain
-- ============================================================================

-- Cette fonction retourne toutes les fournitures nécessaires pour le lendemain
CREATE OR REPLACE FUNCTION get_supplies_for_tomorrow(
  p_device_id TEXT,
  p_school_year_start DATE
) RETURNS TABLE (
  supply_id UUID,
  supply_name TEXT,
  course_name TEXT
) AS $$
DECLARE
  v_tomorrow DATE;
BEGIN
  v_tomorrow := CURRENT_DATE + INTERVAL '1 day';

  RETURN QUERY
  SELECT DISTINCT
    s.id as supply_id,
    s.name as supply_name,
    c.course_name
  FROM calendar_courses cc
  JOIN courses c ON c.id = cc.course_id
  JOIN course_supplies cs ON cs.course_id = c.id
  JOIN supplies s ON s.id = cs.supply_id
  WHERE cc.device_id = p_device_id
    AND cc.day_of_week = EXTRACT(ISODOW FROM v_tomorrow)
    AND (
      cc.week_type = 'BOTH'
      OR cc.week_type = get_current_week_type(p_school_year_start, v_tomorrow)
    )
  ORDER BY c.course_name, s.name;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- DONNÉES DE TEST (OPTIONNEL)
-- ============================================================================

-- Exemple: Définir le 2 septembre 2024 comme début de l'année scolaire
-- UPDATE users_preferences
-- SET school_year_start_date = '2024-09-02'
-- WHERE device_id = 'VOTRE_DEVICE_ID';

-- Exemple: Ajouter des cours avec semaines A/B
-- INSERT INTO calendar_courses (device_id, course_id, room_name, day_of_week, week_type, start_time_hour, start_time_minute, end_time_hour, end_time_minute)
-- VALUES
--   -- Lundi (1) - Semaine A uniquement
--   ('test-device', (SELECT id FROM courses WHERE course_name = 'Mathématiques' LIMIT 1), 'Salle 101', 1, 'A', 8, 0, 10, 0),
--   -- Lundi (1) - Semaine B uniquement
--   ('test-device', (SELECT id FROM courses WHERE course_name = 'Français' LIMIT 1), 'Salle 102', 1, 'B', 8, 0, 10, 0),
--   -- Mardi (2) - Les deux semaines
--   ('test-device', (SELECT id FROM courses WHERE course_name = 'Anglais' LIMIT 1), 'Salle 201', 2, 'BOTH', 14, 0, 16, 0);

-- ============================================================================
-- TESTS DES FONCTIONS
-- ============================================================================

-- Test: Quelle est la semaine actuelle?
-- SELECT get_current_week_type('2024-09-02', CURRENT_DATE);

-- Test: Cours d'aujourd'hui
-- SELECT * FROM get_courses_for_date('VOTRE_DEVICE_ID', CURRENT_DATE, '2024-09-02');

-- Test: Fournitures pour demain
-- SELECT * FROM get_supplies_for_tomorrow('VOTRE_DEVICE_ID', '2024-09-02');

-- ============================================================================
-- NETTOYAGE (si besoin de recommencer)
-- ============================================================================

-- DROP FUNCTION IF EXISTS get_supplies_for_tomorrow(TEXT, DATE);
-- DROP FUNCTION IF EXISTS get_courses_for_date(TEXT, DATE, DATE);
-- DROP FUNCTION IF EXISTS get_current_week_type(DATE, DATE);
-- DROP VIEW IF EXISTS v_calendar_courses_detailed;
-- ALTER TABLE calendar_courses DROP COLUMN IF EXISTS week_type;
-- ALTER TABLE calendar_courses DROP COLUMN IF EXISTS day_of_week;
-- ALTER TABLE users_preferences DROP COLUMN IF EXISTS school_year_start_date;
