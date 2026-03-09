import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/utils.dart';
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
    final validationError = Validators.validateSupplyName(state.supplyName);
    if (validationError != null) {
      state = state.copyWith(errorSupplyName: validationError);
      return;
    }

    final cleanName = Validators.clean(state.supplyName);
    var response =
        await supplyRepository.store(AddSupplyCommand(cleanName, courseId));

    response.fold((failure) {
      state = state.copyWith(isLoading: false);
      _errorController.add(ErrorMessages.getMessageForFailure(failure));
    }, (supply) {
      _successController.add(supply);
    });
  }

  skip() {
    ref.watch(routerDelegateProvider).goToHome();
  }
}
