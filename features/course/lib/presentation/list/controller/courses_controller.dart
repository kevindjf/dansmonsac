import 'dart:async';
import 'dart:developer' as developer;
import 'package:course/di/riverpod_di.dart';
import 'package:course/presentation/list/controller/course_list_state.dart';
import 'package:course/repository/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:main/presentation/home/controller/home_state_ui.dart';
import 'package:onboarding/src/di/riverpod_di.dart';
import 'package:onboarding/src/models/command/pack_time_command.dart';
import 'package:onboarding/src/presentation/course/controller/course_onboarding_state.dart';
import 'package:onboarding/src/presentation/course/course_page.dart';
import 'package:onboarding/src/presentation/hour/controller/setup_time_onboarding_state.dart';
import 'package:onboarding/src/repositories/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:supply/di/riverpod_di.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/repository/supply_repository.dart';

import '../../../models/cours_with_supplies.dart';

part 'courses_controller.g.dart';

@riverpod
class CoursesController extends _$CoursesController {
  late CourseRepository courseRepository;
  late SupplyRepository supplyRepository;

  final List<CourseWithSupplies> listCourses = [];

  @override
  Future<CourseListState> build() async {
    courseRepository = ref.watch(courseRepositoryProvider);
    supplyRepository = ref.watch(supplyRepositoryProvider);

    state = const AsyncValue.loading(); // Déclenche un état de chargement

    final response = await courseRepository.fetchCourses();

    return response.fold(
      (failure) => ErrorCourseListState(), // Gestion d'erreur
      (courses) {
        listCourses.addAll(courses);

        return DataCourseListState(apiToUI(courses));
      }, // Retourne la liste des cours
    );
  }

  List<CourseItemUI> apiToUI(List<CourseWithSupplies> courses) {
    List<CourseItemUI> itemsUi = [];

    for (var course in courses) {
      List<SupplyItemUI> supplies = [];
      for (var supply in course.supplies) {
        supplies.add(SupplyItemUI(id: supply.id, name: supply.name));
      }

      itemsUi.add(CourseItemUI(
          id: course.id,
          title: course.name,
          supplies: supplies,
          isExpand: false));
    }

    return itemsUi;
  }

  void onExpandCourse(int index) {
    state = state.whenData((currentState) {
      if (currentState is DataCourseListState) {
        final updatedList = List<CourseItemUI>.from(currentState.items);

        updatedList[index] = updatedList[index].copyWith(
          isExpand: !updatedList[index].isExpand,
        );

        return DataCourseListState(updatedList);
      }
      return currentState;
    });
  }

  void addSupply(int index, Supply? supply) {
    if (supply == null || state.value == null) return;

    final currentUI = (state.value as DataCourseListState).items;
    final expandStates = {
      for (var course in currentUI) course.id: course.isExpand
    };

    final updatedCourses = List<CourseWithSupplies>.from(listCourses);
    final updatedCourse = updatedCourses[index];
    final updatedSupplies = List<Supply>.from(updatedCourse.supplies)
      ..add(supply);

    updatedCourses[index] = updatedCourse.copyWith(supplies: updatedSupplies);

    final updatedUI = apiToUI(updatedCourses).map((course) {
      return course.copyWith(isExpand: expandStates[course.id] ?? false);
    }).toList();

    updatedUI[index] = updatedUI[index].copyWith(isExpand: true);

    listCourses
      ..clear()
      ..addAll(updatedCourses);

    state = AsyncValue.data(DataCourseListState(updatedUI));
  }

