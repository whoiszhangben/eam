/// 修改密码
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class Password extends StatefulWidget {
  Password({
    super.key,
  });

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  bool isVisible = false;
  bool isVisible2 = false;
  bool isVisible3 = false;
  String oldPassword = '';
  String pwd = '';
  String pwd2 = '';

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController pwd2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleBar('', true),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 32,
            right: 32,
            top: 21,
            bottom: 21,
          ),
          children: [
            const SizedBox(height: 21),
            const Center(
              child: Text(
                '修改密码',
                style: TextStyle(
                  fontSize: 24,
                  height: 32 / 20,
                ),
              ),
            ),
            const SizedBox(height: 41),
            Input(
              onChanged: (value) {
                setState(() {
                  oldPassword = value;
                });
              },
              controller: oldPasswordController,
              obscureText: !isVisible3,
              borderRadius: 14,
              iconSize: 24,
              vertical: 19,
              fontSize: 16,
              iconPadding: 20,
              prefixIcon: Icons.lock,
              suffixIcon: isVisible3 ? Icons.visibility : Icons.visibility_off,
              onPressedSuffixIcon: () {
                setState(() {
                  isVisible3 = !isVisible3;
                });
              },
              hintText: '请输入原始密码',
            ),
            const SizedBox(height: 10),
            Input(
              onChanged: (value) {
                setState(() {
                  pwd = value;
                });
              },
              controller: pwdController,
              obscureText: !isVisible,
              borderRadius: 14,
              iconSize: 24,
              vertical: 19,
              fontSize: 16,
              iconPadding: 20,
              prefixIcon: Icons.lock,
              suffixIcon: isVisible ? Icons.visibility : Icons.visibility_off,
              onPressedSuffixIcon: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              hintText: '请输入新密码',
            ),
            const SizedBox(height: 10),
            Input(
              onChanged: (value) {
                pwd2 = value;
              },
              controller: pwd2Controller,
              obscureText: !isVisible2,
              borderRadius: 14,
              iconSize: 24,
              vertical: 19,
              fontSize: 16,
              iconPadding: 20,
              prefixIcon: Icons.lock,
              suffixIcon: isVisible2 ? Icons.visibility : Icons.visibility_off,
              onPressedSuffixIcon: () {
                setState(() {
                  isVisible2 = !isVisible2;
                });
              },
              hintText: '再次输入新密码',
            ),
            PrimaryButton(
              '确认',
              enabled: pwd.isNotEmpty && oldPassword.isNotEmpty,
              margin: const EdgeInsets.only(top: 50),
              onPressed: () async {
                debugPrint('||| 修改密码');

                FocusManager.instance.primaryFocus?.unfocus();
                if (!verify(pwd, pwd2)) return;

                var res = await Api.account.password(pwd, oldPassword);
                if (res == 0) return;

                // 如果是记住密码，则更新已记住密码
                String? password = prefs.getString('password');
                if (password != null) {
                  prefs.setString('password', pwd);
                }
                await alert(context, '提示', '密码修改成功');

                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}

verify(pwd, pwd2) {
  String msg = '';

  if (pwd != pwd2) {
    msg = '密码不一致';
  }

  if (msg != '') {
    SmartDialog.showToast(msg);
  }
  return msg == '';
}
