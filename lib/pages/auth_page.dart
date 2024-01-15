// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:animated_text_kit/animated_text_kit.dart';
import '../../utils/local_data.dart';
import '../../pages/expert_pages/expert_page.dart';
import '../../pages/user_pages/user_page.dart';
import '../../pages/user_pages/categories.dart';
import '../../widgets/offlineWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/tools.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import '../models/admin.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';
import '../utils/transition.dart';
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
  final linkTextStyle = const TextStyle(
      color: themeColor,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      wordSpacing: 2);

  int radioValue = 1;
  double screenWidth = WidgetsBinding
          .instance.platformDispatcher.views.first.physicalSize.width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  late double fieldWidth;

  @override
  void initState() {
    super.initState();
    fieldWidth = screenWidth * 0.6;
  }

  @override
  void dispose() {
    passwordController.dispose();
    //formKey.currentState!.reset();
    super.dispose();
  }

  Widget buildLabelBackground(Widget child) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15)),
        child: child,
      );

  Widget buildFormBackground({required Widget child}) {
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
            final date = await showDatePicker(
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
        final specializations = collection.docs;
        // ignore: use_build_context_synchronously
        showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
                  content: StatefulBuilder(builder: (_, stateFunction) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...specializations.map((doc) {
                          final specialization = doc.data();
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

  Field buildIdField() {
    return Field(
        title: 'معرف المستخدم',
        isPassword: false,
        controller: idController,
        inputType: TextInputType.number,
        validator: (value) {
          if (value != null && (value.isEmpty)) {
            return 'ممنوع  ترك معرف المستخدم فارغ';
          }
          return null;
        },
        onSaved: (newValue) {
          idController.text = newValue!;
          context.read<Auth>().addAuthData('ID', newValue);
        },
        width: fieldWidth);
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
                  style: userTypeTextStyle(isExpert: !provider.isExpert),
                ),
                Switch(
                    activeColor: Colors.blue,
                    value: provider.isExpert,
                    onChanged: (value) {
                      provider.setIsExpert(value);
                    }),
                Text(
                  'خبير',
                  style: userTypeTextStyle(isExpert: provider.isExpert),
                )
              ],
            );
          },
        ));
  }

  TextStyle userTypeTextStyle({bool isExpert = true}) {
    return TextStyle(
        color: Colors.black,
        fontSize: isExpert ? 22 : 14,
        fontWeight: isExpert ? FontWeight.bold : null);
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
                      CustomPageRoute(builder: (_) => CategoriesPage())),
                  icon: const Icon(Icons.close),
                ),
        ),
      ],
    );
  }

  Field buildPhoneNumberField() {
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
        width: fieldWidth);
  }

  Field buildLastNameField() {
    return Field(
      title: 'اسم العائلة',
      validator: (value) {
        return value!.isEmpty ? 'ادخل اسم العائلة' : null;
      },
      onSaved: (lastName) =>
          context.read<Auth>().addAuthData('last name', lastName!.trim()),
      width: fieldWidth,
      isDirectionRtl: true,
    );
  }

  Field buildFirstNameField() {
    return Field(
      title: 'الاسم الأول',
      validator: (value) {
        return value!.isEmpty ? 'ادخل اسمك الأول' : null;
      },
      onSaved: (firstName) =>
          context.read<Auth>().addAuthData('first name', firstName!.trim()),
      width: fieldWidth,
      isDirectionRtl: true,
    );
  }

  Field buildPasswordField(bool isSignUp, Function(String? value) onSaved) {
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
          if (value == null || value.isEmpty) {
            return 'كلمة السر فارغة';
          }

          if (isSignUp) {
            String errorMessage = '';
            if (value.length < 6) {
              showMyDialog(
                  'يجب أن تكون كلمة السر مكونة من 6 خانات على الأقل', context);
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
        onSaved: onSaved,
        width: fieldWidth);
  }

  Field buildConfirmPasswordField({TextEditingController? controller}) {
    return Field(
        controller: controller,
        isPassword: true,
        title: 'تأكيد كلمة السر',
        validator: (value) {
          return value != passwordController.text
              ? 'كلمة السر غير متطابقة'
              : null;
        },
        width: fieldWidth);
  }

  Padding buildForgotPassword(TextStyle linkTextStyle, BuildContext context) {
    final forgotPasswardFromKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextButton(
        onPressed: () => showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) =>
              Consumer<Auth>(builder: (context, provider, child) {
            void sendCode() async {
              if (!forgotPasswardFromKey.currentState!.validate()) {
                return;
              }
              provider.setIsFrogotButtonLoading(true);
              forgotPasswardFromKey.currentState!.save();
              final doc = (await getUser(provider.email, provider.isExpert));
              if (doc == null) {
                provider.setEmailNotExist(true);
                provider.setIsFrogotButtonLoading(false);
                return;
              }
              provider.setEmailNotExist(false);
              final data = doc.data();
              provider.setAuthData(data);
              if (provider.isExpert) {
                writeID(doc.id);
              } else {
                writeEmial(provider.email);
              }
              writeName(data['first name'] + ' ' + data['last name']);

              provider.setCode(randomNumeric(6));
              sendEmail(
                to: provider.email,
                subject: 'Ask Me رمز تأكيد حسابك في تطبيق',
                text: 'رمز التأكيد هو : ${provider.code}',
              );
              provider.setIsFrogotButtonLoading(false);
              provider.setIsCodeSent(true);
            }

            void updatePassword() async {
              if (!forgotPasswardFromKey.currentState!.validate()) {
                return;
              }
              provider.setIsFrogotButtonLoading(true);
              forgotPasswardFromKey.currentState!.save();
              final expert = (await expertsCollection
                      .doc('verified')
                      .collection('experts')
                      .get())
                  .docs
                  .firstWhere((element) => element['email'] == provider.email);
              if (provider.isExpert) {
                await expertsCollection
                    .doc('verified')
                    .collection('experts')
                    .doc(expert.id)
                    .update({'password': passwordController.text});
              } else {
                await usersCollection
                    .doc(provider.email)
                    .update({'password': passwordController.text});
              }

              displaySnackBar(
                context,
                text: 'تم تغيير كلمة السر',
                snackBarColor: Colors.green[300],
              );

              //Use Future.delayed() so the user can ensure that password has been changed successfully
              //then after 2 seconds move to the home page
              await Future.delayed(const Duration(seconds: 2));
              provider.setIsFrogotButtonLoading(false);
              provider.clearForgotPasswordData();
              if (provider.isExpert) {
                writeID(expert.id);
                writeName(expert.data()['first name'] +
                    ' ' +
                    expert.data()['last name']);
              } else {
                final user =
                    (await usersCollection.doc(provider.email).get()).data();

                writeName(user!['first name'] + ' ' + user['last name']);
                writeEmial(provider.email);
              }
              while (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(
                  context,
                  CustomPageRoute(
                      builder: (_) => provider.isExpert
                          ? const ExpertPage()
                          : const UserPage()));
            }

            return AlertDialog(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    provider.isExpert ? 'خبير' : 'مستخدم',
                    style: userTypeTextStyle(),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        (provider.isExpert ? 0.17 : 0.13),
                  ),
                  IconButton(
                    onPressed: () {
                      forgotPasswardFromKey.currentState!.reset();
                      emailController.clear();
                      provider.clearForgotPasswordData();
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!provider.isCodePassed)
                    Text(provider.isCodeSent
                        ? 'تم إرسال الرمز'
                        : 'سنقوم بإرسال رمز إلى ايميلك للتحقق من هويتك'),
                  Form(
                    key: forgotPasswardFromKey,
                    child: provider.isCodePassed
                        ? Column(
                            children: [
                              buildPasswordField(
                                  provider.isSignUp,
                                  (newValue) => provider.addAuthData(
                                      'password', newValue!)),
                              buildConfirmPasswordField(
                                controller: TextEditingController(text: ''),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              buildEmailField(true),
                              if (provider.emailNotExist)
                                AnimatedTextKit(
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'الايميل غير صحيح',
                                      speed: const Duration(milliseconds: 50),
                                      textStyle: const TextStyle(
                                          color: Colors.red, fontSize: 15),
                                      colors: [
                                        Colors.red,
                                        Colors.yellow,
                                        Colors.blue
                                      ],
                                    )
                                  ],
                                  isRepeatingAnimation: true,
                                ),
                              if (provider.isCodeSent)
                                Field(
                                  title: 'رمز التأكيد',
                                  inputType: TextInputType.number,
                                  width: fieldWidth,
                                  validator: (value) {
                                    if (value != null &&
                                        provider.code.compareTo(value) == 0) {
                                      passwordController.clear();
                                      provider.setIsCodePassed(true);
                                      return null;
                                    } else {
                                      return 'الرمز غير صحيح';
                                    }
                                  },
                                ),
                            ],
                          ),
                  ),
                  provider.isFrogotButtonLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed:
                              provider.isCodePassed ? updatePassword : sendCode,
                          style: buildButtonStyle(
                              condition: false,
                              color: const Color.fromARGB(255, 68, 138, 255)),
                          child: Text(
                            provider.isCodePassed
                                ? 'تغيير كلمة السر'
                                : provider.isCodeSent
                                    ? 'تحقق'
                                    : 'إرسال الرمز',
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                ],
              ),
            );
          }),
        ),
        child: Text(
          'هل نسيت كلمة السر؟',
          style: linkTextStyle,
        ),
      ),
    );
  }

  Field buildEmailField(bool isUsedInForgotPassword) {
    return Field(
        controller: emailController,
        title: 'الايميل',
        isPassword: false,
        inputType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الايميل فارغ';
          } else if (!value.contains('@')) {
            return 'الايميل غير صحيح';
          }
          return null;
        },
        onSaved: (newValue) => isUsedInForgotPassword
            ? context.read<Auth>().setEmail(newValue!)
            : context.read<Auth>().addAuthData('email', newValue!.trim()),
        width: fieldWidth);
  }

  Widget buildDivider() {
    return const Divider(thickness: 2, color: Colors.grey, height: 50);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<Auth>();
    double screenHeight = MediaQuery.of(context).size.height;

    TextButton buildSwitchAuthModeButton(TextStyle linkTextStyle) {
      return TextButton(
        onPressed: auth.switchAuthMode,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
        child: Text(!auth.isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
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
        if (auth.isSignUp && auth.isExpert) {
          if (auth.radioGroupValue == 0) {
            showMyDialog('يجب أن تختار تخصصك', context);
            auth.setIsLoading(false);
            return;
          }
          final newComersCollection = (await expertsCollection
              .doc('new comers')
              .collection('experts')
              .get());
          final verifiedCollection = (await expertsCollection
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
          } else {
            await auth.authenticate(context);
            formKey.currentState!.reset();
            emailController.clear();
            passwordController.clear();
          }
        }
        //SignUp user
        else if (auth.isSignUp && !auth.isExpert) {
          final users = (await usersCollection.get());
          final list = users.docs
              .where((user) => user.data()['email'] == auth.authData['email']);
          if (list.isNotEmpty) {
            showMyDialog('الايميل مُستخدم مسبقاً', context);
          } else {
            await auth.authenticate(context);
          }
        }
        //Login Expert
        else if (!auth.isSignUp && auth.isExpert) {
          if (idController.text == Admin.id) {
            await auth.authenticate(context);
          } else {
            final expert = (await expertsCollection
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
              await auth.authenticate(context);
            }
          }
        }
        //Login user
        else if (!auth.isSignUp && !auth.isExpert) {
          await auth.authenticate(context);
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
            !auth.isSignUp ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      );
    }

    Column buildFields() {
      return Column(
        children: [
          if (auth.isExpert && !auth.isSignUp) buildIdField(),
          if (!auth.isExpert || auth.isSignUp) buildEmailField(false),
          buildPasswordField(auth.isSignUp,
              (newValue) => auth.addAuthData('password', newValue!)),
          if (auth.isSignUp) buildConfirmPasswordField(),
          if (auth.isSignUp) buildFirstNameField(),
          if (auth.isSignUp) buildLastNameField(),
          if (auth.isSignUp) buildPhoneNumberField(),
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

    return Stack(children: [
      SafeArea(
        child: OfflineWidget(
          //isOfflineWidgetWithScaffold: true,
          onlineWidget: Scaffold(
            appBar: buildAppBar(),
            body: buildBackground(
              //Use material to add elevation for form container
              buildFormBackground(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildUserTypeSwitch(context),
                        buildDivider(),
                        buildFields(),
                        if (!auth.isSignUp)
                          buildForgotPassword(linkTextStyle, context),
                        //Display this widgets when user want to create new account
                        if (auth.isSignUp && !auth.isExpert)
                          buildSelectBirthDate(
                              context, DateTime.now(), auth.birthDate),
                        if (auth.isSignUp && auth.isExpert)
                          buildSpecializationRadioButtons(context),
                        if (auth.isSignUp && auth.isExpert)
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'آخر درجة علمية لك, يجب أن تكون شهادة بكالوريوس على الأقل إذا كنت تنوي دخول مجال علمي',
                                  maxLines: 3,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
      ),
      if (auth.isFrogotButtonLoading)
        GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        )
    ]);
  }
}
