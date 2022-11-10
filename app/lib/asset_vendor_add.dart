/// 新建资产分类
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetVendorAdd extends StatefulWidget {
  AssetVendorAdd({
    super.key,
  });

  @override
  State<AssetVendorAdd> createState() => _AssetVendorAddState();
}

class _AssetVendorAddState extends State<AssetVendorAdd> {
  String name = '';
  String phone = '';
  String addr = '';
  String description = '';
  double width = 82;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = name;
    phoneController.text = phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleBar('新建供应商'),
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
                    // 供应商名称
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
                              child: Text('供应商名称'),
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
                    // 电话号码
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
                              child: Text('电话号码'),
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
                                      phone = value;
                                    });
                                  },
                                  controller: phoneController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 地址信息
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
                              child: Text('地址信息'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    addr = value;
                                  },
                                  controller: TextEditingController(text: addr),
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
                  enabled: name.isNotEmpty && phone.isNotEmpty,
                  onPressed: () async {
                    debugPrint('||| 提交 $name $phone $addr $description');

                    var item = {
                      'name': name,
                      'phone': phone,
                      'addr': addr,
                      'description': description,
                    };
                    var res = await Api.vendor.add(item);
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
