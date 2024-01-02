// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:ask_me2/models/admin_provider.dart';
import 'package:ask_me2/pages/user_pages/categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ask_me2/utils.dart';
import 'package:intl/intl.dart';
import '../models/auth.dart';
import 'package:provider/provider.dart';
import '../widgets/field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final userTypeButtonStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(buttonColor.withRed(200)));
  final idController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
    passwordController.dispose();
    //formKey.currentState!.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    bool isSignUp = auth.authMode == AuthMode.signUp;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextStyle linkTextStyle = const TextStyle(
        color: themeColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        wordSpacing: 2);

    Field buildPasswordField(double screenWidth) {
      List<String> characters = List.generate(
              26, (index) => String.fromCharCode('a'.codeUnitAt(0) + index)) +
          List.generate(
              26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index)) +
          ['!', '@', '#', '\$', '%', '^', '&', '*'];
      return Field(
          title: 'كلمة السر',
          isPassword: true,
          inputType: TextInputType.text,
          controller: passwordController,
          validator: (value) {
            if (value != null && isSignUp) {
              String errorMessage = '';
              if (value.isEmpty || value.length < 6) {
                showMyDialog('يجب أن تكون كلمة السر مكونة من 6 خانات على الأقل',
                    context);
                return errorMessage;
              } else if (value
                  .split('')
                  .toSet()
                  .intersection(characters.toSet())
                  .isEmpty) {
                showMyDialog(
                    'يجب أن تحتوي كلمة السر على رمز واحد أو حرف انجليزي واحد على الأقل',
                    context);
                return errorMessage;
              }
            }
            return null;
          },
          onSaved: (newValue) {
            auth.addAuthData('password', newValue!);
          },
          width: screenWidth * 0.6);
    }

    TextButton buildSwitchAuthModeButton(TextStyle linkTextStyle) {
      return TextButton(
        onPressed: auth.switchAuthMode,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
        child: Text(!isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
            style: linkTextStyle),
      );
    }

    //TODO: put all validations on input here in this method, don't keep any validations in authinticate()
    void validate() async {
      //make sure the data is valid
      if (!formKey.currentState!.validate()) return;
      //save the data after passing the condition successfully
      auth.setIsLoading(true);
      formKey.currentState!.save();
      try {
        if (isSignUp && auth.isExpert) {
          if (auth.radioGroupValue == 0) {
            showMyDialog('يجب أن تختار تخصصك', context);
            auth.setIsLoading(false);
            return;
          }
          var newComersCollection = (await FirebaseFirestore.instance
              .collection('experts')
              .doc('new comers')
              .collection('experts')
              .get());
          var verifiedCollection = (await FirebaseFirestore.instance
              .collection('experts')
              .doc('verified')
              .collection('experts')
              .get());
          bool isEmailUsed = newComersCollection.docs
                  .where((expert) =>
                      expert.data()['email'] == auth.authData['email'])
                  .isNotEmpty ||
              verifiedCollection.docs
                  .where((expert) =>
                      expert.data()['email'] == auth.authData['email'])
                  .isNotEmpty;

          if (auth.pickedFile == null) {
            showMyDialog(
              'يجب أن تقوم بتحميل شهادتك',
              context,
            );
          } else if (isEmailUsed) {
            showMyDialog(
              'الايميل مُستخدم مسبقاً',
              context,
            );
          } else if (newComersCollection.docs
                  .where((expert) =>
                      expert.data()['phoneNumber'] ==
                      auth.authData['phoneNumber'])
                  .isNotEmpty ||
              verifiedCollection.docs
                  .where((expert) =>
                      expert.data()['phoneNumber'] ==
                      auth.authData['phoneNumber'])
                  .isNotEmpty) {
            showMyDialog(
              'رقم الهاتف مُستخدم مسبقاً',
              context,
            );
          }else{
            auth.authenticate(context);
          formKey.currentState!.reset();
          }
        }
        //SignUp user
        else if (isSignUp && !auth.isExpert) {
          var usersCollection =
              (await FirebaseFirestore.instance.collection('users').get());
          var list = usersCollection.docs
              .where((user) => user.data()['email'] == auth.authData['email']);
          if (list.isNotEmpty) {
            showMyDialog('الايميل مُستخدم مسبقاً', context);
          } else {
             auth.authenticate(context);
          }
        }
        //Login Expert
        else if (!isSignUp && auth.isExpert) {
          if (idController.text == adminId) {
             auth.authenticate(context);
          } else {
            var expert = (await FirebaseFirestore.instance
                    .collection('experts')
                    .doc('verified')
                    .collection('experts')
                    .doc(idController.text)
                    .get())
                .data();

            if (expert != null && expert['isSuspended']) {
              showMyDialog(
                'حسابك معّطل',
                context,
              );
            } else {
               auth.authenticate(context);
            }
          }
        }
        //Login user
        else if (!isSignUp && !auth.isExpert) {
           auth.authenticate(context);
        }
        auth.setIsLoading(false);
      } catch (e) {
        auth.setIsLoading(false);
        showMyDialog(
          e.toString(),
          context,
        );
      }
      
    }

    ElevatedButton buildSubmitButton() {
      return ElevatedButton(
        onPressed: validate,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(buttonColor)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            !isSignUp ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      );
    }

    Column buildFields(double screenWidth) {
      return Column(
        children: [
          if (auth.isExpert && !isSignUp) buildIdField(screenWidth),
          if (!auth.isExpert || isSignUp) buildEmailField(screenWidth),
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
      return auth.radioGroupValue == 0
          ? buildLabelBackground(const SizedBox(
              height: 30,
              width: 30,
            ))
          : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('specializations')
                  .doc(auth.radioGroupValue.toString())
                  .get(),
              builder: (_, future) => future.hasData
                  ? buildLabelBackground(Text(
                      future.data!['name'],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ))
                  : const CircularProgressIndicator(),
            );
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

    return SafeArea(
      child: buildOfflineWidget(
        isOfflineWidgetWithScaffold: true,
          onlineWidget: Scaffold(
          appBar: buildAppBar(),
          body: buildBackground(
            //Use material to add elevation for form container
            buildFormBackground(
              screenWidth: screenWidth,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildUserTypeSwitch(context),
                      buildDivider(),
                      buildFields(screenWidth),
                      if (!isSignUp) buildForgotPasswordText(linkTextStyle),
                      //Display this widgets when user want to create new account
                      if (isSignUp && !auth.isExpert)
                        buildSelectBirthDate(
                            context, DateTime.now(), auth.birthDate),
                      if (isSignUp && auth.isExpert)
                        buildSpecializationRadioButtons(context),
                      if (isSignUp && auth.isExpert)
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'آخر درجة علمية لك, يجب أن تكون شهادة بكالوريوس على الأقل إذا كنت تنوي دخول مجال علمي',
                                maxLines: 3,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                            auth.pickedFile == null
                                ? ElevatedButton(
                                    onPressed: () async => context
                                        .read<Auth>()
                                        .setPickedFile(
                                            await selectFile(true, context)),
                                    style: buildSelectButtonStyle(),
                                    child: Text(
                                      'تحميل',
                                      style: buildSelectButtonTextStyle(),
                                    ),
                                  )
                                : Container(),
                            auth.pickedFile == null
                                ? Container()
                                : Wrap(
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Text(auth.pickedFile!.name),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        // Remove the selected file
                                        onPressed: () => context
                                            .read<Auth>()
                                            .setPickedFile(null),
                                      )
                                    ],
                                  )
                          ],
                        ),
                      buildDivider(),
                      !auth.isLoading
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
        ),
      ),
    );
  }

  Widget buildFormBackground(
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
            'حدد تاريخ ميلادك',
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
                themeColor,
              ]),
        ),
        alignment: Alignment.center,
        child: child);
  }

  ElevatedButton buildSelectSpecButton(BuildContext ctx, BuildContext context) {
    return ElevatedButton(
      style: buildSelectButtonStyle(),
      child: Column(
        children: ['اختر', ' تخصصك']
            .map(
              (e) => Text(e, style: buildSelectButtonTextStyle()),
            )
            .toList(),
      ),
      onPressed: () async {
        QuerySnapshot<Map<String, dynamic>> collection = await FirebaseFirestore
            .instance
            .collection('specializations')
            .get();
        var specializations = collection.docs;
        // ignore: use_build_context_synchronously
        showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
                  content: StatefulBuilder(builder: (_, stateFunction) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...specializations.map((doc) {
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
                        }),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('اغلاق'))
                      ],
                    );
                  }),
                ));
      },
    );
  }

  Field buildIdField(double screenWidth) {
    return Field(
        title: 'معرف المستخدم',
        isPassword: false,
        controller: idController,
        inputType: TextInputType.number,
        validator: (value) {
          if (value != null && (value.isEmpty /*|| value.length != 4*/)) {
            return 'معرف المسختدم غير صحيح';
          }
          return null;
        },
        onSaved: (newValue) {
          idController.text = newValue!;
          context.read<Auth>().addAuthData('ID', newValue);
        },
        width: screenWidth * 0.6);
  }

  Padding buildUserTypeSwitch(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Consumer<Auth>(
          builder: (_, provider, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'مستخدم',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: !provider.isExpert ? 22 : 14,
                      fontWeight: !provider.isExpert ? FontWeight.bold : null),
                ),
                Switch(
                    activeColor: Colors.blue,
                    value: provider.isExpert,
                    onChanged: (value) {
                      provider.setIsExpert(value);
                    }),
                Text(
                  'خبير',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: provider.isExpert ? 22 : 14,
                      fontWeight: provider.isExpert ? FontWeight.bold : null),
                )
              ],
            );
          },
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Ask Me'),
      actions: [
        Consumer<Auth>(
          builder: (_, provider, __) => provider.isLoading
              ? Container()
              : IconButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => CategoriesPage())),
                  icon: const Icon(Icons.close),
                ),
        ),
      ],
    );
  }

  Field buildPhoneNumberField(double screenWidth) {
    return Field(
        inputType: TextInputType.phone,
        title: 'رقم الهاتف',
        hint: '07 #### ####',
        validator: (value) {
          if (value != null) {
            if (value.length != 10) {
              return 'يجب أن يحتوي الرقم على 10 أرقام';
            } else if (int.parse(value.substring(0, 2)) != 7) {
              return 'يجب أن يبدأ رقم الهاتف ب07';
            } else if (int.parse(value[2]) < 7) {
              return 'يجب أن يكون الرقم الثالث إما 7 أو 8 أو 9';
            }
            return null;
          }
          return '07 #### ####';
        },
        onSaved: (phoneNumber) => context
            .read<Auth>()
            .addAuthData('phoneNumber', phoneNumber!.trim()),
        width: screenWidth * 0.6);
  }

  Field buildLastNameField(double screenWidth) {
    return Field(
        title: 'اسم العائلة',
        validator: (value) {
          return value!.isEmpty ? 'ادخل اسم العائلة' : null;
        },
        onSaved: (lastName) =>
            context.read<Auth>().addAuthData('last name', lastName!.trim()),
        width: screenWidth * 0.6);
  }

  Field buildFirstNameField(double screenWidth) {
    return Field(
        title: 'الاسم الأول',
        validator: (value) {
          return value!.isEmpty ? 'ادخل اسمك الأول' : null;
        },
        onSaved: (firstName) =>
            context.read<Auth>().addAuthData('first name', firstName!.trim()),
        width: screenWidth * 0.6);
  }

  Field buildConfirmPasswordField(double screenWidth) {
    return Field(
        isPassword: true,
        title: 'تأكيد كلمة السر',
        validator: (value) {
          return value != passwordController.text
              ? 'كلمة السر غير متطابقة'
              : null;
        },
        width: screenWidth * 0.6);
  }

  Padding buildForgotPasswordText(TextStyle linkTextStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(
        'هل نسيت كلمة السر؟',
        style: linkTextStyle,
      ),
    );
  }

  Field buildEmailField(double screenWidth) {
    return Field(
        controller: emailController,
        title: 'الايميل',
        isPassword: false,
        inputType: TextInputType.emailAddress,
        validator: (value) {
          if (value != null && (value.isEmpty || !value.contains('@'))) {
            return 'الايميل غير صحيح';
          }
          return null;
        },
        onSaved: (newValue) =>
            context.read<Auth>().addAuthData('email', newValue!.trim()),
        width: screenWidth * 0.6);
  }

  Widget buildDivider() {
    return const Divider(thickness: 2, color: Colors.grey, height: 50);
  }
}
