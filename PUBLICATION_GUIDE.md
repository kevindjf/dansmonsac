# Guide de Publication - DansMonSac

Ce guide détaille toutes les étapes pour publier DansMonSac sur Google Play Store et Apple App Store.

---

## 📋 Prérequis

### Comptes nécessaires
- ✅ Compte Google Play Console (25$ one-time fee)
- ✅ Compte Apple Developer (99€/an)

### Éléments requis
- [ ] Screenshots de l'application (min. 2 pour Android, 3 pour iOS)
- [ ] Icône de l'application (✅ déjà créée)
- [ ] Bannière Google Play (1024x500px) - optionnel mais recommandé
- [ ] Description et textes marketing (✅ voir STORE_LISTING.md)
- [ ] Politique de confidentialité publiée en ligne (✅ voir PRIVACY_POLICY.md)

---

## 🤖 Publication Android (Google Play)

### Étape 1 : Créer le keystore de signature

**⚠️ IMPORTANT : Ne perdez JAMAIS ce fichier ni les mots de passe !**

```bash
cd android

keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias dansmonsac

# Il vous sera demandé :
# - Store password : choisissez un mot de passe fort
# - Key password : choisissez un mot de passe fort (peut être le même)
# - Nom et prénom, organisation, etc.
```

**💾 Sauvegarde :**
- Sauvegardez `upload-keystore.jks` dans un endroit sûr (cloud crypté, gestionnaire de mots de passe)
- Notez les mots de passe dans un endroit sécurisé

### Étape 2 : Configurer key.properties

Copiez le template et remplissez-le :

```bash
cd android
cp key.properties.template key.properties
```

Éditez `key.properties` avec vos informations :

```properties
storePassword=VOTRE_STORE_PASSWORD
keyPassword=VOTRE_KEY_PASSWORD
keyAlias=dansmonsac
storeFile=../upload-keystore.jks
```

⚠️ **Ne commitez JAMAIS ce fichier dans Git !** (déjà dans .gitignore)

### Étape 3 : Builder l'APK/AAB

**Pour Google Play (recommandé - Android App Bundle) :**

```bash
flutter build appbundle --release
```

Le fichier sera généré dans :
`build/app/outputs/bundle/release/app-release.aab`

**Alternative - APK classique :**

```bash
flutter build apk --release --split-per-abi
```

Fichiers générés dans `build/app/outputs/flutter-apk/` :
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit - requis)
- `app-x86_64-release.apk` (émulateurs)

### Étape 4 : Tester l'APK/AAB

```bash
# Installer l'APK sur un device connecté
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Ou utiliser bundletool pour tester l'AAB
```

Vérifiez que tout fonctionne :
- [ ] L'app se lance correctement
- [ ] Pas de crash
- [ ] Les notifications fonctionnent
- [ ] Les préférences sont sauvegardées
- [ ] Le système A/B fonctionne

### Étape 5 : Google Play Console

1. **Créer l'application**
   - Allez sur https://play.google.com/console
   - Cliquez sur "Créer une application"
   - Nom : `DansMonSac`
   - Langue par défaut : Français (France)
   - Type : Application / Jeu
   - Gratuit/Payant : Gratuit

2. **Remplir la fiche du store**
   - **Description courte** : (voir STORE_LISTING.md)
   - **Description complète** : (voir STORE_LISTING.md)
   - **Icône** : `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
   - **Graphique de fonctionnalité** : 1024x500px (optionnel)
   - **Screenshots** : min. 2 (Phone), optionnel (Tablet, Wear OS, TV)
   - **Catégorie** : Éducation
   - **Tags** : Education, Organisation, École

3. **Politique de confidentialité**
   - Héberger PRIVACY_POLICY.md sur un site web accessible
   - Ou utiliser GitHub Pages : https://[ton-username].github.io/dansmonsac/privacy
   - Coller l'URL dans Google Play Console

4. **Questionnaire de sécurité des données**
   - **Collecte de données** : NON
   - **Partage de données** : NON
   - L'app ne collecte aucune donnée utilisateur

5. **Contenu et public cible**
   - **Public cible** : Principalement 13-17 ans, aussi 9-12 et adultes
   - **Contenu** : PEGI 3 / Everyone
   - **Annonces** : Non, pas de publicités

6. **Upload de l'AAB**
   - Allez dans "Production" > "Créer une version"
   - Uploadez `app-release.aab`
   - Notes de version : (voir plus bas)

7. **Soumettre pour examen**
   - Vérifiez tous les warnings
   - Cliquez sur "Envoyer pour examen"
   - Délai : 1-7 jours généralement

### Notes de version (première release)

**Français :**
```
🎒 Première version de DansMonSac !

✨ Fonctionnalités :
• Gestion emploi du temps semaines A/B
• Liste automatique des fournitures à préparer
• Rappel quotidien par notification
• Personnalisation avec couleur d'accent
• Interface simple et intuitive

Cette application vous aidera à ne plus jamais oublier vos affaires pour l'école !
```

**Anglais :**
```
🎒 First release of DansMonSac!

✨ Features:
• A/B week schedule management
• Automatic supply list generation
• Daily reminder notifications
• Customizable accent color
• Simple and intuitive interface

