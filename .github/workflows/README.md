# 🚀 GitHub Actions - Déploiement Supabase

## 🔄 Workflows Disponibles

### 1. **CI** (`ci.yml`) - Tests automatiques
- Se déclenche sur **chaque Pull Request**
- Lance Supabase en local avec Docker
- Applique les migrations pour vérifier qu'elles fonctionnent
- Arrête l'environnement local
- ✅ **Aucun secret requis** (tout en local)

### 2. **Deploy Staging** (`deploy-staging.yml`)
- Se déclenche sur push vers la branche `staging`
- Déploie automatiquement sur l'environnement de staging

### 3. **Deploy Production** (`deploy-production.yml`)
- Se déclenche sur push vers la branche `main`
- Nécessite une approbation manuelle avant déploiement

---

## 📋 Configuration des Secrets

Avant de pouvoir utiliser les workflows de déploiement, vous devez configurer les secrets GitHub.

### Étapes :

1. **Aller dans votre repository GitHub**
   - Settings → Secrets and variables → Actions

2. **Ajouter les secrets suivants :**

#### `SUPABASE_ACCESS_TOKEN`
- Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
- Account → Access Tokens
- Créer un nouveau token
- Copier et ajouter comme secret

#### `STAGING_PROJECT_ID`
- Aller sur votre projet Staging dans Supabase
- Settings → General → Reference ID
- Copier l'ID (format: `abcdefghijklmnop`)

#### `STAGING_DB_PASSWORD`
- Aller sur votre projet Staging dans Supabase
- Settings → Database → Database Password
- Utiliser le mot de passe existant ou en générer un nouveau

#### `PRODUCTION_PROJECT_ID`
- Aller sur votre projet Production dans Supabase
- Settings → General → Reference ID
- Copier l'ID

#### `PRODUCTION_DB_PASSWORD`
- Aller sur votre projet Production dans Supabase
- Settings → Database → Database Password
- Utiliser le mot de passe existant

---

## 🔄 Workflow de Développement Complet

### 1. Feature Branch → Pull Request
```bash
git checkout -b feature/nouvelle-fonctionnalite
# ... développement + migrations ...
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite
```
✅ **CI se lance automatiquement** sur la PR
- Teste que les migrations s'appliquent correctement
- Valide la structure de la DB

### 2. Merge vers Staging
```bash
git checkout staging
git merge feature/nouvelle-fonctionnalite
git push origin staging
```
✅ **Déploiement automatique** vers staging
- Applique les migrations sur l'environnement de staging
- Testez l'application sur staging

### 3. Merge vers Production
```bash
git checkout main
git merge staging
git push origin main
```
⚠️ **Déploiement avec approbation manuelle**
- Le workflow se met en pause
- Notification aux reviewers
- Approbation requise
- Déploiement vers production

---

## 🛡️ Protection de la Production

Le workflow `deploy-production.yml` utilise l'environnement `production` qui nécessite :

1. **Configurer l'environnement de protection :**
   - Repository Settings → Environments → New environment
   - Nom : `production`
   - Cocher "Required reviewers"
   - Ajouter les personnes qui peuvent approuver

2. **Lors d'un push sur `main` :**
   - Le workflow se met en pause
   - Les reviewers reçoivent une notification
   - Ils doivent approuver manuellement
   - Le déploiement continue après approbation

---

## 📦 Ce que Font les Workflows

### CI (Tests automatiques)
1. `supabase start` - Lance Supabase localement avec Docker
2. `supabase db push` - Applique les migrations sur l'instance locale
3. `supabase stop` - Arrête l'instance locale

**Avantages :**
- ✅ Détecte les erreurs de migration avant le merge
- ✅ Valide la syntaxe SQL
- ✅ Vérifie que les migrations s'appliquent dans l'ordre
- ✅ Aucun impact sur les environnements distants

### Deploy Staging/Production
1. `supabase link` - Connecte le CLI au projet Supabase Cloud
2. `supabase db push` - Applique les migrations manquantes sur le cloud

---

## ✅ Vérification

### Après CI (sur PR) :
1. **GitHub Actions :**
   - Checks tab sur la PR → Voir le workflow CI
   - Vérifier qu'il passe au vert ✅

### Après Déploiement :
1. **GitHub Actions :**
   - Actions tab → Voir le workflow en cours
   - Vérifier qu'il passe au vert ✅

2. **Supabase Dashboard :**
   - Table Editor → Vérifier que les tables existent
   - SQL Editor → Tester des requêtes

3. **Application :**
   - Tester les fonctionnalités qui utilisent la DB

---

## 🐛 Résolution de Problèmes

### CI : "Docker not available"
- Normal sur les runners GitHub, Docker est disponible par défaut
- Si erreur, vérifier que `runs-on: ubuntu-latest` est bien présent

### CI : "Migration failed"
- La migration a une erreur SQL
- Corriger la migration localement
- Tester avec `supabase start` + `supabase db push`
- Commit et push à nouveau

### Déploiement : "Project not found"
- Vérifier que `STAGING_PROJECT_ID` ou `PRODUCTION_PROJECT_ID` est correct
- Format attendu : `abcdefghijklmnop` (16 caractères)

### Déploiement : "Authentication failed"
- Vérifier que `SUPABASE_ACCESS_TOKEN` est valide
- Régénérer un nouveau token si nécessaire

### Déploiement : "Database connection failed"
- Vérifier que `STAGING_DB_PASSWORD` ou `PRODUCTION_DB_PASSWORD` est correct
- Réinitialiser le mot de passe dans Supabase si nécessaire

---

## 🎯 Best Practices

1. **Toujours créer une PR avant de merger**
   - Permet au CI de valider les migrations
   - Revue de code par l'équipe

2. **Toujours tester sur staging d'abord**
   - Merge vers `staging` → Test complet → Merge vers `main`

3. **Ne jamais skip l'approbation production**
   - Toujours vérifier que staging fonctionne avant d'approuver

4. **Sauvegarder avant les migrations importantes**
   - Backup manuel depuis Supabase Dashboard si migration risquée

5. **Versionner les migrations**
   - Ne jamais modifier une migration déjà déployée
   - Créer une nouvelle migration pour les corrections

6. **Monitorer les déploiements**
   - Vérifier les logs GitHub Actions
   - Vérifier les logs Supabase après déploiement

---

## 📚 Ressources

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Supabase Migrations Guide](https://supabase.com/docs/guides/cli/local-development#database-migrations)
