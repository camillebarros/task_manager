import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

 Rxn<User> user = Rxn<User>();
 
  // Método para registrar o usuário
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      Get.offAllNamed('/home');  // Redireciona para a página inicial após o cadastro
    } catch (e) {
      Get.snackbar('Erro', e.toString());  // Exibe um snackbar com o erro
    }
  }
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro ao entrar', e.toString());
    }
  }
  // Método para fazer logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/');  // Redireciona para a tela de login após o logout
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível fazer logout: ${e.toString()}');
    }
  }
}
