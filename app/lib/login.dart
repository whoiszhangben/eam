/// 登录
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/login_setting.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool inited = false;
  bool isRemember = false;
  bool isVisible = false;
  String account = '';
  String password = '';

  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (bottomHeight == 0 && MediaQuery.of(context).padding.bottom != 0) {
      bottomHeight = MediaQuery.of(context).padding.bottom;
      print('bottomHeight $bottomHeight');
    }

    if (!inited) {
      String? id = prefs.getString('account');
      String? pwd = prefs.getString('password');
      account = id ?? '';
      password = pwd ?? '';
      isRemember = pwd != null;
      accountController.text = account;
      passwordController.text = password;
      inited = true;
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0XFFFFFFFF),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                const SizedBox(height: 89),
                const Image(image: AssetImage("images/group.png")),
                const SizedBox(height: 53),
                SizedBox(
                  height: 60,
                  child: Input(
                    onChanged: (value) {
                      setState(() {
                        account = value;
                      });
                    },
                    controller: accountController,
                    prefixIcon: Icons.person_sharp,
                    borderRadius: 14,
                    iconSize: 24,
                    vertical: 19,
                    fontSize: 16,
                    iconPadding: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Input(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  controller: passwordController,
                  prefixIcon: Icons.lock,
                  borderRadius: 14,
                  iconSize: 24,
                  vertical: 19,
                  fontSize: 16,
                  iconPadding: 20,
                  obscureText: !isVisible,
                  suffixIcon:
                      isVisible ? Icons.visibility : Icons.visibility_off,
                  onPressedSuffixIcon: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool? value) {
                          setState(() {
                            isRemember = value!;
                          });
                        },
                        selected: false,
                        value: isRemember,
                        title: const Text("记住密码"),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  '登录',
                  enabled: account.isNotEmpty && password.isNotEmpty,
                  onPressed: () async {
                    debugPrint('||| 登录');

                    FocusManager.instance.primaryFocus?.unfocus();
                    if (isRemember) {
                      prefs.setString('account', account);
                      prefs.setString('password', password);
                    } else {
                      prefs.remove('account');
                      prefs.remove('password');
                    }
                    var res = await Api.account.login(account, password);
                    if (res == 0) return;
                    Navigator.of(context).popAndPushNamed('index');
                  },
                ),
              ],
            ),
          ),

          // 服务器配置
          Positioned(
            top: 56,
            right: 12,
            child: IconButton(
              onPressed: () {
                debugPrint('||| setting');

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginSetting(),
                  ),
                );
              },
              iconSize: 24,
              icon: Image.asset('images/setting.png'),
            ),
          ),
        ],
      ),
    );
  }
}
