/// 资产转让确认
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:date_format/date_format.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetTransferEnter extends StatefulWidget {
  AssetTransferEnter({
    super.key,
    required this.list,
  });

  var list;

  @override
  State<AssetTransferEnter> createState() => _AssetTransferEnterState();
}

class _AssetTransferEnterState extends State<AssetTransferEnter> {
  bool inited = false;
  // 使用人
  String custodian = '';
  // 使用部门
  var orgId = '';
  // 日期
  DateTime date = DateTime.now();
  // 位置
  String savelocation = '';
  // 流水备注
  String fdescription = '';
  final DateTime today = DateTime.now();

  // 购买部门下拉选择
  Map<String, String> orgMap = {'': ''};
  List<DropdownMenuItem<String>> orgs = buildDropdownMenuItems([
    {'id': '', 'name': '加载中...'},
  ]);
  late List list;
  @override
  Widget build(BuildContext context) {
    if (!inited) {
      list = clone(widget.list);
      (() async {
        // 部门选择列表
        var org = [
          {'id': '', 'name': '请选择'},
          ...await orgList(),
        ];
        var orgItems = buildDropdownMenuItems([
          ...org,
        ]);
        orgMap = toMap(org);

        setState(() {
          orgs = orgItems;
        });
      })();
      inited = true;
    }

    return Scaffold(
      appBar: titleBar('资产转让'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 16, bottom: 14, right: 10),
                    child: Row(children: const [
                      Text(
                        "当前选择资产",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      Spacer(),
                    ]),
                  ),
                  // 资产名称
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                            child: Text('资产名称'),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Input(
                                enabled: false,
                                controller: TextEditingController(
                                  text: list
                                      .map((row) {
                                        var item = row['data'];
                                        return item['name'];
                                      })
                                      .toList()
                                      .join(','),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
              ),
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 16, bottom: 14, right: 10),
                    child: Row(children: const [
                      Text(
                        "转让信息",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      Spacer(),
                    ]),
                  ),
                  Column(children: [
                    // 使用人
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
                              child: Text('使用人'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    custodian = value;
                                  },
                                  controller:
                                      TextEditingController(text: custodian),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 使用部门
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
                              child: Text('部门'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    customButton: Input(
                                      enabled: false,
                                      normalBorder: true,
                                      controller: TextEditingController(
                                          text: orgMap[orgId]),
                                      suffixIcon: Icons.arrow_forward_ios,
                                    ),
                                    items: orgs,
                                    onChanged: (value) {
                                      setState(() {
                                        orgId = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 领用日期
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
                              child: Text('使用日期'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  child: Input(
                                    controller: TextEditingController(
                                      text: formatDate(date, shortDate),
                                    ),
                                    enabled: false,
                                    normalBorder: true,
                                    suffixIcon: Icons.arrow_forward_ios,
                                  ),
                                  onTap: () async {
                                    debugPrint('||| 打开选择日期选择');
                                    var result = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: today.add(
                                          const Duration(days: -365 * 100)),
                                      lastDate: today
                                          .add(const Duration(days: 365 * 100)),
                                    );
                                    debugPrint('||| 选择日期$result');
                                    if (result == null) return;
                                    setState(() {
                                      date = result;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 位置
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
                          const SizedBox(
                            width: 90,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('位置'),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    savelocation = value;
                                  },
                                  controller:
                                      TextEditingController(text: savelocation),
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
                              child: Text('流水备注'),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Input(
                                  onChanged: (value) {
                                    fdescription = value;
                                  },
                                  controller:
                                      TextEditingController(text: fdescription),
                                  multiline: true,
                                ),
                              ),
                            ),
                          ),
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
                  onPressed: () async {
                    debugPrint('|||提交');
                    // Navigator.pop(context);
                    print(list);

                    var info = {
                      'custodian': custodian,
                      'orgId': int.tryParse(orgId),
                      'ctime': formatDate(
                        date,
                        longDate,
                      ),
                      'savelocation': savelocation,
                    };

                    if (!verify(info)) return;

                    var items = list.map((item) {
                      return {
                        'id': item['data']['id'],
                        'fdescription': fdescription,
                        'state': AssetStateEnum.transfer.index,
                        'custodian': info['custodian'],
                        'orgId': info['orgId'],
                        'ctime': info['ctime'],
                        'savelocation': info['savelocation'],
                      };
                    }).toList();
                    var res = await Api.goods.modify(items);
                    if (res == 0) return;

                    await alert(context, '提交成功', '当前资产已成功转让');

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('index', (route) => false);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

verify(item) {
  String msg = '';

  if (item['custodian'] == '') {
    msg = '使用人不能为空';
  } else if (item['orgId'] == null) {
    msg = '部门不能为空';
  }

  if (msg != '') {
    SmartDialog.showToast(msg);
  }
  return msg == '';
}
