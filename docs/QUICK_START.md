# 🚀 Guide Rapide de Configuration Supabase

## ⚡ Configuration en 5 minutes

### Étape 1 : Créer le projet Supabase (2 min)

1. Allez sur https://supabase.com et connectez-vous
2. Cliquez sur **"New Project"**
3. Remplissez :
   - **Name** : DansMonSac (ou autre)
   - **Database Password** : créez un mot de passe fort
   - **Region** : choisissez la plus proche (ex: West EU - Paris)
4. Cliquez sur **"Create new project"**
5. ⏱️ Attendez 2-3 minutes que le projet soit créé

### Étape 2 : Créer les tables (1 min)

1. Dans Supabase, cliquez sur **SQL Editor** (icône dans le menu gauche)
2. Cliquez sur **"New query"**
3. Ouvrez le fichier `docs/supabase_schema.sql` de ce projet
4. **Copiez tout le contenu** et collez-le dans l'éditeur SQL
5. Cliquez sur **"Run"** (ou Ctrl+Enter)
6. ✅ Vérifiez qu'il n'y a pas d'erreurs

### Étape 3 : Récupérer les identifiants (30 sec)

1. Dans Supabase, cliquez sur **Settings** (icône engrenage en bas à gauche)
2. Cliquez sur **API**
3. Copiez ces deux valeurs :
   - **Project URL** (exemple : `https://xxxxx.supabase.co`)
   - **anon public** key (commence par `eyJ...`)

### Étape 4 : Configurer l'application Flutter (1 min)

1. Ouvrez le fichier : `features/common/lib/src/repository/repository_helper.dart`
2. Remplacez les lignes 9 et 11 avec vos valeurs :

```dart
await Supabase.initialize(
  url: "COLLEZ_VOTRE_PROJECT_URL_ICI",     // Ligne 9
  anonKey: "COLLEZ_VOTRE_ANON_KEY_ICI",    // Ligne 11
);
```

3. Sauvegardez le fichier

### Étape 5 : Lancer l'application (30 sec)

```bash
flutter clean
flutter pub get
flutter run
```

## ✅ C'est tout !

Votre application est maintenant connectée à Supabase et prête à l'emploi.

---

## 🔍 Vérification

Pour vérifier que tout fonctionne :

1. Dans Supabase, allez dans **Table Editor**
2. Vous devriez voir 6 tables :
   - ✓ courses
   - ✓ supplies
   - ✓ course_supplies
   - ✓ courses_user
   - ✓ calendar_courses
   - ✓ users_preferences

3. Lancez l'application et créez un cours
4. Retournez dans Supabase → **Table Editor** → **courses**
5. Vous devriez voir votre cours apparaître !

---

## 🆘 Problème ?

### L'app ne se connecte pas à Supabase

**Solution :** Vérifiez que :
- ✓ Vous avez bien copié l'URL et la clé anon
- ✓ Il n'y a pas d'espaces avant ou après
- ✓ L'URL commence par `https://`
- ✓ La clé commence par `eyJ`

### Erreur "Row level security policy"

**Solution :** Dans Supabase SQL Editor, exécutez :

```sql
ALTER TABLE courses DISABLE ROW LEVEL SECURITY;
ALTER TABLE supplies DISABLE ROW LEVEL SECURITY;
ALTER TABLE course_supplies DISABLE ROW LEVEL SECURITY;
ALTER TABLE courses_user DISABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_courses DISABLE ROW LEVEL SECURITY;
ALTER TABLE users_preferences DISABLE ROW LEVEL SECURITY;
```

### Erreur "Failed host lookup"

**Solution :** Vérifiez que `AndroidManifest.xml` contient :

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📚 Documentation complète

Pour plus de détails, consultez `docs/SUPABASE_SETUP.md`
