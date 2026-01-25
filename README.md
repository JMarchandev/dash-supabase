# Dash Supabase

Backend Supabase pour l'application Dash - Dashboard de productivité personnalisable.

## 🚀 Stack Technique

- **Supabase** - Backend as a Service
- **PostgreSQL** - Base de données
- **Row Level Security (RLS)** - Sécurité des données
- **Docker** - Développement local

## 📦 Structure

```
supabase/
├── config.toml           # Configuration Supabase
├── migrations/           # Migrations SQL
├── templates/           # Templates d'emails
└── types/               # Types TypeScript générés
```

## 🛠️ Développement Local

### Prérequis
- Docker Desktop
- Supabase CLI

### Installation

```bash
# Installer Supabase CLI
brew install supabase/tap/supabase

# Démarrer Supabase
supabase start

# Appliquer les migrations
supabase migration up

# Générer les types
supabase gen types typescript --local > types/database.types.ts
```

### Services disponibles

- **API**: http://127.0.0.1:54321
- **Studio**: http://127.0.0.1:54323
- **Inbucket (emails)**: http://127.0.0.1:54324

## 🗃️ Base de Données

### Tables

- **profiles** - Profils utilisateurs (first_name, last_name, avatar_url)
- **widget_layouts** - Disposition des widgets par utilisateur
- **user_credentials** - Tokens OAuth chiffrés (Gmail, Spotify, GitHub, etc.)

### RLS Policies

Toutes les tables sont protégées par RLS :
- Les utilisateurs ne peuvent accéder qu'à leurs propres données
- Lecture/écriture/mise à jour/suppression sécurisées

## 📧 Templates d'Emails

Templates personnalisés en français :
- Confirmation d'inscription
- Réinitialisation de mot de passe
- Lien magique de connexion
- Invitation

## 🔒 Sécurité

- Tokens OAuth chiffrés avec AES-256-GCM
- RLS activé sur toutes les tables
- OTP valide pendant 24h
- Refresh tokens avec rotation

## 🔄 Migrations

```bash
# Créer une nouvelle migration
supabase migration new nom_de_la_migration

# Appliquer les migrations
supabase migration up

# Reset (⚠️ supprime les données)
supabase db reset
```

## 📝 Générer les Types

```bash
# Générer les types TypeScript
supabase gen types typescript --local > types/database.types.ts

# Copier vers le client
cp types/database.types.ts ../client/types/database.types.ts
```

## 🌐 Déploiement

Le déploiement se fait via Supabase CLI :

```bash
# Link au projet
supabase link --project-ref <project-ref>

# Push migrations
supabase db push

# Push fonctions (si nécessaire)
supabase functions deploy
```
