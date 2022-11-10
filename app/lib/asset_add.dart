import 'dart:convert';
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

var groupItem = {
  'name': '',
  // TODO 设置默认部门
  'orgId': '',
  'buytime': DateTime.now().millisecondsSinceEpoch,
  'catalog': '',
  'catalogChild': '',
  'model': '',
  'amount': '1',
  'unit': '个',
  'price': '',
  'description': '',
  'local': '',
  'use': '',
  'vendorId': '',
  'warrantyPeriod': '', // 保修期限(月)
};

class AssetAdd extends StatefulWidget {
  AssetAdd({
    super.key,
  });

  @override
  State<AssetAdd> createState() => _AssetAddState();
}

class _AssetAddState extends State<AssetAdd>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  var click = 0;

  double width = 90;
  bool firstFocus = false;
  bool inited = false;
  bool isGroup = true;
  String groupName = '';
  DateTime buytime = DateTime.now();
  final DateTime today = DateTime.now();

  var list = [
    json.decode(json.encode(groupItem)),
    // json.decode(json.encode(groupItem)),
  ];

  List orgs = [
    {'id': '', 'name': '加载中...'},
  ];
  List catalogs = [
    {'id': '', 'name': '加载中...'},
  ];
  List vendors = [
    {'id': '', 'name': '加载中...'},
  ];

  @override
  void initState() {
    super.initState();
    _asyncData();
  }

  _asyncData() async {
    var org = await orgList();
    var catalog = await catalogList();
    var vendor = await vendorList();
    print('initState Select lists');
    setState(() {
      orgs = [
        {'id': '', 'name': '请选择'},
        ...org,
      ];
      catalogs = [
        {'id': '', 'name': '请选择'},
        ...catalog,
      ];
      vendors = [
        {'id': '', 'name': '请选择'},
        ...vendor,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!inited) {
      (() async {})();
      inited = true;
    }

    buildCard(index, item) {
      // 基础信息
      return Card(
        margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 16, bottom: 14, right: 10),
            child: Row(children: [
              const Text(
                "基础信息",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              if (isGroup) Text('资产 #${index + 1}'),
              if (index != 0)
                IconButton(
                  onPressed: () async {
                    debugPrint('||| 删除资产');

                    var res = await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('提示'),
                        content: Text('确认移除资产 #${index + 1}？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                    if (res == true) {
                      setState(() {
                        list.removeAt(index);
                      });
                      SmartDialog.showToast('删除成功');
                      return;
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
            ]),
          ),
          Column(children: [
            // 资产名称
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('资产名称'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          init: (FocusNode focusNode) {
                            if (!firstFocus) {
                              focusNode.requestFocus();
                              firstFocus = true;
                            }
                          },
                          onChanged: (value) {
                            item['name'] = value;
                          },
                          controller: TextEditingController(text: item['name']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 资产类别
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('资产类别'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Select(
                          catalogs,
                          onChanged: (value) async {
                            if (value == item['catalog']) return;
                            setState(() {
                              item['catalogChildData'] = [
                                {'id': '', 'name': '加载中...'},
                              ];
                              item['catalog'] = value;
                              item['catalogChild'] = '';
                            });
                            if (value == '') return;
                            var catalogChild =
                                await catalogChildList(int.parse(value));
                            setState(() {
                              item['catalogChildData'] = [
                                {'id': '', 'name': '请选择'},
                                ...catalogChild,
                              ];
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 资产子类别
            if (item['catalog'] != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                        child: Text('资产子类别'),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Select(
                            item['catalogChildData'],
                            onChanged: (value) {
                              setState(() {
                                item['catalogChild'] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            // 规格/型号
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('规格/型号'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          onChanged: (value) {
                            item['model'] = value;
                          },
                          controller:
                              TextEditingController(text: item['model']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 购买日期
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('购买日期'),
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
                              text: formatDate(buytime, shortDate),
                            ),
                            enabled: false,
                            normalBorder: true,
                            suffixIcon: Icons.arrow_forward_ios,
                          ),
                          onTap: () async {
                            debugPrint('||| 打开选择购买日期选择');
                            var result = await showDatePicker(
                              context: context,
                              initialDate: buytime,
                              firstDate:
                                  today.add(const Duration(days: -365 * 100)),
                              lastDate:
                                  today.add(const Duration(days: 365 * 100)),
                            );
                            debugPrint('||| 选择购买日期$result');
                            if (result == null) return;
                            setState(() {
                              buytime = result;
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 购买价格
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('购买价格'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            item['price'] = value;
                          },
                          controller:
                              TextEditingController(text: item['price']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 使用部门
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('部门'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Select(
                          orgs,
                          onChanged: (value) {
                            setState(() {
                              item['orgId'] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 供应商
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('供应商'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Select(
                          vendors,
                          onChanged: (value) {
                            setState(() {
                              item['vendorId'] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 保修期限(月)
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('保修期限(月)'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            item['warrantyPeriod'] = value;
                          },
                          controller: TextEditingController(
                              text: item['warrantyPeriod']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 储存位置
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('储存位置'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          onChanged: (value) {
                            item['local'] = value;
                          },
                          controller:
                              TextEditingController(text: item['local']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 使用人
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                            item['use'] = value;
                          },
                          controller: TextEditingController(text: item['use']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 购买数量
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('购买数量'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            item['amount'] = value;
                          },
                          controller:
                              TextEditingController(text: item['amount']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 单位
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                      child: Text('单位'),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Input(
                          onChanged: (value) {
                            item['unit'] = value;
                          },
                          controller: TextEditingController(text: item['unit']),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 备注
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 10),
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
                            item['description'] = value;
                          },
                          controller:
                              TextEditingController(text: item['description']),
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
      );
    }

    return Scaffold(
      appBar: titleBar('资产入库'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            // 10000 高度不可见时不重绘
            cacheExtent: 10000,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // 基础信息
              ...(list.asMap().entries.where((element) {
                return element.key == 0 || isGroup;
              }).map((entry) {
                // 基础信息
                return buildCard(entry.key, entry.value);
              })),
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
                    debugPrint('||| 资产入库 $widget.group');

                    if (!verify(list)) return;

                    var body = json.decode(json.encode(list));
                    for (var item in body) {
                      var vendorId = int.tryParse(item['vendorId']);
                      item['vendorId'] = vendorId;
                      var warrantyPeriod = int.tryParse(item['warrantyPeriod']);
                      item['warrantyPeriod'] = warrantyPeriod;
                      var orgId = int.tryParse(item['orgId']);
                      item['orgId'] = orgId;
                      var gSortId = int.tryParse(item['catalog']);
                      item['gSortId'] = gSortId;
                      var childgsortid = int.tryParse(item['catalogChild']);
                      item['childgsortid'] = childgsortid;
                      var amount = int.tryParse(item['amount']);
                      item['amount'] = amount;
                      var price = double.tryParse(item['price']);
                      item['price'] = price;
                      var buytime = formatDate(
                        DateTime.fromMillisecondsSinceEpoch(item['buytime']),
                        longDate,
                      );
                      item['buytime'] = buytime;
                    }

                    var res = await Api.goods.add(body);
                    if (res == 0) return;
                    await alert(context, '添加成功', '当前资产已记录成功');
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          if (isGroup)
            Positioned(
              bottom: 140,
              right: -28,
              child: AddAnimation(
                animation: _controller,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Image.asset('images/add.png'),
                  iconSize: 60,
                  onPressed: () async {
                    debugPrint('||| 增加资产组');

                    FocusManager.instance.primaryFocus?.unfocus();
                    print(_controller.status);
                    var status = _controller.status;
                    if (_controller.status == AnimationStatus.dismissed) {
                      _controller.forward();
                      click = 0;
                      readyHide(0);
                    } else if (status == AnimationStatus.completed) {
                      setState(() {
                        list.add(json.decode(json.encode(groupItem)));
                      });
                      SmartDialog.showToast('新增资产 #${list.length}');
                      readyHide(++click);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  readyHide(count) async {
    await Future.delayed(const Duration(seconds: 5));
    if (count == click) _controller.reverse();
  }
}

verify(List list) {
  String msg = '';

  var index = list.indexWhere((element) {
    if (element['name'] == '') {
      msg = '资产名称不能为空';
      return true;
    }
    if (element['catalog'] == '') {
      msg = '资产类别不能为空';
      return true;
    }
    if (element['catalogChild'] == '') {
      msg = '资产子类别不能为空';
      return true;
    }
    if (element['orgId'] == '') {
      msg = '部门不能为空';
      return true;
    }
    return false;
  });
  if (msg != '') {
    SmartDialog.showToast('资产 #${index + 1}:$msg');
  }
  return msg == '';
}

class AddAnimation extends AnimatedWidget {
  AddAnimation({
    Key? key,
    required Animation<double> animation,
    this.child,
  }) : super(
          key: key,
          listenable: animation,
        );

  Widget? child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    double scale = Tween(begin: .5, end: -.5).animate(animation).value;
    double translateX = Tween(begin: 0.0, end: -50.0).animate(animation).value;

    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..scale(scale.abs() + .5)
        ..translate(translateX),
      child: child,
    );
  }
}
