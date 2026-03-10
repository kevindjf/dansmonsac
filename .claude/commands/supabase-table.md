Crée ou modifie une table Supabase en respectant ces règles :

## Avant de coder
1. Vérifier les tables existantes via MCP Supabase (list_tables)
2. Vérifier les colonnes et types existants
3. Ne pas dupliquer une table/colonne qui existe déjà

## Table
- Nommage snake_case pour tables et colonnes
- Toujours `id uuid DEFAULT gen_random_uuid() PRIMARY KEY`
- Toujours `created_at timestamptz DEFAULT now()`
- `updated_at timestamptz` si l'entité est modifiable
- Foreign keys explicites avec ON DELETE CASCADE/SET NULL selon le cas

## RLS (Row Level Security)
- TOUJOURS activer RLS sur les nouvelles tables
- Créer les policies AVANT d'exposer la table
- Policy SELECT : `auth.uid() = user_id`
- Policy INSERT : `auth.uid() = user_id`
- Policy UPDATE/DELETE : même pattern

## Modèle Dart
- snake_case DB → camelCase Dart dans fromJson/toJson
- Classe avec factory fromJson + méthode toJson
- Placer dans `lib/features/<feature>/models/`

## Migration
- Fichier SQL propre et réversible
- Utiliser apply_migration via MCP
