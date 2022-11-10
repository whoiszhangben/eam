/// 新建资产分类
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetCatalogChildAdd extends StatefulWidget {
  AssetCatalogChildAdd(
    this.parent, {
    super.key,
  });

  var parent;

  @override
  State<AssetCatalogChildAdd> createState() => _AssetCatalogChildAddState();
}

class _AssetCatalogChildAddState extends State<AssetCatalogChildAdd> {
  String code = '';
  String name = '';
  String description = '';
  double width = 80;
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('parent: ${widget.parent}');

    return Scaffold(
      appBar: titleBar('新建资产分类'),
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
                    // 总分类
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 12, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0x00F53F3F),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Text('总分类'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  disabled: true,
                                  onChanged: (value) {
                                    name = value;
                                  },
                                  controller: TextEditingController(
                                      text: widget.parent['name']),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
                          SizedBox(
                            width: width,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Text('子分类名称'),
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
                                      name = value;
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
                          SizedBox(
                            width: width,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Text('子分类编码'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(children: [
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 80),
                                    child: Text(
                                      '${widget.parent['code']}-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Input(
                                      onChanged: (value) {
                                        setState(() {
                                          code = value;
                                        });
                                      },
                                      controller: codeController,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
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
                          SizedBox(
                            width: width,
                            child: const Align(
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
                                    description = value;
                                  },
                                  controller:
                                      TextEditingController(text: description),
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
                  enabled: code != '' && name != '',
                  onPressed: () async {
                    debugPrint('||| 提交 $code $name $description');
                    var item = {
                      'gsortid': widget.parent['id'],
                      'code': code,
                      'name': name,
                      'description': description
                    };
                    var res = await Api.catalogChild.add(item);
                    if (res == 0) return;
                    SmartDialog.showToast('添加成功');
                    Navigator.pop(context, res['data']);
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
