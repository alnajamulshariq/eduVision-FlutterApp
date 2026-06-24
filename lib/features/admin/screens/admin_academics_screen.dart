import 'package:eduvision_app/app/theme.dart';
import 'package:eduvision_app/core/constants/app_constants.dart';
import 'package:eduvision_app/core/widgets/module_screen_shell.dart';
import 'package:flutter/material.dart';

class AdminAcademicsScreen extends StatelessWidget {
  const AdminAcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenShell(
      title: 'Academic Management',
      subtitle: 'Departments, batches, semesters, subjects.',
      fallbackRoute: AppRoutes.admin,
      children: const [
        ModulePanel(
          child: Column(
            children: [
              ModuleInfoTile(
                title: 'Departments',
                subtitle: 'BSIT, BSSE, and academic units',
                icon: Icons.account_tree_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Batches',
                subtitle: 'Batch 2022, 2023, and intake groups',
                icon: Icons.groups_rounded,
                color: AppColors.blue,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Semesters',
                subtitle: 'Semester levels and promotions',
                icon: Icons.layers_rounded,
                color: AppColors.amber,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'Subjects',
                subtitle: 'Course catalogue preview',
                icon: Icons.menu_book_rounded,
                color: Color(0xFFB48CFF),
              ),
            ],
          ),
        ),
        ModulePanel(
          child: Column(
            children: [
              ModuleInfoTile(
                title: 'Database Systems',
                subtitle: 'Assigned to Mr. Ahmad',
                icon: Icons.assignment_ind_rounded,
                color: AppColors.cyan,
              ),
              SizedBox(height: 10),
              ModuleInfoTile(
                title: 'BSIT 2022',
                subtitle: 'Students enrolled',
                icon: Icons.school_rounded,
                color: AppColors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
