import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../database/database_helper.dart';
import '../../utilities/logger.dart';
import '../../widgets/custom_loader.dart';

class LoginController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final _auth = FirebaseAuth.instance;

  RxBool isObscurePassword = true.obs;

  void passwordStatusChange() {
    isObscurePassword.value = !isObscurePassword.value;
  }

  Future<dynamic> login(BuildContext context) async {
    customLoader.showLoader(context);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      logger.i(credential);
      User? user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic> userData = {
        'id': user!.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
      };

      await DatabaseHelper().insertUser(userData);
      //TODO: Save user credentials locally
      customLoader.hideLoader();
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      customLoader.hideLoader();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: ${e.code}'),
          duration: const Duration(seconds: 1),
        ),
      );
      logger.e(e);
      return e;
    } catch (e) {
      customLoader.hideLoader();
      logger.e(e);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign in'),
          duration: Duration(seconds: 1),
        ),
      );
      return e;
    }
  }
}
