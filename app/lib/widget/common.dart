import 'dart:convert';

import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/flowing.dart';
import 'package:date_format/date_format.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// 下拉选择项
List<DropdownMenuItem<String>> buildDropdownMenuItems(List arr) {
  return arr.map((item) {
    return DropdownMenuItem(
      value: item['id'].toString(),
      child: Text(item['name'].toString()),
    );
  }).toList();
}

// 主按钮
class PrimaryButton extends StatelessWidget {
  PrimaryButton(
    String this.data, {
    super.key,
    required this.onPressed,
    this.margin,
    this.width,
    this.enabled = true,
  });

  final String? data;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final double? width;
  bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      margin: margin,

      /// background: linear-gradient(
      ///   113.04deg,
      ///   #00A9E4 19.9%,
      ///   #1A77FF 90.05%
      /// );
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // TODO deg 转换错误
          begin: Alignment.topLeft,
          end: const Alignment(0.5, 1),
          colors: enabled
              ? const [
                  Color(0xff00A9E4),
                  Color(0xff1A77FF),
                ]
              : const [
                  Color(0x6600A9E4),
                  Color(0x661A77FF),
                ],
          stops: const [0.199, 0.9005],
        ),
        borderRadius: BorderRadius.circular(45.0),
        // box-shadow: 0px 6px 10px rgba(25, 121, 255, 0.3)
        boxShadow: const [
          BoxShadow(
            color: Color(0x4c1979FF),
            offset: Offset(0, 6),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
        ),
        child: Text(
          data!,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
    );
  }
}

// 右滑导航
navigator(context, widget) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, _, __) => widget,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

viewItem(
  name,
  child, {
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  double width = 68,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: width,
          child: Text(
            name,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              height: 16 / 14,
              color: Color(0xff212121),
            ),
            strutStyle: const StrutStyle(leading: .5),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            child: child,
          ),
        ),
      ],
    ),
  );
}

viewField(name, value, [double width = 68]) {
  return viewItem(
    name,
    Text(
      value?.toString() ?? '',
      style: const TextStyle(
        fontSize: 14,
        height: 16 / 14,
        color: Color(0xff9E9E9E),
      ),
      strutStyle: const StrutStyle(leading: .5),
    ),
    width: width,
  );
}

enum AssetStateEnum {
  _, // 占位 0
  idle, // 闲置 1
  use, // 领用 2
  remand, // 归还 3
  lose, // 遗失 4
  transfer, // 转让 5
  scrap, // 报废 6
}

scanquery(context) async {
  debugPrint('||| 打开扫码');
  // TODO
  final id = await Navigator.of(context).pushNamed('scan');
  // var id = '103';
  debugPrint('||| 扫码结果: $id');
  if (id == null) return;
  var res = await Api.goods.query(id);
  if (res == 0) return;
  if (res['data'] == null) {
    alert(context, '无数据', '资产编号 No.$id 无数据');
    return;
  }
  List<dynamic> list = res['data'];
  // 当前的放到最前面
  var curIndex = list.indexWhere((element) => element['id'].toString() == id);
  var cur = list[curIndex];
  list.removeAt(curIndex);
  list = [cur, ...list];
  return list;
}

class ViewGoods extends StatefulWidget {
  ViewGoods(
    this.item, {
    super.key,
    this.editDescription,
    this.hasFlowing = true,
    this.hasTotal = false,
  });

  var item;
  bool hasFlowing;
  bool hasTotal;
  // 备注是否可编辑
  bool? editDescription;

  @override
  State<ViewGoods> createState() => _ViewGoodsState();
}

// 加宽的版本
viewField2(name, value) {
  return viewField(name, value, 90);
}

displayOrgName(item) {
  var parentOrgName = item['baseOrgName'];
  var orgName = item['organization']?['name'];
  if (parentOrgName == '') return orgName;
  return '$parentOrgName - $orgName';
}

class _ViewGoodsState extends State<ViewGoods> {
  bool inited = false;
  bool showFlowing = false;
  var flowings;

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    if (!inited) {
      inited = true;
    }
    print(item);
    return Column(children: [
      viewField2('资产类别', item['gsort']?['name']),
      viewField2('资产子类别', item['childGsort']?['name']),
      viewField2('规格/型号', item['model']),
      viewField2(
        '购买日期',
        item['buyTime'] == null
            ? '-'
            : formatDate(DateTime.parse(item['buyTime']), longDate),
      ),
      viewField2('购买价格', item['price']),
      viewField2('部门', displayOrgName(item)),
      viewField2('供应商', item['vendor']?['name']),
      viewField2('保修期限(月)', item['warrantyPeriod']),
      viewField2('储存位置', item['savelocation']),
      viewField2('资产状态', stateMap[item['state']] ?? '-'),
      viewField2('使用人', item['custodian']),
      if (widget.editDescription != true) viewField2('备注', item['description']),
      // 编辑备注
      if (widget.editDescription == true)
        viewItem(
          '备注',
          Input(
            onChanged: (value) {
              item['description'] = value;
            },
            controller: TextEditingController(text: item['description']),
            multiline: true,
          ),
          width: 80,
        ),
      if (widget.hasTotal)
        viewField2(
          '维修总金额',
          item['repair'].fold(
            0,
            (total, repair) => total + repair['price'],
          ),
        ),
      // 维修记录
      repairList(item),
      if (widget.hasFlowing) Flowing(item),
    ]);
  }
}

