import 'package:course/models/cours_with_supplies.dart';
import 'package:course/presentation/list/controller/courses_controller.dart';
import 'package:course/presentation/list/widgets/content_course_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/ui/ui.dart';
import 'package:course/presentation/add/add_course_page.dart';
import 'package:supply/models/supply.dart';
import 'package:supply/presentation/add/add_supply_page.dart';
import 'controller/course_list_state.dart';

class CoursesPage extends ConsumerWidget {
  CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(coursesControllerProvider).when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text('Erreur : $error'),
          data: (state) {
            if (state is DataCourseListState) {
              return _body(context, state.items, ref);
            } else {
              return const Text("Aucune donnée");
            }
          },
        );
  }

  _body(BuildContext context, List<CourseItemUI> items, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getList(context,items, ref),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => showBottomSheet(context, ref),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Ajouter un cours",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  showBottomSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return AddCoursePage(onAddCourse: (CourseWithSupplies? course) {
          ref.read(coursesControllerProvider.notifier).onAddCourse(course);
        });
      },
    );
  }

  showBottomSheetSupply(
      int index, CourseItemUI course, BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return AddSupplyPage(
          courseId: course.id,
          onAddSupply: (Supply? supply) {
            ref
                .read(coursesControllerProvider.notifier)
                .addSupply(index, supply);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  _getList(BuildContext context,List<CourseItemUI> items, WidgetRef ref) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // Appelez votre fonction de rafraîchissement ici
          await ref.read(coursesControllerProvider.notifier).refreshCourses();
        },
        child: items.isEmpty
            ? _buildEmptyView(context)
            : ListView.builder(
          itemCount: items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Cours & Fourniture(s)",
                  style: GoogleFonts.robotoCondensed(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              );
            } else if (index <= items.length) {
              int realIndex = index - 1;
              final item = items[realIndex];

              return ContentCourseHolder(
                key: ValueKey('${item.id}_${item.isExpand}'),
                course: item,
                onAddSupply: (CourseItemUI value) {
                  showBottomSheetSupply(realIndex, value, context, ref);
                },
                onDeleteSupply: (SupplyItemUI value) {
                  ref
                      .read(coursesControllerProvider.notifier)
                      .onDeleteSupply(realIndex, value);
                },
                onDeleteCourse: (CourseItemUI value) {
                  ref
                      .read(coursesControllerProvider.notifier)
                      .onDeleteCourse(realIndex);
                },
                onExpandCourse: (CourseItemUI value) {
                  ref
                      .read(coursesControllerProvider.notifier)
                      .onExpandCourse(realIndex);
                },
              );
            } else {
              return const SizedBox(height: 80);
            }
          },
        ),
      ),
    );
  }

  _buildEmptyView(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7, // Hauteur pour centrer le contenu
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 50,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  "Aucun cours trouvé",
                  style: GoogleFonts.robotoCondensed(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tirez vers le bas pour actualiser ou\najoutez un nouveau cours",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoCondensed(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
