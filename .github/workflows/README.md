# 🚀 GitHub Actions - Déploiement Supabase

## 🔄 Workflows Disponibles

### 1. **CI** (`ci.yml`) - Tests automatiques
- Se déclenche sur **chaque Pull Request** et manuellement via `workflow_dispatch`
- Lance Supabase en local avec Docker
- Vérifie que les types TypeScript sont à jour
- Exécute les tests de la base de données
- Arrête l'environnement local
- ✅ **Aucun secret requis** (tout en local)

### 2. **Deploy Staging** (`deploy-staging.yml`)
- Se déclenche sur push vers les branches `staging` ou `develop`
- Déploie automatiquement sur l'environnement de staging
- Génère les types TypeScript à jour
- Peut être déclenché manuellement via `workflow_dispatch`

### 3. **Deploy Production** (`deploy-production.yml`)
- Se déclenche sur push vers la branche `main`
- Utilise l'environnement protégé `production` avec approbation requise
- Déploie sur l'environnement de production
- Génère les types TypeScript à jour
- Peut être déclenché manuellement via `workflow_dispatch`

---

## 📋 Configuration des Secrets et Environnements

Avant de pouvoir utiliser les workflows de déploiement, vous devez configurer les secrets GitHub et les environnements protégés.

### Étape 1 : Configurer les Environnements Protégés

1. **Aller dans votre repository GitHub**
   - Settings → Environments

2. **Créer l'environnement `staging`**
   - Cliquer sur "New environment"
   - Nom : `staging`
   - (Optionnel) Ajouter des reviewers si vous voulez une approbation pour staging

3. **Créer l'environnement `production`**
   - Cliquer sur "New environment"
   - Nom : `production`
   - ✅ **Cocher "Required reviewers"**
   - Ajouter les personnes autorisées à approuver les déploiements en production
   - (Optionnel) Ajouter une "Wait timer" pour retarder les déploiements

### Étape 2 : Ajouter les Secrets GitHub

**Aller dans Settings → Secrets and variables → Actions**

#### Secrets Partagés (Repository secrets)

##### `SUPABASE_ACCESS_TOKEN`
- Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
- Account → Access Tokens
- Créer un nouveau token avec les permissions :
  - ✅ All projects access
  - ✅ Read/Write permissions
- Copier et ajouter comme secret GitHub

#### Secrets Spécifiques par Environnement

##### Pour l'environnement `staging` :

1. **`STAGING_PROJECT_ID`**
   - Aller sur votre projet Staging dans Supabase
   - Settings → General → Reference ID
   - Copier l'ID (format: `abcdefghijklmnop`)
   - Ajouter comme secret dans l'environnement `staging` ou comme repository secret

2. **`STAGING_DB_PASSWORD`**
   - Aller sur votre projet Staging dans Supabase
   - Settings → Database → Database Password
   - Utiliser le mot de passe existant ou en générer un nouveau
   - Ajouter comme secret dans l'environnement `staging` ou comme repository secret

##### Pour l'environnement `production` :

1. **`PRODUCTION_PROJECT_ID`**
   - Aller sur votre projet Production dans Supabase
   - Settings → General → Reference ID
   - Copier l'ID
   - Ajouter comme secret dans l'environnement `production` ou comme repository secret

2. **`PRODUCTION_DB_PASSWORD`**
   - Aller sur votre projet Production dans Supabase
   - Settings → Database → Database Password
   - Utiliser le mot de passe existant
   - Ajouter comme secret dans l'environnement `production` ou comme repository secret

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
git merge staging  # ou develop selon votre workflow
git push origin main
```
⚠️ **Déploiement avec approbation manuelle**
- Le workflow démarre automatiquement
- Le workflow se met en pause avant le déploiement
- Les reviewers configurés reçoivent une notification
- Approbation manuelle requise dans GitHub Actions
- Le déploiement continue après approbation
- Types TypeScript générés automatiquement

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
1. `supabase db start` - Lance Supabase localement avec Docker
2. `supabase gen types typescript --local` - Génère les types TypeScript depuis le schéma local
3. Vérifie que les types générés correspondent aux types commités
4. `supabase test db` - Exécute les tests de la base de données (si configurés)
5. `supabase stop` - Arrête l'instance locale

**Avantages :**
- ✅ Détecte les erreurs de migration avant le merge
- ✅ Valide la syntaxe SQL
- ✅ Vérifie que les migrations s'appliquent dans l'ordre
- ✅ Garantit que les types TypeScript sont à jour
- ✅ Exécute les tests automatisés
- ✅ Aucun impact sur les environnements distants

### Deploy Staging/Production
1. `supabase link --project-ref $PROJECT_ID` - Connecte le CLI au projet Supabase Cloud
2. `supabase db push --include-all` - Applique TOUTES les migrations manquantes sur le cloud
3. `supabase gen types typescript --linked` - Génère les types TypeScript depuis le schéma distant

**Avantages :**
- ✅ Déploiement automatique des migrations
- ✅ Types TypeScript générés depuis le schéma réel
- ✅ `--include-all` garantit que toutes les migrations sont appliquées
- ✅ Environnements protégés avec approbation manuelle

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
   - Vérifie automatiquement que les types sont à jour

2. **Toujours tester sur staging d'abord**
   - Merge vers `staging` ou `develop` → Test complet → Merge vers `main`
   - Valide les migrations dans un environnement réel

3. **Ne jamais skip l'approbation production**
   - Toujours vérifier que staging fonctionne avant d'approuver
   - Vérifier les logs du déploiement staging
   - Tester l'application sur staging avant d'approuver production

4. **Sauvegarder avant les migrations importantes**
   - Backup manuel depuis Supabase Dashboard si migration risquée
   - Documentation des migrations complexes

5. **Versionner les migrations**
   - ❌ **JAMAIS modifier une migration déjà déployée**
   - ✅ Créer une nouvelle migration pour les corrections
   - Utiliser `supabase migration new fix_description` pour corriger

6. **Monitorer les déploiements**
   - Vérifier les logs GitHub Actions en temps réel
   - Vérifier les logs Supabase après déploiement
   - Tester l'application après chaque déploiement

7. **Garder les types à jour**
   - Commiter les types générés avec chaque migration
   - Le CI vérifiera automatiquement qu'ils correspondent
   - Ne jamais modifier manuellement `database.types.ts`

8. **Utiliser les déploiements manuels si nécessaire**
   - Tous les workflows supportent `workflow_dispatch`
   - Permet de redéployer manuellement depuis l'interface GitHub
   - Utile pour les rollbacks ou les hotfixes

---

## 📚 Ressources

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Supabase Migrations Guide](https://supabase.com/docs/guides/cli/local-development#database-migrations)