repairList(item, [double width = 90]) {
  return viewItem(
    '维修记录',
    Column(
      children: [
        if (item['repair'].length != 0)
          ...item['repair'].map((repair) {
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                  width: 1,
                  color: Color(0xffF2F3F5),
                )),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    [
                      formatDate(DateTime.parse(repair['ctime']), shortDate),
                      '\n',
                      '花费${repair['price']}元。',
                      (repair['description'] == '' ||
                              repair['description'] == null)
                          ? ''
                          : '\n备注：${repair['description']}',
                    ].join(''),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 16 / 14,
                      color: Color(0xff9E9E9E),
                    ),
                    strutStyle: const StrutStyle(leading: .5),
                  ),
                ),
              ]),
            );
          }),
      ],
    ),
    width: width,
  );
}

toSimpleList(List list) {
  return list.map((item) {
    return {
      'id': item['id'].toString(),
      'name': item['name'].toString(),
    };
  }).toList();
}

Future<List<Map<String, String>>> vendorList() async {
  var res = await Api.vendor.query();
  if (res == 0) return [];
  return toSimpleList(res['data']['list']);
}

catalogList() async {
  var res = await Api.catalog.query();
  if (res == 0) return [];
  return toSimpleList(res['data']['list']);
}

catalogChildList(parentId) async {
  var res = await Api.catalogChild.query(parentId);
  if (res == 0) return [];
  return toSimpleList(res['data']['list']);
}

orgList() async {
  var res = await Api.organization.query();
  if (res == 0) return [];
  List list = res['data']['list'];

  var map = {};
  var root = [];
  // to map
  for (var item in list) {
    map[item['id']] = item;
    // 初始化
    item['children'] = [];
  }
  // build tree
  for (var item in list) {
    var parent = map[item['parent']];
    if (parent != null) {
      parent['children'].add(item);
    } else {
      // 根元素无父节点
      root.add(item);
    }
  }
  // tree to list
  List<Map<String, String>> arr = [];
  flatTree(root, '', arr);

  return arr;
}

flatTree(List list, String prefix, List arr) {
  for (var item in list) {
    arr.add({
      'id': item['id'].toString(),
      'name': '$prefix${item['name']}',
    });
    flatTree(item['children'], '$prefix    ', arr);
  }
}

clone(obj) {
  return json.decode(json.encode(obj));
}

class TitleContent extends StatelessWidget {
  TitleContent(
    this.title, {
    super.key,
    this.isWhite = false,
  });

  String title;
  bool isWhite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 44),
      color: Color(isWhite ? 0xffffffff : 0xff042275),
      width: 100.w,
      height: 48 + 44,
      child: Stack(children: [
        SizedBox(
          width: 100.w,
          height: 100.h,
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Color(isWhite ? 0xff212121 : 0xffffffff)),
            ),
          ),
        ),
        Positioned(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(isWhite ? 0xff212121 : 0xffffffff),
            ),
            onPressed: () {
              print('||| 返回');
              Navigator.of(context).pop();
            },
            iconSize: 18,
          ),
        ),
      ]),
    );
  }
}

// TODO 怎么重写为 class ？
titleBar(title, [bool? isWhite]) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(92),
    child: TitleContent(
      title,
      isWhite: isWhite ?? false,
    ),
  );
}

