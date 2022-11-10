/// 供应商
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/asset_vendor_add.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AssetVendor extends StatefulWidget {
  AssetVendor({
    super.key,
    this.list,
  });

  var list;

  @override
  State<AssetVendor> createState() => _AssetVendorState();
}

buildList(List list) {
  var arr = list.map((item) {
    return {
      'expanded': false,
      'data': item,
    };
  }).toList();
  if (arr.isNotEmpty) arr.first['expanded'] = true;
  return arr;
}

class _AssetVendorState extends State<AssetVendor> {
  var arr;
  String keyword = '';
  @override
  void initState() {
    super.initState();
    arr = buildList(widget.list);
  }

  search() async {
    var res = await Api.vendor.query(keyword);
    if (res == 0) return;
    setState(() {
      arr = buildList(res['data']['list']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleBar('供应商管理'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // 顶部搜索栏占位
              const SizedBox(height: 52),
              // 主要内容
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      arr[index]['expanded'] = !isExpanded;
                    });
                  },
                  children: [
                    ...arr.map((row) {
                      var item = row['data'];

                      return ExpansionPanel(
                        isExpanded: row['expanded'],
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            minVerticalPadding: 0,
                            contentPadding: const EdgeInsets.all(0),
                            title: Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Color(0xff212121),
                                ),
                              ),
                            ),
                          );
                        },
                        body: Container(
                          // padding: const EdgeInsets.only(top: 16),
                          margin: const EdgeInsets.only(left: 16, right: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                              width: 1,
                              color: Color(0xffF2F3F5),
                            )),
                          ),
                          child: Column(children: [
                            const SizedBox(height: 20),
                            viewField('电话号码', item['phone']),
                            viewField('地址信息', item['addr']),
                            viewField('备注', item['description']),
                          ]),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // 底部导航占位
              const SizedBox(height: 117),
            ],
          ),

          // 顶部搜索栏
          Positioned(
            top: 0,
            width: 100.w,
            child: Container(
              color: const Color(0xFFf2f5f9),
              padding: const EdgeInsets.only(
                left: 16,
                top: 8,
                bottom: 8,
              ),
              child: Row(children: [
                Expanded(
                  child: Input(
                    onChanged: (value) {
                      keyword = value;
                    },
                    controller: TextEditingController(text: keyword),
                    prefixIcon: Icons.search,
                    suffixIcon: Icons.close,
                    vertical: 8,
                    isDense: true,
                    borderRadius: 20,
                    onPressedSuffixIcon: () {
                      debugPrint('||| 清空');
                      setState(() {
                        keyword = '';
                      });
                      search();
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 16),
                  child: InkWell(
                    onTap: () async {
                      debugPrint('||| 搜索');
                      FocusManager.instance.primaryFocus?.unfocus();
                      search();
                    },
                    child: const Text(
                      '搜索',
                      style: TextStyle(
                        color: Color(0xff212121),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // 底部导航
          Positioned(
            top: 0,
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Stack(
                children: [
                  Positioned(
                    width: 100.w,
                    height: 117,
                    // appBar: 92 bg: 117 navbar: bottomHeight
                    top: 100.h - 92 - 127,
                    child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/bottom_nav_bg.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          // 占位
                          SizedBox(
                            width: (100 / 3).w,
                          ),
                          // 新建机构
                          SizedBox(
                            width: (100 / 3).w,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 60,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x1a1979FF),
                                          blurRadius: 4.0,
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: Image.asset('images/add.png'),
                                      iconSize: 60,
                                      onPressed: () async {
                                        debugPrint('||| 新建供应商');

                                        var newItem =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AssetVendorAdd(),
                                          ),
                                        );
                                        debugPrint('||| 新增页返回： $newItem');

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        if (newItem != null) {
                                          setState(() {
                                            arr.add({
                                              'expanded': true,
                                              'data': newItem,
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 占位
                          SizedBox(
                            width: (100 / 3).w,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
