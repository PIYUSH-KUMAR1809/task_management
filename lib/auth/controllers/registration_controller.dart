import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../database/database_helper.dart';
import '../../utilities/logger.dart';
import '../../widgets/custom_loader.dart';

class RegistrationController extends GetxController {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  RxBool isObscurePassword = true.obs;
  RxBool isObscureConfirmPassword = true.obs;

  final _auth = FirebaseAuth.instance;

  void passWordStatusChange() {
    isObscurePassword.value = !isObscurePassword.value;
  }

  void confirmPasswordStatusChange() {
    isObscureConfirmPassword.value = !isObscureConfirmPassword.value;
  }

  Future<dynamic> signUp(BuildContext context) async {
    customLoader.showLoader(context);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      // Here you can store the user's additional information like username
      User? user = userCredential.user;
      if (user != null) {
        await user.updateProfile(displayName: name.text);
        await user.reload();
        user = _auth.currentUser;

        await user!.updateProfile(displayName: name.text);
        logger.i(user.toString());

        Map<String, dynamic> userData = {
          'id': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        };

        await DatabaseHelper().insertUser(userData);
        //TODO: Save user credentials locally
        customLoader.hideLoader();
        Get.offAllNamed('/home');
      }
      logger.i(user);
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
          content: Text('Failed to sign up'),
          duration: Duration(seconds: 1),
        ),
      );
      return e;
    }
  }
}
