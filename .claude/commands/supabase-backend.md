---
name: supabase-backend
description: Backend Supabase complet - auth, realtime, edge functions, storage, data layer. Utiliser quand on implémente de l'auth, du realtime, des edge functions, du storage, ou la couche data.
target: clement
stack: supabase
keywords: auth, realtime, edge function, storage, bucket, channel, presence, broadcast, sign up, login, token, webhook
---

Implémente le backend Supabase en respectant ces règles :

## Auth
- Toujours `supabase.auth` — jamais de système auth custom
- Sign up : email/password ou OAuth (Google, Apple). Stocker le profil dans une table `profiles`
- Trigger `on_auth_user_created` pour créer le profil automatiquement
- Token refresh géré par le SDK, ne pas le faire manuellement
- Protéger les routes sensibles avec RLS basé sur `auth.uid()`

## Realtime
- `supabase.channel()` pour écouter les changements (INSERT, UPDATE, DELETE)
- Présence : `channel.track()` pour les utilisateurs en ligne
- Broadcast : `channel.send()` pour les events custom (typing, notifications)
- TOUJOURS `channel.unsubscribe()` dans dispose() côté Flutter
- Filtrer côté serveur (RLS) pas côté client — ne jamais écouter toute la table

## RLS avancé
- Policy par rôle : `auth.jwt() ->> 'role'` pour admin/user/moderator
- Policy multi-tenant : `organization_id = (SELECT org_id FROM members WHERE user_id = auth.uid())`
- JAMAIS de `USING (true)` sur INSERT/UPDATE/DELETE — toujours restreindre
- Tester les policies avec `SET ROLE authenticated; SET request.jwt.claims = '...'`

## Edge Functions
- Deno/TypeScript, déployées via `supabase functions deploy`
- Pour la logique serveur (webhooks, paiements, envoi d'emails, tâches CRON)
- Toujours valider les inputs avec Zod ou validation manuelle
- Retourner des codes HTTP appropriés (200, 400, 401, 500)
- Variables d'env via `Deno.env.get()`, secrets via dashboard

## Storage
- Buckets : `public/` (avatars, images) vs `private/` (documents)
- RLS sur les buckets : policy basée sur `auth.uid()` et le path du fichier
- Nommage : `{user_id}/{uuid}.{ext}` — éviter les noms prévisibles
- Limiter la taille : policy `(octet_length(content) < 5242880)` pour 5MB max
- Signed URLs pour les fichiers privés, public URLs pour les assets publics

## Data Layer Flutter
- Repository pattern : `XxxRepository` encapsule tous les appels Supabase
- Le provider appelle le repository, JAMAIS Supabase directement
- Pagination : `.range(from, to)` avec infinite scroll
- Cache local : stocker en SharedPreferences/Hive pour offline-first si pertinent
- Gestion d'erreurs : catch `PostgrestException`, `AuthException`, `StorageException` séparément