alert(context, title, content) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.only(top: 19),
      contentPadding: const EdgeInsets.only(top: 23, bottom: 27),
      actionsPadding: EdgeInsets.zero,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          height: 24 / 16,
          color: Color(0xff212121),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Color(0xffF7F7F7),
                ),
              ),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '确定',
                style: TextStyle(color: Color(0xffCE2035)),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class Input extends StatefulWidget {
  Input({
    super.key,
    this.onChanged,
    this.controller,
    this.suffixIcon,
    this.onPressedSuffixIcon,
    this.prefixIcon,
    this.onPressedPrefixIcon,
    this.enabled = true,
    this.disabled = false,
    this.multiline = false,
    this.borderRadius = 8.0,
    this.iconSize = 14,
    this.fontSize = 14,
    this.vertical = 9,
    this.horizontal = 12,
    this.iconPadding = 0,
    this.obscureText = false,
    this.hintText = '请输入',
    this.keyboardType,
    this.isDense = false,
    this.init,
    this.normalBorder = false,
  });

  ValueChanged<String>? onChanged;
  TextEditingController? controller;
  IconData? suffixIcon;
  VoidCallback? onPressedSuffixIcon;
  IconData? prefixIcon;
  VoidCallback? onPressedPrefixIcon;
  bool enabled;
  bool disabled;
  bool multiline;
  double borderRadius;
  double iconSize;
  double fontSize;
  double vertical;
  double horizontal;
  double iconPadding;
  bool obscureText;
  String hintText;
  TextInputType? keyboardType;
  bool isDense;
  Function? init;
  bool normalBorder;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final FocusNode _textFieldFocus = FocusNode();

  bool focus = false;

  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(() {
      if (_textFieldFocus.hasFocus) {
        setState(() {
          focus = true;
        });
      } else {
        setState(() {
          focus = false;
        });
      }
    });
    if (widget.init != null) widget.init!(_textFieldFocus);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.obscureText,
      focusNode: _textFieldFocus,
      onChanged: widget.onChanged,
      controller: widget.controller,
      enabled: widget.disabled ? false : widget.enabled,
      style: TextStyle(
        fontSize: widget.fontSize,
        color: const Color(0XFF212121),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.disabled
            ? const Color(0x339E9E9E)
            : focus
                ? const Color(0X051B78FF)
                : const Color(0XFFFAFAFA),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.fontSize,
          color: const Color(0XFF9E9E9E),
        ),
        isDense: widget.isDense,
        contentPadding: EdgeInsets.only(
          top: widget.vertical,
          bottom: widget.vertical,
          left: widget.prefixIcon != null
              ? 0
              : (widget.horizontal + widget.iconPadding),
          right: widget.suffixIcon != null ? 0 : widget.horizontal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff042275)),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0XFFFAFAFA)),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: widget.normalBorder
              ? const BorderSide(color: Color(0XFFFAFAFA))
              : const BorderSide(color: Color(0x339E9E9E)),
          // borderSide: const BorderSide(color: Color(0XFFFAFAFA)),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        // 前置图标配置
        prefixIconConstraints: widget.prefixIcon != null
            ? BoxConstraints(
                minWidth: widget.horizontal + widget.iconSize,
              )
            : null,
        prefixIcon: widget.prefixIcon != null
            ? SizedBox(
                width: widget.horizontal + widget.iconSize + widget.iconPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      widget.prefixIcon,
                      size: widget.iconSize,
                      color: const Color(0xffd9d9d9),
                    ),
                    SizedBox(width: widget.iconPadding),
                  ],
                ),
              )
            : null,
        // 后置图标配置
        suffixIconConstraints: widget.suffixIcon != null
            ? BoxConstraints(
                minWidth: widget.horizontal + widget.iconSize,
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            ? SizedBox(
                width: widget.horizontal + widget.iconSize,
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(maxHeight: widget.iconSize),
                      onPressed: widget.onPressedSuffixIcon,
                      icon: Icon(
                        widget.suffixIcon,
                        size: widget.iconSize,
                        color: const Color(0xffd9d9d9),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      // 多行文本配置
      keyboardType:
          widget.multiline ? TextInputType.multiline : widget.keyboardType,
      minLines: widget.multiline ? 5 : 1,
      maxLines: widget.multiline ? 100 : 1,
    );
  }
}

class Select extends StatefulWidget {
  Select(
    this.list, {
    super.key,
    required this.onChanged,
  });

  var onChanged;
  List list;

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  TextEditingController controller = TextEditingController();
  List<DropdownMenuItem<String>> items = [];
  var map;
  var val;

  @override
  void initState() {
    super.initState();

    update();
    if (widget.list.isNotEmpty) {
      val = widget.list.first['id'];
      controller.text = map[widget.list.first['id']];
    }
  }

  update() {
    map = toMap(widget.list);
    items = buildDropdownMenuItems(widget.list);
  }

  @override
  void didUpdateWidget(covariant Select oldWidget) {
    super.didUpdateWidget(oldWidget);

    update();
    controller.text = map[val] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Input(
          hintText: '请选择',
          enabled: false,
          normalBorder: true,
          controller: controller,
          suffixIcon: Icons.arrow_forward_ios,
        ),
        items: items,
        onChanged: ((value) {
          val = value;
          controller.text = map[value];
          widget.onChanged(value);
        }),
      ),
    );
  }
}
