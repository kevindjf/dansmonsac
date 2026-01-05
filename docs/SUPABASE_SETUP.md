# Configuration Supabase pour DansMonSac

Ce document contient toutes les informations nécessaires pour recréer votre projet Supabase.

## 🔧 Étape 1 : Créer un nouveau projet Supabase

1. Allez sur https://supabase.com
2. Connectez-vous ou créez un compte
3. Cliquez sur "New Project"
4. Choisissez un nom pour votre projet
5. Créez un mot de passe pour la base de données (gardez-le en sécurité !)
6. Sélectionnez une région proche de vous
7. Cliquez sur "Create new project"
8. Attendez quelques minutes que le projet soit créé

## 📊 Étape 2 : Créer les tables

Allez dans **SQL Editor** dans le menu de gauche de Supabase, puis copiez-collez et exécutez les scripts SQL suivants dans l'ordre :

### 1️⃣ Table `courses`
Stocke les cours (Mathématiques, Français, etc.)

```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_courses_created_at ON courses(created_at);
```

### 2️⃣ Table `supplies`
Stocke les fournitures (Cahier, Stylo, etc.)

```sql
CREATE TABLE supplies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_supplies_name ON supplies(name);
```

### 3️⃣ Table `course_supplies`
Table de liaison entre les cours et les fournitures (relation many-to-many)

```sql
CREATE TABLE course_supplies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  supply_id UUID NOT NULL REFERENCES supplies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Éviter les doublons
  UNIQUE(course_id, supply_id)
);

-- Index pour améliorer les performances des jointures
CREATE INDEX idx_course_supplies_course_id ON course_supplies(course_id);
CREATE INDEX idx_course_supplies_supply_id ON course_supplies(supply_id);
```

### 4️⃣ Table `courses_user`
Association entre les cours et les utilisateurs/appareils

```sql
CREATE TABLE courses_user (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Éviter les doublons
  UNIQUE(device_id, course_id)
);

-- Index pour améliorer les performances des requêtes par device_id
CREATE INDEX idx_courses_user_device_id ON courses_user(device_id);
CREATE INDEX idx_courses_user_course_id ON courses_user(course_id);
```

### 5️⃣ Table `calendar_courses`
Stocke les cours planifiés dans le calendrier avec leurs horaires

```sql
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

-- Index pour améliorer les performances
CREATE INDEX idx_calendar_courses_device_id ON calendar_courses(device_id);
CREATE INDEX idx_calendar_courses_course_id ON calendar_courses(course_id);
```

### 6️⃣ Table `users_preferences`
Stocke les préférences utilisateur (heure de préparation du sac, etc.)

```sql
CREATE TABLE users_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL,
  hour INTEGER NOT NULL CHECK (hour >= 0 AND hour <= 23),
  minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 59),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_users_preferences_device_id ON users_preferences(device_id);

-- Trigger pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_preferences_updated_at
  BEFORE UPDATE ON users_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## 🔒 Étape 3 : Configuration des politiques RLS (Row Level Security)

### Option A : Mode Développement (RAPIDE mais NON SÉCURISÉ)

**⚠️ ATTENTION : Utilisez ceci uniquement pour le développement local !**

```sql
-- Désactiver RLS sur toutes les tables
ALTER TABLE courses DISABLE ROW LEVEL SECURITY;
ALTER TABLE supplies DISABLE ROW LEVEL SECURITY;
ALTER TABLE course_supplies DISABLE ROW LEVEL SECURITY;
ALTER TABLE courses_user DISABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_courses DISABLE ROW LEVEL SECURITY;
ALTER TABLE users_preferences DISABLE ROW LEVEL SECURITY;
```

### Option B : Mode Production (SÉCURISÉ - Recommandé)

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_preferences ENABLE ROW LEVEL SECURITY;

-- Politiques pour courses
CREATE POLICY "Tout le monde peut lire les cours" ON courses FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut créer des cours" ON courses FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut supprimer des cours" ON courses FOR DELETE USING (true);

-- Politiques pour supplies
CREATE POLICY "Tout le monde peut lire les fournitures" ON supplies FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut créer des fournitures" ON supplies FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut supprimer des fournitures" ON supplies FOR DELETE USING (true);

-- Politiques pour course_supplies
CREATE POLICY "Tout le monde peut lire les liaisons" ON course_supplies FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut créer des liaisons" ON course_supplies FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut supprimer des liaisons" ON course_supplies FOR DELETE USING (true);

-- Politiques pour courses_user
CREATE POLICY "Tout le monde peut lire courses_user" ON courses_user FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut créer courses_user" ON courses_user FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut supprimer courses_user" ON courses_user FOR DELETE USING (true);

-- Politiques pour calendar_courses
CREATE POLICY "Tout le monde peut lire le calendrier" ON calendar_courses FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut ajouter au calendrier" ON calendar_courses FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut supprimer du calendrier" ON calendar_courses FOR DELETE USING (true);

-- Politiques pour users_preferences
CREATE POLICY "Tout le monde peut lire les préférences" ON users_preferences FOR SELECT USING (true);
CREATE POLICY "Tout le monde peut créer des préférences" ON users_preferences FOR INSERT WITH CHECK (true);
CREATE POLICY "Tout le monde peut modifier les préférences" ON users_preferences FOR UPDATE USING (true);
```