Never forget your school supplies again!
```

---

## 🍎 Publication iOS (App Store)

### Étape 1 : Configuration Xcode

1. Ouvrir le projet iOS :
```bash
open ios/Runner.xcworkspace
```

2. Sélectionner "Runner" dans le navigator

3. **General tab :**
   - Display Name : `DansMonSac`
   - Bundle Identifier : `fr.kappsmobile.dansmonsac`
   - Version : `1.0.0`
   - Build : `1`

4. **Signing & Capabilities :**
   - Team : Sélectionnez votre équipe Apple Developer
   - Cochez "Automatically manage signing"

### Étape 2 : Configurer Info.plist

Le fichier `ios/Runner/Info.plist` doit contenir :

```xml
<key>CFBundleDisplayName</key>
<string>DansMonSac</string>

<key>NSUserNotificationsUsageDescription</key>
<string>Nous avons besoin d'envoyer des notifications pour te rappeler de préparer ton sac chaque jour.</string>

<key>NSCalendarsUsageDescription</key>
<string>Accès au calendrier pour gérer ton emploi du temps.</string>
```

### Étape 3 : Builder pour iOS

```bash
flutter build ios --release
```

Ou depuis Xcode :
- Product > Archive
- Attendez la fin de l'archivage

### Étape 4 : App Store Connect

1. **Créer l'app**
   - Allez sur https://appstoreconnect.apple.com
   - "Mes Apps" > "+" > "Nouvelle app"
   - Plateformes : iOS
   - Nom : `DansMonSac`
   - Langue principale : Français
   - Bundle ID : `fr.kappsmobile.dansmonsac`
   - SKU : `dansmonsac-ios`

2. **Informations sur l'app**
   - **Nom** : DansMonSac
   - **Sous-titre** : (30 caractères) Ne plus rien oublier
   - **Description** : (voir STORE_LISTING.md)
   - **Mots-clés** : (100 caractères) voir STORE_LISTING.md
   - **URL de support** : [votre site web ou email]
   - **URL marketing** : [optionnel]

3. **Politique de confidentialité**
   - URL : [votre URL de politique de confidentialité]

4. **Catégorie**
   - Primaire : Éducation
   - Secondaire : Productivité

5. **Prix et disponibilité**
   - Prix : Gratuit
   - Disponibilité : Tous les territoires

6. **Captures d'écran**
   - iPhone 6.7" (required)
   - iPhone 6.5" (required)
   - iPad Pro 12.9" (optional)
   - Min. 3 screenshots par taille

7. **Upload depuis Xcode**
   - Dans Xcode, après "Archive"
   - Window > Organizer
   - Sélectionnez l'archive
   - "Distribute App" > "App Store Connect"
   - Suivez l'assistant

8. **Soumettre pour examen**
   - Dans App Store Connect, sélectionnez la build
   - Répondez aux questions (export compliance, etc.)
   - Cliquez sur "Soumettre pour examen"
   - Délai : 1-2 jours généralement

---

## 📝 Checklist finale avant soumission

### Android
- [ ] Keystore créé et sauvegardé
- [ ] key.properties configuré
- [ ] AAB généré et testé
- [ ] Screenshots prêts (min. 2)
- [ ] Description remplie
- [ ] Politique de confidentialité publiée
- [ ] Questionnaire de sécurité des données complété
- [ ] Pas de warnings critiques dans Play Console

### iOS
- [ ] Certificats Apple Developer configurés
- [ ] Archive créée dans Xcode
- [ ] Screenshots prêts (min. 3 par taille)
- [ ] Description remplie
- [ ] Politique de confidentialité publiée
- [ ] Questionnaire sur l'export compliance
- [ ] Build uploadée sur App Store Connect

---

## 🔄 Mises à jour ultérieures

### Incrémenter la version

Éditez `pubspec.yaml` :

```yaml
version: 1.0.1+2  # 1.0.1 = versionName, 2 = versionCode
```

Format : `MAJOR.MINOR.PATCH+BUILD`
- **MAJOR** : Changements majeurs incompatibles
- **MINOR** : Nouvelles fonctionnalités compatibles
- **PATCH** : Corrections de bugs
- **BUILD** : Incrémenter à chaque upload (Android versionCode, iOS build number)

### Builder et uploader

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

Puis suivez les mêmes étapes que pour la première publication.

---

## 🆘 Résolution de problèmes

### Erreur de signature Android
```
INSTALL_PARSE_FAILED_NO_CERTIFICATES
```
**Solution** : Vérifiez que key.properties est correct et que le keystore existe

### Build iOS échoue
```
Code signing error
```
**Solution** : Vérifiez que votre compte Apple Developer est actif et que les certificats sont valides

### L'app crash au lancement (release)
**Causes possibles** :
- Proguard trop agressif : ajustez `proguard-rules.pro`
- Permissions manquantes
- Chemins d'assets incorrects

**Debug** :
```bash
flutter build apk --release
adb logcat | grep -i flutter
```

---

## 📞 Support

### Pour les utilisateurs
Fournissez un email de support dans les stores.

### Monitoring
- **Crashes** : Consultez Play Console / App Store Connect
- **Reviews** : Répondez aux avis (améliore le ranking !)
- **Analytics** : Ajoutez Firebase Analytics si souhaité (optionnel)

---

## 🎉 Après publication

1. **Testez l'installation**
   - Téléchargez depuis le store
   - Vérifiez que tout fonctionne

2. **Communication**
   - Partagez le lien du store
   - Demandez des avis (bons avis = meilleur ranking)

3. **Maintenance**
   - Surveillez les crashes
   - Lisez les reviews
   - Corrigez les bugs critiques rapidement
   - Planifiez des mises à jour régulières

---

**Liens utiles :**
- Google Play Console : https://play.google.com/console
- App Store Connect : https://appstoreconnect.apple.com
- Flutter Deployment Docs : https://docs.flutter.dev/deployment

Bonne chance pour la publication ! 🚀
