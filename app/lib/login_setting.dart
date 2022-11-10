import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';

class LoginSetting extends StatefulWidget {
  const LoginSetting({super.key});

  @override
  State<LoginSetting> createState() => _LoginSettingState();
}

class _LoginSettingState extends State<LoginSetting> {
  bool inited = false;
  String url = baseUrl;

  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!inited) {
      urlController.text = url;
      inited = true;
    }
    return Scaffold(
      appBar: titleBar('服务器配置', true),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Color(0xffffffff),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                const SizedBox(height: 89 - 64),
                const Image(image: AssetImage("images/group.png")),
                const SizedBox(height: 89),
                const Center(
                  child: Text('服务器地址配置'),
                ),
                const SizedBox(height: 20),
                Input(
                  onChanged: (value) {
                    setState(() {
                      url = value;
                    });
                  },
                  controller: urlController,
                  prefixIcon: Icons.settings,
                  borderRadius: 14,
                  iconSize: 24,
                  vertical: 19,
                  fontSize: 16,
                  iconPadding: 20,
                ),
                const SizedBox(height: 78),
                PrimaryButton(
                  '确认',
                  enabled: url.isNotEmpty,
                  onPressed: () {
                    debugPrint('||| 保存配置 $url');
                    baseUrl = url;
                    prefs.setString('baseUrl', url);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
