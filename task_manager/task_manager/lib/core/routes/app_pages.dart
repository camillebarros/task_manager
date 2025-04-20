import 'package:get/get.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/modules/auth/views/login.page.dart';
import 'package:task_manager/modules/auth/views/register_page.dart';
import 'package:task_manager/modules/tasks/views/task_list_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.AUTH,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => TaskListPage(),
      transition: Transition.fadeIn,
    ),
  ];
}