# DansMonSac - Publication

## 📱 À propos

**DansMonSac** est une application mobile Flutter qui aide les élèves à préparer leur sac scolaire et à ne rien oublier.

**Version actuelle :** 1.0.0 (Build 1)

---

## 🗂️ Documents de publication

Tous les documents nécessaires pour la publication sont prêts :

### ✅ Configuration technique
- **android/app/build.gradle** - Configuration de signature pour release
- **android/app/proguard-rules.pro** - Règles ProGuard pour optimisation
- **android/key.properties.template** - Template pour la configuration de signature
- **.gitignore** - Mis à jour pour ne pas commiter les clés

### ✅ Textes marketing
- **STORE_LISTING.md** - Descriptions complètes, mots-clés, catégories
  - Titre court et long
  - Description Google Play (4000 caractères)
  - Description App Store
  - Mots-clés optimisés pour SEO
  - Catégories et public cible

### ✅ Légal
- **PRIVACY_POLICY.md** - Politique de confidentialité complète
  - Conforme RGPD
  - Conforme COPPA
  - Pas de collecte de données
  - Prête à être publiée en ligne

### ✅ Guide complet
- **PUBLICATION_GUIDE.md** - Instructions détaillées étape par étape
  - Publication Android (Google Play)
  - Publication iOS (App Store)
  - Résolution de problèmes
  - Checklist complète

---

## 🚀 Prochaines étapes

### 1. Générer le Keystore Android
```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias dansmonsac
```
⚠️ **Sauvegardez ce fichier et les mots de passe en lieu sûr !**

### 2. Configurer key.properties
```bash
cd android
cp key.properties.template key.properties
# Éditez key.properties avec vos mots de passe
```

### 3. Prendre les screenshots
Minimum requis :
- **Android** : 2 screenshots (Phone)
- **iOS** : 3 screenshots (iPhone 6.7")

Suggestions de screenshots :
1. Écran d'accueil "Mon Sac" avec liste de fournitures
2. Calendrier avec emploi du temps A/B
3. Page "Mes Matières"
4. Notification de rappel
5. Paramètres avec personnalisation

### 4. Publier la politique de confidentialité
Options :
- GitHub Pages (gratuit)
- Votre site web
- Hébergeur simple (Netlify, Vercel)

URL nécessaire pour les stores.

### 5. Builder pour production

**Android :**
```bash
flutter build appbundle --release
```
Fichier : `build/app/outputs/bundle/release/app-release.aab`

**iOS :**
```bash
flutter build ios --release
# Puis archiver avec Xcode
```

### 6. Soumettre aux stores
Suivez le guide complet dans **PUBLICATION_GUIDE.md**

---

## 📊 Informations app

**Nom :** DansMonSac
**Package :** fr.kappsmobile.dansmonsac
**Version :** 1.0.0
**Build :** 1

**Catégorie :** Éducation
**Prix :** Gratuit
**Public :** 9+ ans

**Plateformes :**
- Android 5.0+ (API 21+)
- iOS 12.0+

---

## 🎯 Fonctionnalités principales

✅ Gestion emploi du temps A/B
✅ Liste automatique des fournitures
✅ Rappel quotidien par notification
✅ Personnalisation couleur d'accent
✅ Fournitures personnalisées par matière
✅ Interface intuitive

---

## 🔒 Confidentialité

**Aucune donnée collectée !**
- Stockage 100% local sur l'appareil
- Pas de serveur backend
- Pas de tracking
- Pas de publicité
- Open source friendly

---

## 📞 Support

Une fois publié, fournissez un email de support :
- Pour les utilisateurs : [votre email de support]
- Pour les stores : Requis dans les listings

---

## 🔄 Mises à jour

Pour publier une mise à jour :

1. Modifier le code
2. Incrémenter la version dans `pubspec.yaml` :
   ```yaml
   version: 1.0.1+2  # versionName+versionCode
   ```
3. Builder avec `flutter build appbundle/ios`
4. Uploader sur les consoles
5. Ajouter des notes de version

---

## ✅ Checklist pré-publication

### Technique
- [x] Configuration Android release
- [x] ProGuard rules
- [x] .gitignore mis à jour
- [ ] Keystore créé
- [ ] key.properties configuré
- [x] Version définie (1.0.0+1)

### Contenu
- [x] Descriptions écrites
- [x] Mots-clés définis
- [x] Politique de confidentialité rédigée
- [ ] Politique de confidentialité publiée en ligne
- [ ] Screenshots pris
- [x] Icône de l'app (✅ déjà présente)

### Comptes
- [x] Google Play Developer (selon vous)
- [x] Apple Developer (selon vous)

### Documentation
- [x] Guide de publication
- [x] Instructions détaillées
- [x] Templates fournis

---

## 🎉 Après publication

1. **Tester l'installation** depuis les stores
2. **Partager** les liens de téléchargement
3. **Surveiller** les reviews et crashs
4. **Répondre** aux avis utilisateurs
5. **Maintenir** : corrections de bugs et nouvelles fonctionnalités

---

## 📚 Ressources

- [Guide de publication complet](PUBLICATION_GUIDE.md)
- [Textes marketing](STORE_LISTING.md)
- [Politique de confidentialité](PRIVACY_POLICY.md)
- [Documentation Flutter - Deployment](https://docs.flutter.dev/deployment)

---

**Prêt pour la publication ! 🚀**

Tous les éléments sont préparés. Il ne reste plus qu'à :
1. Créer le keystore
2. Prendre les screenshots
3. Publier la politique de confidentialité
4. Builder et uploader

Bonne chance ! 🎒