## 📱 Étape 4 : Configuration de l'application Flutter

### 1. Récupérer vos identifiants Supabase

Dans votre projet Supabase :
1. Allez dans **Settings** (icône engrenage en bas à gauche)
2. Cliquez sur **API**
3. Copiez ces deux valeurs :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon public key** : commence par `eyJ...`

### 2. Mettre à jour le code Flutter

Ouvrez le fichier : `features/common/lib/src/repository/repository_helper.dart`

Remplacez les lignes 9 et 11 avec vos nouvelles valeurs :

```dart
await Supabase.initialize(
  url: "VOTRE_PROJECT_URL_ICI",  // ← Collez votre Project URL ici
  anonKey: "VOTRE_ANON_KEY_ICI", // ← Collez votre anon public key ici
);
```

**Exemple :**
```dart
await Supabase.initialize(
  url: "https://abcdefghijklmnop.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTcwMDAwMDAwMCwiZXhwIjoyMDE1NTc2MDAwfQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
);
```

## ✅ Étape 5 : Vérification

1. Assurez-vous que toutes les tables sont créées :
   - Dans Supabase, allez dans **Table Editor**
   - Vous devriez voir 6 tables : `courses`, `supplies`, `course_supplies`, `courses_user`, `calendar_courses`, `users_preferences`

2. Testez l'application :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 📋 Structure de la base de données

### Diagramme des relations

```
users_preferences
  ├─ device_id (unique)
  └─ hour, minute

courses_user
  ├─ device_id
  └─ course_id → courses.id

courses
  └─ id, course_name

course_supplies (many-to-many)
  ├─ course_id → courses.id
  └─ supply_id → supplies.id

supplies
  └─ id, name

calendar_courses
  ├─ device_id
  ├─ course_id → courses.id
  └─ room_name, start_time, end_time
```

### Description des tables

| Table | Description | Clés étrangères |
|-------|-------------|-----------------|
| `courses` | Liste des cours (Math, Français, etc.) | - |
| `supplies` | Liste des fournitures (Cahier, Stylo, etc.) | - |
| `course_supplies` | Associe les fournitures aux cours | `course_id`, `supply_id` |
| `courses_user` | Associe les cours aux utilisateurs | `course_id` |
| `calendar_courses` | Cours planifiés avec horaires | `course_id` |
| `users_preferences` | Préférences utilisateur (heure de préparation) | - |

## 🔍 Requêtes utiles pour déboguer

### Voir tous les cours d'un utilisateur
```sql
SELECT c.course_name, s.name as supply_name
FROM courses_user cu
JOIN courses c ON c.id = cu.course_id
LEFT JOIN course_supplies cs ON cs.course_id = c.id
LEFT JOIN supplies s ON s.id = cs.supply_id
WHERE cu.device_id = 'VOTRE_DEVICE_ID';
```

### Voir le calendrier d'un utilisateur
```sql
SELECT c.course_name, cc.room_name, cc.start_time_hour, cc.start_time_minute
FROM calendar_courses cc
JOIN courses c ON c.id = cc.course_id
WHERE cc.device_id = 'VOTRE_DEVICE_ID'
ORDER BY cc.start_time_hour, cc.start_time_minute;
```

### Compter le nombre d'éléments
```sql
SELECT
  (SELECT COUNT(*) FROM courses) as nb_courses,
  (SELECT COUNT(*) FROM supplies) as nb_supplies,
  (SELECT COUNT(*) FROM calendar_courses) as nb_calendar;
```

## 🆘 Problèmes courants

### Erreur : "relation does not exist"
→ Les tables n'ont pas été créées. Retournez à l'étape 2.

### Erreur : "new row violates row-level security policy"
→ Les politiques RLS bloquent les requêtes. Utilisez l'Option A (désactiver RLS) pour le développement.

### Erreur : "Failed host lookup"
→ Vérifiez que vous avez bien mis à jour les identifiants dans `repository_helper.dart` et que la permission INTERNET est dans `AndroidManifest.xml`.

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez que toutes les tables sont bien créées dans Supabase
2. Vérifiez que les identifiants sont corrects dans le code
3. Consultez les logs de Supabase : **Logs** → **Postgres Logs**
