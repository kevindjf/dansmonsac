# Supabase Setup - DansMonSac

## Tables requises

### Epic 2 : Daily Bag Preparation with Streak

| Table | Sync | Description |
|-------|------|-------------|
| `bag_completions` | ✅ OUI | Track when students complete bag prep (required for parent visibility) |
| `daily_checks` | ❌ NON | Local-only - checklist state per day |

### Epic 5 : Parent-Child Linking (Future)

| Table | Sync | Description |
|-------|------|-------------|
| `parent_links` | ✅ OUI | Anonymous pairing codes for parent linking |

## Comment appliquer les migrations

### Option 1 : Via Supabase Dashboard (Recommandé)

1. Connectez-vous à [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet **DansMonSac**
3. Allez dans **SQL Editor** (menu de gauche)
4. Cliquez sur **+ New Query**
5. Copiez-collez le contenu de `supabase_migrations.sql`
6. Cliquez sur **Run** (▶️)
7. Vérifiez que les tables sont créées dans **Table Editor**

### Option 2 : Via Supabase CLI

```bash
# Si vous utilisez Supabase CLI localement
supabase db push
```

### Option 3 : Via script SQL direct

```bash
# Connectez-vous à votre base PostgreSQL Supabase
psql "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"

# Exécutez le fichier
\i supabase_migrations.sql
```

## Vérification

Après avoir appliqué les migrations, vérifiez que tout fonctionne :

### 1. Vérifier que les tables existent

Dans Supabase Dashboard → **Table Editor** :
- ✅ `bag_completions` doit apparaître
- ✅ Colonnes : `id`, `date`, `completed_at`, `device_id`, `created_at`

### 2. Tester l'insertion

Dans **SQL Editor**, exécutez :

```sql
-- Test insert
INSERT INTO public.bag_completions (id, date, device_id)
VALUES ('test-' || gen_random_uuid()::text, NOW(), 'test-device')
RETURNING *;

-- Vérifier
SELECT * FROM public.bag_completions LIMIT 5;

-- Nettoyer le test
DELETE FROM public.bag_completions WHERE device_id = 'test-device';
```

### 3. Tester depuis l'app Flutter

1. Relancez l'app
2. Complétez votre sac (cochez toutes les fournitures)
3. Attendez quelques secondes (sync automatique)
4. Vérifiez dans Supabase Dashboard → **Table Editor** → `bag_completions`
5. Vous devriez voir une nouvelle ligne avec votre `device_id`

## Troubleshooting

### Erreur "relation already exists"
➡️ Normal si la table existe déjà. La migration utilise `IF NOT EXISTS`.

### Erreur de permissions RLS
➡️ Les politiques RLS sont configurées pour permettre l'accès anonyme (device_id-based).
➡️ Vérifiez que RLS est activé : **Authentication** → **Policies** → `bag_completions`

### L'app ne sync pas
1. Vérifiez que l'app a accès réseau
2. Vérifiez les logs : `LogService` devrait afficher `✅ BagCompletion synced`
3. Vérifiez le fichier `.env` : `SUPABASE_URL` et `SUPABASE_ANON_KEY` corrects

## Architecture Notes

### Pourquoi DailyChecks est local-only ?

**DailyChecks** contient l'état des checkboxes minute par minute :
- Génère beaucoup de trafic réseau (chaque check/uncheck)
- Pas nécessaire côté serveur (seul le résultat final compte)
- **BagCompletions** capture le résultat final (bag terminé)

### Pourquoi BagCompletions est syncé ?

- Nécessaire pour Epic 5 (parent peut voir si l'enfant a préparé son sac)
- Données légères (1 ligne par jour de bag complété)
- Historique de streak partageable

## Next Steps

Une fois les migrations appliquées :

1. ✅ Story 2.5 (Streak Counter UI) - Fonctionne
2. ✅ Story 2.6 (Bag Ready Confirmation) - Fonctionne
3. ✅ Sync vers Supabase - Fonctionne
4. 🔮 Epic 5 (Parent Linking) - Table `parent_links` (commentée, à décommenter plus tard)
