import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LocalAuthentication _localAth;
  bool _isBiometricAvailable = false;
  final myController = TextEditingController();
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? username;
  String? password;

  @override
  Widget build(BuildContext context) {
    _localAth = LocalAuthentication();
    _localAth.canCheckBiometrics.then((b) {
      setState(() {
        _isBiometricAvailable = b;
      });
    });
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor('#283B71'),
        body: ProgressHUD(
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          key: UniqueKey(),
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
          ),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (event.y < -5) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Porfavor no agite el celular"),
        ));
      }
    });
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 20,
              bottom: 30,
              top: 50,
            ),
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          FormHelper.inputFieldWidget(
              context,
              prefixIcon: const Icon(Icons.person),
              showPrefixIcon: true,
              "username",
              "Username",
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Username can't be empty.";
                }
                return null;
              },
              (onSavedVal) {
                //username = onSavedVal.toString();
              },
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 10,
              onChange: (val) {
                //print(val.toString());
                username = val.toString();
              }),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(
              context,
              prefixIcon: const Icon(Icons.person),
              showPrefixIcon: true,
              "password",
              "Password",
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Password can't be empty.";
                }
                return null;
              },
              (onSavedVal) {
                password = onSavedVal.toString();
              },
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 10,
              obscureText: hidePassword,
              onChange: (val) {
                password = val.toString();
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                color: Colors.white.withOpacity(0.7),
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: FormHelper.submitButton(
              "Login",
              () {
                final docRef = FirebaseFirestore.instance
                    .collection("usuarios")
                    .where("usuario", isEqualTo: username)
                    .where("pass", isEqualTo: password)
                    .get()
                    .then(
                      (res) => {
                        if (res.docs.length > 0)
                          {Navigator.pushNamed(context, '/crud')}
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Usuario o contrase??a incorrectos"),
                            ))
                          }
                      },
                      onError: (e) => print("Error completing: $e"),
                    );
              },
              btnColor: HexColor('#283B71'),
              borderColor: Colors.white,
              txtColor: Colors.white,
              borderRadius: 10,
            ),
          ),
          Center(
              child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/map');
            },
            child: const Text('Ir Mapa'),
          )),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: IconButton(
                onPressed: () async {
                  bool didAuthenticate = await _localAth.authenticate(
                      localizedReason: "Iniciar sesion con huella");
                  if (didAuthenticate) {
                    {
                      Navigator.pushNamed(context, '/crud');
                    }
                  }
                },
                icon: Icon(
                  Icons.fingerprint,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
