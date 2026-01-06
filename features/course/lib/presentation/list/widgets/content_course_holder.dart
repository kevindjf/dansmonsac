import 'package:course/presentation/list/controller/course_list_state.dart';
import 'package:course/presentation/list/widgets/content_supplies_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/ui/ui.dart';

class ContentCourseHolder extends ConsumerWidget {
  final _contentOpenProvider = StateProvider<bool>((ref) => false);

  final ValueChanged<CourseItemUI> onAddSupply;
  final ValueChanged<CourseItemUI> onExpandCourse;
  final ValueChanged<SupplyItemUI> onDeleteSupply;
  final ValueChanged<CourseItemUI> onDeleteCourse;

  final CourseItemUI course;

  ContentCourseHolder(
      {super.key,
      required this.course,
      required this.onExpandCourse,
      required this.onAddSupply,
      required this.onDeleteSupply,
      required this.onDeleteCourse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isOpen = course.isExpand;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            InkWell(
              splashColor: Colors.transparent, // Supprime l'effet d'onde
              highlightColor: Colors.transparent,
              onTap: () => onExpandCourse(course),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course.title.toUpperCase(),
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 16,
                        color: accentColor,
                        fontWeight: FontWeight.bold),
                  ),
                  AnimatedRotation(
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    turns: isOpen ? 0.25 : 0,
                    child: Icon(Icons.chevron_right,
                        size: 24, color: accentColor),
                  )
                ],
              ),
            ),
            isOpen
                ? ContentSupplyHolder(
                    supplies: course.supplies,
                    onAddSupply: () {
                      onAddSupply(course);
                    },
                    onDeleteSupply: onDeleteSupply,
                    onDeleteCourse: () {
                      onDeleteCourse(course);
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
