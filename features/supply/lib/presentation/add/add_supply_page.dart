import 'dart:async';

import 'package:common/src/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/presentation/add/controller/add_supply_controller.dart';

class AddSupplyPage extends ConsumerStatefulWidget {
  final String courseId;
  final ValueChanged<Supply?> onAddSupply;

  const AddSupplyPage(
      {Key? key, required this.courseId, required this.onAddSupply})
      : super(key: key);

  @override
  ConsumerState<AddSupplyPage> createState() => _AddSupplyPageState();
}

class _AddSupplyPageState extends ConsumerState<AddSupplyPage> {
  final TextEditingController _supplyNameController = TextEditingController();

  StreamSubscription? _errorSubscription;
  StreamSubscription? _successSubscription;

  AddSupplyController getNotifier() {
    return ref.read(addSupplyControllerProvider(widget.courseId).notifier);
  }

  @override
  void initState() {
    super.initState();

    _supplyNameController.addListener(() => ref
        .read(addSupplyControllerProvider(widget.courseId).notifier)
        .supplyNameChanged(_supplyNameController.text));

    _supplyNameController.addListener(() => ref
        .read(addSupplyControllerProvider(widget.courseId).notifier)
        .supplyNameChanged(_supplyNameController.text));

    _errorSubscription = ref
        .read(addSupplyControllerProvider(widget.courseId).notifier)
        .errorStream
        .listen((errorMessage) {
      if (mounted) {
        ShowErrorMessage.show(context, errorMessage);
      }
    });

    _successSubscription = ref
        .read(addSupplyControllerProvider(widget.courseId).notifier)
        .successStream
        .listen((supply) {
      if (mounted) {
        widget.onAddSupply(supply);
      }
    });
  }

  @override
  void dispose() {
    _supplyNameController.dispose();
    _errorSubscription?.cancel();
    _successSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(addSupplyControllerProvider(widget.courseId));
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Ajuste le padding selon la hauteur du clavier
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // Permet d'éviter que la bottom sheet prenne toute la hauteur
          children: [
            Text(
              "Nouvelle fourniture",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _supplyNameController,
              labelText: "Fourniture",
              hintText: "Exemple : Cahier bleu",
              context: context,
              onSubmitted: (_) => getNotifier().store(),
            ),
            state.errorSupplyName == null
                ? const SizedBox()
                : Column(
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${state.errorSupplyName}",
                        style: TextStyle(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      getNotifier().store();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Bouton Plus tard
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Fermer le clavier d'abord
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Plus tard",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      String? hintText,
      Function(String)? onSubmitted,
      BuildContext? context}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context!).colorScheme.primary),
        ),
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
