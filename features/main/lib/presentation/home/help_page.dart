import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: Text(
          'Aide',
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF303030),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions frequentes',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trouve les reponses a tes questions',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Items
          _buildFaqItem(
            context: context,
            question: 'Comment ajouter un cours ?',
            answer: 'Va dans l\'onglet "Cours" et appuie sur le bouton "Ajouter un cours" en bas de l\'ecran. Entre le nom de la matiere et valide.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment ajouter des fournitures a un cours ?',
            answer: 'Dans l\'onglet "Cours", appuie sur un cours pour le deployer. Tu verras un bouton "+" pour ajouter des fournitures a ce cours.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment fonctionne le systeme de semaines A/B ?',
            answer: 'Certains cours n\'ont lieu qu\'une semaine sur deux. Dans l\'onglet "Calendrier", tu peux choisir si un cours a lieu en semaine A, semaine B, ou les deux. La date de debut d\'annee scolaire dans les parametres determine quelle semaine est A ou B.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment ajouter un cours au calendrier ?',
            answer: 'Dans l\'onglet "Calendrier", appuie sur "Ajouter un cours". Selectionne le cours, la salle, le jour, le type de semaine et les horaires.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment partager mon emploi du temps ?',
            answer: 'Va dans les parametres ou appuie sur "Partager" dans l\'onglet Calendrier. Un code unique sera genere que tu peux partager avec tes amis. Ils pourront importer ton emploi du temps avec ce code.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment importer l\'emploi du temps d\'un ami ?',
            answer: 'Va dans les parametres et choisis "Importer un emploi du temps". Entre le code de 6 caracteres que ton ami t\'a donne. Tu verras un apercu avant d\'importer.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment modifier l\'heure des notifications ?',
            answer: 'Dans les parametres, appuie sur "Heure de preparation" pour choisir l\'heure a laquelle tu veux recevoir le rappel quotidien.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment changer la couleur de l\'application ?',
            answer: 'Dans les parametres, appuie sur "Couleur d\'accent" pour choisir ta couleur preferee. Elle sera appliquee dans toute l\'application.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Comment supprimer un cours ou une fourniture ?',
            answer: 'Dans l\'onglet "Cours", fais glisser le cours ou la fourniture vers la gauche pour faire apparaitre le bouton de suppression.',
            accentColor: accentColor,
          ),
          _buildFaqItem(
            context: context,
            question: 'Mes donnees sont-elles sauvegardees ?',
            answer: 'Oui, tes donnees sont sauvegardees automatiquement sur ton appareil et synchronisees en ligne. Tu peux reinstaller l\'application sans perdre tes cours.',
            accentColor: accentColor,
          ),
          const SizedBox(height: 24),

          // Contact section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 32,
                  color: accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu n\'as pas trouve ta reponse ?',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Contacte-nous a support@dansmonsac.app',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required BuildContext context,
    required String question,
    required String answer,
    required Color accentColor,
  }) {
    return Card(
      color: const Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          iconColor: accentColor,
          collapsedIconColor: Colors.white54,
          title: Text(
            question,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
