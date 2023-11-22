import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/auth.dart';
import 'package:provider/provider.dart';
import '../widgets/field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  static Color color = const Color.fromRGBO(17, 138, 178, 1);
  @override
  State<AuthPage> createState() => _AuthPageState();
}

//Sit dolor veniam veniam exercitation do ipsum ex aute eiusmod. Deserunt aute ullamco laboris fugiat esse. Amet sunt officia cillum proident ut aliquip anim laboris laboris. Excepteur ullamco consectetur culpa fugiat mollit magna eiusmod. Laboris non cillum est ad minim commodo ex nulla nulla cupidatat pariatur occaecat tempor ullamco. Quis proident irure tempor elit. Minim Lorem nisi ullamco ad cupidatat ex deserunt proident laboris pariatur anim ipsum nulla incididunt.

Color _buttonColor = const Color.fromRGBO(178, 57, 17, 1);

class _AuthPageState extends State<AuthPage> {
  final Map<String, String?> _authData = {
    "email": "",
    "password": "",
    'phoneNumber': '',
    'first name': '',
    'last name': '',
  };

  final userTypeButtonStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(_buttonColor.withRed(200)));

  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordController = TextEditingController();
  var radioValue = 1;

  Widget buildLabelBackground(Widget child) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15)),
        child: child,
      );

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    File? image =
        context.select<Auth, File?>((provider) => provider.image);
    DateTime now = DateTime.now();
    DateTime birthDate =
        context.select<Auth, DateTime>((provider) => provider.birthDate);
    var authMode =
        context.select<Auth, AuthMode>((provider) => provider.authMode);
    int radioGroupValue =
        context.select<Auth, int>((provider) => provider.radioGroupValue);
    bool isSignUp = authMode == AuthMode.signUp;
    bool isLoading =
        context.select<Auth, bool>((provider) => provider.isLoading);
    bool isExpert = context.select<Auth, bool>((provider) => provider.isExpert);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextStyle linkTextStyle = TextStyle(
        color: AuthPage.color,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        wordSpacing: 2);
    //List<String> specializations = ['Religion','Public Safety','Mechanical',];

    Field buildPasswordField(double screenWidth) {
      return Field(
          title: 'Password',
          isPassword: true,
          inputType: TextInputType.text,
          controller: _passwordController,
          validator: (value) {
            if (value != null) {
              if ((value.isEmpty || value.length <= 5) &&
                  authMode == AuthMode.logIn) {
                return 'Password should be at least 6 digits';
              }
              //Complete this after dealing with database
              /* else if (authMode == authMode.signUp&&value!= passwordInDB) {
                          return 'Wrong password';
                        } */
            }
            return null;
          },
          onSaved: (newValue) {
            setState(() {
              _authData['password'] = newValue;
            });
          },
          width: screenWidth * 0.6);
    }

    //  void _submit() async {
    //   //make sure the data is valid
    //   if (!_formKey.currentState!.validate()) return;
    //   //save the data after passing the condition successfully
    //   _formKey.currentState!.save();
    //   try {
    //     var userDoc = FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(_authData['email']!);
    //     var gottenUserDoc = await userDoc.get();
    //     if (gottenUserDoc.data() != null) {
    //       var data = gottenUserDoc.data()!;
    //       if (data['isAdmin'] > 0) {
    //         throw 'Create user account';
    //       }
    //       setState(() {
    //         _authData['email'] = data['email'];
    //         _authData['password'] = data['password'];
    //       });
    //       try {
    //         FirebaseAuth.instance.createUserWithEmailAndPassword(
    //             email: 'foo@bar.com', password: 'password');
    //       } catch (e) {
    //         if (e is PlatformException) {
    //           if (e.code != 'email-already-in-use') {
    //             _switchAuthMode();
    //           }
    //         }
    //       }
    //     }
    //     await Provider.of<Auth>(context, listen: false).authenticate(
    //       _authData['email']!,
    //       _authData['password']!,
    //       _authData['name']!,
    //       authMode == AuthMode.logIn,
    //     );
    //   } catch (e) {
    //     _showErrorDialog(e.toString());
    //   }
    // }

    TextButton buildSwitchAuthModeButton(TextStyle linkTextStyle) {
      return TextButton(
        onPressed: context.read<Auth>().switchAuthMode,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
        child: Text(
            '${authMode == AuthMode.logIn ? 'Create a new' : 'Already have'} account',
            style: linkTextStyle),
      );
    }

    ElevatedButton buildSubmitButton() {
      return ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(_buttonColor)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            authMode == AuthMode.logIn ? 'Log in' : 'Sign up',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      );
    }

    Column buildFields(double screenWidth) {
      return Column(
        children: [
          if (isExpert && !isSignUp) buildIdField(screenWidth),
          if (!isExpert || isSignUp) buildEmailField(screenWidth),
          buildPasswordField(screenWidth),
          if (isSignUp) buildConfirmPasswordField(screenWidth),
          if (isSignUp) buildFirstNameField(screenWidth),
          if (isSignUp) buildLastNameField(screenWidth),
          if (isSignUp) buildPhoneNumberField(screenWidth),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }

    Widget buildSelectionLabel() {
      return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('specializations')
              .doc(radioGroupValue.toString())
              .get(),
          builder: (_, future) => future.hasData
              ? buildLabelBackground(Text(
                  future.data!['name'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ))
              : const CircularProgressIndicator());
    }

    Builder buildSpecializationRadioButtons(BuildContext context) {
      return Builder(builder: (ctx) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSelectSpecButton(ctx, context),
            const SizedBox(
              width: 10,
            ),
            buildSelectionLabel()
          ],
        );
      });
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: buildBackground(
        //Use material to add elevation for form container
        buildFormBackground(
          screenWidth: screenWidth,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildUserTypeSwitch(context),
                  buildDivider(),
                  buildFields(screenWidth),
                  if (!isSignUp) buildForgotPasswordText(linkTextStyle),
                  //Display this widgets when user want to create new account
                  if (isSignUp && !isExpert)
                    buildSelectBirthDate(context, now, birthDate),
                  if (isSignUp && isExpert)
                    buildSpecializationRadioButtons(context),
                  if (isSignUp && isExpert)
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Upload your latest academic certificate (at least bachelor degree for scientific fields)',
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<Auth>().selectImage(context),
                          style: buildSelectButtonStyle(),
                          child: Text(
                            'Upload',
                            style: buildSelectButtonTextStyle(),
                          ),
                        ),
                        image == null
                            ? Container()
                            : Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border:Border.all(width: 3)
                                ,borderRadius: BorderRadius.circular(15)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.file(image,
                                fit:BoxFit.contain,),
                              ),
                            )
                      ],
                    ),
                  buildDivider(),
                  !isLoading
                      ? Column(
                          children: [
                            buildSubmitButton(),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            buildSwitchAuthModeButton(linkTextStyle),
                          ],
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildFormBackground(
      {required Widget child, required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
          elevation: 10,
          //To avoid bad corners give the same borderRadius for material and container
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: child)),
    );
  }

  Row buildSelectBirthDate(
      BuildContext context, DateTime now, DateTime birthDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: buildSelectButtonStyle(),
          onPressed: () async {
            var date = await showDatePicker(
              context: context,
              firstDate: now.subtract(const Duration(days: 365 * 70)),
              initialDate: birthDate,
              lastDate: now,
            );
            if (date != null) {
              // ignore: use_build_context_synchronously
              context.read<Auth>().setBirthDate(date);
            }
          },
          child: Text(
            'Pick birth date',
            style: buildSelectButtonTextStyle(),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        buildLabelBackground(Text(
          DateFormat('yyyy-MM-dd').format(birthDate),
        ))
      ],
    );
  }

  Widget buildBackground(Widget child) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                AuthPage.color,
              ]),
        ),
        alignment: Alignment.center,
        child: child);
  }

  ElevatedButton buildSelectSpecButton(BuildContext ctx, BuildContext context) {
    return ElevatedButton(
      style: buildSelectButtonStyle(),
      child: Column(
        children: ['Select your', ' specialization']
            .map(
              (e) => Text(e, style: buildSelectButtonTextStyle()),
            )
            .toList(),
      ),
      onPressed: () async {
        var collection = await FirebaseFirestore.instance
            .collection('specializations')
            .get();
        var docs = collection.docs;
        // ignore: use_build_context_synchronously
        showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
                  content: StatefulBuilder(builder: (_, stateFunction) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...docs.map((doc) {
                          var specialization = doc.data();
                          return RadioListTile(
                            activeColor: Colors.blue,
                            title: Text(specialization['name']),
                            value: int.parse(doc.reference.id),
                            groupValue: radioValue,
                            onChanged: (newId) {
                              stateFunction(() => radioValue = newId!);
                              context.read<Auth>().setRadioGroupValue(newId!);
                            },
                          );
                        }).toList(),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'))
                      ],
                    );
                  }),
                ));
      },
    );
  }

  TextStyle buildSelectButtonTextStyle() {
    return const TextStyle(fontSize: 16, color: Colors.black);
  }

  ButtonStyle buildSelectButtonStyle() {
    return ElevatedButton.styleFrom(
        side: BorderSide(width: 2, color: _buttonColor),
        elevation: 3,
        backgroundColor: Colors.blue);
  }

  Field buildIdField(double screenWidth) {
    return Field(
        title: 'ID',
        isPassword: false,
        inputType: TextInputType.number,
        validator: (value) {
          if (value != null && (value.isEmpty || value.length != 4)) {
            return 'Invalid ID';
          }
          return null;
        },
        onSaved: (newValue) =>
            setState(() => _authData['email'] = newValue!.trim()),
        width: screenWidth * 0.6);
  }

  Padding buildUserTypeSwitch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              style: userTypeButtonStyle,
              onPressed: () => context.read<Auth>().setIsExpert(false),
              child: const Text(
                'User',
                style: TextStyle(color: Colors.white),
              )),
          ElevatedButton(
              style: userTypeButtonStyle,
              onPressed: () => context.read<Auth>().setIsExpert(true),
              child: const Text(
                'Expert',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AuthPage.color,
      title: const Text('Ask Me'),
      centerTitle: true,
    );
  }

  Field buildPhoneNumberField(double screenWidth) {
    return Field(
        inputType: TextInputType.phone,
        title: 'Phone number',
        hint: '07 #### ####',
        validator: (value) {
          if (value != null) {
            if (value.length != 10) {
              return 'Phone number must be 10 digits';
            } else if (int.parse(value.substring(0, 2)) != 7) {
              return 'Phone number must start with 07';
            } else if (int.parse(value[2]) < 7) {
              return 'Third digit of phone number must be 7,8 or 9';
            }
            return null;
          }
          return '07 #### ####';
        },
        onSaved: (phoneNumber) =>
            setState(() => _authData['phoneNumber'] = phoneNumber),
        width: screenWidth * 0.6);
  }

  Field buildLastNameField(double screenWidth) {
    return Field(
        title: 'Last Name',
        validator: (value) {
          return value!.isEmpty ? 'Enter your last name' : null;
        },
        onSaved: (firstName) =>
            setState(() => _authData['last name'] = firstName!.trim()),
        width: screenWidth * 0.6);
  }

  Field buildFirstNameField(double screenWidth) {
    return Field(
        title: 'Frist Name',
        validator: (value) {
          return value!.isEmpty ? 'Enter your first name' : null;
        },
        onSaved: (firstName) =>
            setState(() => _authData['first name'] = firstName!.trim()),
        width: screenWidth * 0.6);
  }

  Field buildConfirmPasswordField(double screenWidth) {
    return Field(
        isPassword: true,
        title: 'Confirm password',
        validator: (value) {
          return value != _passwordController.text
              ? 'Password doesn\'t match'
              : null;
        },
        width: screenWidth * 0.6);
  }

  Padding buildForgotPasswordText(TextStyle linkTextStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(
        'Forgot password?',
        style: linkTextStyle,
      ),
    );
  }

  Field buildEmailField(double screenWidth) {
    return Field(
        title: 'Email',
        isPassword: false,
        inputType: TextInputType.emailAddress,
        validator: (value) {
          if (value != null && (value.isEmpty || !value.contains('@'))) {
            return 'Invalid email';
          }
          return null;
        },
        onSaved: (newValue) =>
            setState(() => _authData['email'] = newValue!.trim()),
        width: screenWidth * 0.6);
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occurred'),
              content: Text(message),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<Auth>(context, listen: false)
                        .setIsLoading(false);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Okay'),
                )
              ],
            ));
  }

  Widget buildDivider() {
    return const Divider(thickness: 2, color: Colors.grey, height: 50);
  }
}
