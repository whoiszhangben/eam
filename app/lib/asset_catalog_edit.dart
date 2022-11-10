/// 新建资产分类
import 'dart:convert';

import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetCatalogEdit extends StatefulWidget {
  AssetCatalogEdit({
    super.key,
    required this.item,
  });

  final item;

  @override
  State<AssetCatalogEdit> createState() => _AssetCatalogEditState();
}

class _AssetCatalogEditState extends State<AssetCatalogEdit> {
  late var item;
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    item = jsonDecode(jsonEncode(widget.item));
    codeController.text = item['code'];
    nameController.text = item['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleBar('编辑资产分类'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // 基础信息
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 16, bottom: 14, right: 10),
                    child: Row(children: const [
                      Text(
                        "基础信息",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      Spacer(),
                    ]),
                  ),
                  Column(children: [
                    // 类型名称
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 12, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xffF53F3F),
                            ),
                          ),
                          const SizedBox(
                            width: 90,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('分类名称'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    setState(() {
                                      item['name'] = value;
                                    });
                                  },
                                  controller: nameController,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 类型代码
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 12, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xffF53F3F),
                            ),
                          ),
                          const SizedBox(
                            width: 90,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('分类编码'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    setState(() {
                                      item['code'] = value;
                                    });
                                  },
                                  controller: codeController,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 备注
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 12, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0x00F53F3F),
                            ),
                          ),
                          const SizedBox(
                            width: 90,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('备注'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    item['description'] = value;
                                  },
                                  controller: TextEditingController(
                                      text: item['description']),
                                  multiline: true,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
                ]),
              ),
              // 底部导航占位
              const SizedBox(height: 98),
            ],
          ),
          Positioned(
            // appBar: 92 bg: 98 navbar: bottomHeight shadow: 10
            top: 100.h - 92 - 98 - bottomHeight + 10,
            child: Container(
              width: 100.w,
              height: 98,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bottom_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(
                    top: 20, right: 32, left: 32, bottom: 18),
                child: PrimaryButton(
                  '提交',
                  enabled: item['name'] != '' && item['code'] != '',
                  onPressed: () async {
                    debugPrint('||| 提交 ${item}');
                    var res = await Api.catalog.modify(item);
                    if (res == 0) return;
                    SmartDialog.showToast('修改成功');
                    Navigator.pop(context, item);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