  Future<void> onDeleteSupply(int courseIndex, SupplyItemUI supply) async {
    // Récupérer l'état actuel
    final currentState = state.value as DataCourseListState;
    final currentCourses = List<CourseItemUI>.from(currentState.items);

    // Créer une version locale mise à jour optimiste (sans attendre la réponse de l'API)
    final optimisticCourses = List<CourseItemUI>.from(currentCourses);
    final targetCourse = optimisticCourses[courseIndex];

    // Supprimer localement la fourniture
    final updatedSupplies =
        targetCourse.supplies.where((s) => s.id != supply.id).toList();

    // Mettre à jour le cours avec la liste de fournitures mise à jour
    optimisticCourses[courseIndex] = targetCourse.copyWith(
      supplies: updatedSupplies,
      isExpand: true, // Maintenir l'expansion
    );

    // Mettre immédiatement à jour l'UI avec cette version optimiste
    state = AsyncValue.data(DataCourseListState(optimisticCourses));

    try {
      // Exécuter la suppression réelle en arrière-plan
      final deleteResult = await supplyRepository.deleteSupply(supply.id);

      if (deleteResult.isLeft()) {
        // En cas d'erreur, restaurer l'état précédent et afficher une notification
        state = AsyncValue.data(DataCourseListState(currentCourses));
        // Ici vous pourriez afficher un snackbar ou une notification d'erreur
        return;
      }

      // Rafraîchir silencieusement les données en arrière-plan
      final coursesResult = await courseRepository.fetchCourses();

      if (coursesResult.isLeft()) {
        // Ignorer l'erreur car l'UI est déjà mise à jour optimistiquement
        return;
      }

      // Extraire les cours mis à jour
      final updatedCourses = coursesResult.getOrElse(() => []);

      // Sauvegarder les états d'expansion actuels
      final expansionMap = {
        for (var course in optimisticCourses) course.id: course.isExpand
      };

      // Convertir les données de l'API et restaurer les états d'expansion
      final updatedUI = apiToUI(updatedCourses).map((course) {
        return course.copyWith(isExpand: expansionMap[course.id] ?? false);
      }).toList();

      // S'assurer que le cours concerné reste en état d'expansion
      if (courseIndex < updatedUI.length) {
        updatedUI[courseIndex] =
            updatedUI[courseIndex].copyWith(isExpand: true);
      }

      // Mettre à jour la liste interne
      listCourses
        ..clear()
        ..addAll(updatedCourses);

      // Mettre à jour l'état avec les données réelles (mais l'utilisateur ne devrait pas voir de différence)
      state = AsyncValue.data(DataCourseListState(updatedUI));
    } catch (e) {
      // Ignorer l'erreur car l'UI est déjà mise à jour optimistiquement
      // Vous pourriez logger l'erreur pour le débogage
    }
  }

  Future<void> onDeleteCourse(int courseIndex) async {
    // Récupérer l'état actuel
    final currentState = state.value as DataCourseListState;
    final currentCourses = List<CourseItemUI>.from(currentState.items);

    // Récupérer le cours à supprimer
    final courseToDelete = currentCourses[courseIndex];

    // Créer une version optimiste sans le cours à supprimer
    final optimisticCourses = List<CourseItemUI>.from(currentCourses);
    optimisticCourses.removeAt(courseIndex);

    // Mettre immédiatement à jour l'UI avec cette version optimiste
    state = AsyncValue.data(DataCourseListState(optimisticCourses));

    try {
      // Exécuter la suppression réelle en arrière-plan
      final deleteResult =
          await courseRepository.deleteCourse(courseToDelete.id);

      if (deleteResult.isLeft()) {
        print(deleteResult);
        // En cas d'erreur, restaurer l'état précédent
        state = AsyncValue.data(DataCourseListState(currentCourses));
        // Vous pourriez afficher un snackbar ou une notification d'erreur
        return;
      }

      // Rafraîchir silencieusement les données en arrière-plan
      final coursesResult = await courseRepository.fetchCourses();

      if (coursesResult.isLeft()) {
        // Ignorer l'erreur car l'UI est déjà mise à jour optimistiquement
        return;
      }

      // Extraire les cours mis à jour
      final updatedCourses = coursesResult.getOrElse(() => []);

      // Sauvegarder les états d'expansion actuels pour les cours restants
      final expansionMap = {
        for (var course in optimisticCourses) course.id: course.isExpand
      };

      // Convertir les données de l'API et restaurer les états d'expansion
      final updatedUI = apiToUI(updatedCourses).map((course) {
        return course.copyWith(isExpand: expansionMap[course.id] ?? false);
      }).toList();

      // Mettre à jour la liste interne
      listCourses
        ..clear()
        ..addAll(updatedCourses);

      // Mettre à jour l'état avec les données réelles
      state = AsyncValue.data(DataCourseListState(updatedUI));
    } catch (e) {
      // Ignorer l'erreur car l'UI est déjà mise à jour optimistiquement
      // Vous pourriez logger l'erreur pour le débogage
    }
  }

  void onAddCourse(CourseWithSupplies? course) {
    if (course == null || state.value == null) return;

    final currentUI = (state.value as DataCourseListState).items;
    final expandStates = {
      for (var course in currentUI) course.id: course.isExpand
    };

    listCourses.add(course);

    final updatedCourses = List<CourseWithSupplies>.from(listCourses);

    final updatedUI = apiToUI(updatedCourses).map((course) {
      return course.copyWith(isExpand: expandStates[course.id] ?? false);
    }).toList();

    listCourses
      ..clear()
      ..addAll(updatedCourses);

    state = AsyncValue.data(DataCourseListState(updatedUI));
  }

  refreshCourses() async {
    final response = await courseRepository.fetchCourses();

    response.fold(
      (failure) => ErrorCourseListState(), // Gestion d'erreur
      (courses) {
        listCourses.clear();
        listCourses.addAll(courses);

        state = AsyncValue.data(DataCourseListState(apiToUI(courses)));
      }, // Retourne la liste des cours
    );
  }
}
