import 'dart:async';
import 'dart:ffi';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:supply/di/riverpod_di.dart';
import 'package:supply/models/command/add_supply_command.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/presentation/add/controller/add_supply_state.dart';
import 'package:supply/repository/supply_repository.dart';

part 'add_supply_controller.g.dart';

@riverpod
class AddSupplyController extends _$AddSupplyController {
  late SupplyRepository supplyRepository;

  final _errorController = StreamController<String>.broadcast();
  final _successController = StreamController<Supply>.broadcast();

  Stream<String> get errorStream => _errorController.stream;

  Stream<Supply> get successStream => _successController.stream;

  @override
  AddSupplyState build(String courseId) {
    supplyRepository = ref.watch(supplyRepositoryProvider);
    return AddSupplyState.initial(courseId);
  }

  supplyNameChanged(String text) {
    state = state.copyWith(supplyName: text);
  }

  store() async {
    if (state.supplyName.trim().isEmpty) {
      state = state.copyWith(
          errorSupplyName: "Le nom de la fourniture ne peut pas être vide");
      return;
    }

    var response = await supplyRepository
        .store(AddSupplyCommand(state.supplyName, courseId));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      _errorController
          .add("Une erreur est survenue, veuillez réessayer ultérieurement !");
    }, (supply) {
      _successController.add(supply);
    });
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
