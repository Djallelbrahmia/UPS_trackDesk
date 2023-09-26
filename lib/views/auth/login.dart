import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ups_trackdesk/utils/global_methodes.dart';
import 'package:ups_trackdesk/views/home_page.dart';
import 'package:ups_trackdesk/views/widget/loading_manager.dart';

import '../../utils/utils.dart';
import '../text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obsecureText = true;
  void _submitFormOnLogin() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
      } catch (e) {
        GlobalMethods.ErrorDialog(subtitle: e.toString(), context: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
      if (FirebaseAuth.instance.currentUser != null) {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(MyHomePage.routeName, (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).screenSize;

    return Scaffold(
      body: LoadingManger(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.18,
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: Image.asset(
                    "assets/img/ups_car.png",
                    fit: BoxFit.fill,
                    height: size.height * 0.2,
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: size.height * 0.1),
                Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return " Entrer votre adresse email s'il vous plait ";
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            decoration: InputDecoration(
                              hintText: "adresse email",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.7)),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              _submitFormOnLogin();
                            },
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passwordController,
                            obscureText: _obsecureText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return " Entrer le mot de passe s'il vous plait' ";
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obsecureText = !_obsecureText;
                                  });
                                },
                                child: _obsecureText
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                              hintText: "Mot de passe",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.7)),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ), //password
                          const SizedBox(
                            height: 12,
                          ),
                        ])),
                Material(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () async {
                      _submitFormOnLogin();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                            text: "Entrer",
                            color: Theme.of(context).colorScheme.secondary,
                            textsize: 24),
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            IconlyBold.login,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
