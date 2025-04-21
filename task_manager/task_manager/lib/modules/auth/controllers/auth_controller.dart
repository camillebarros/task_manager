import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/routes/routes.dart';
import 'package:task_manager/modules/tasks/controllers/task_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User> user = Rxn<User>();

  // Método para registrar o usuário
  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'email': email, 'createdAt': FieldValue.serverTimestamp()});

      Get.offAllNamed(
        '/home',
      ); // Redireciona para a página inicial após o cadastro
    } catch (e) {
      Get.snackbar('Erro', e.toString()); // Exibe um snackbar com o erro
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro ao entrar', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      Get.find<TaskController>().clearTasks();
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao sair: $e');
    }
  }
}
