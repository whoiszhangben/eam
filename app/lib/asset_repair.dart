/// 资产维修
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AssetRepair extends StatefulWidget {
  AssetRepair({
    super.key,
    required this.list,
  });

  var list;

  @override
  State<AssetRepair> createState() => _AssetRepairState();
}

class _AssetRepairState extends State<AssetRepair> {
  double width = 90;
  bool inited = false;
  late List arr;
  late List list;
  @override
  Widget build(BuildContext context) {
    if (!inited) {
      list = clone(widget.list);
      arr = list.map((item) {
        return {
          'selected': true,
          'expanded': true,
          'data': item,
          'more': false,
        };
      }).toList();
      inited = true;
    }

    return Scaffold(
      appBar: titleBar('当前资产信息'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: ExpansionPanelList(
                  expandedHeaderPadding:
                      const EdgeInsets.symmetric(vertical: 2),
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
                            title: CheckboxListTile(
                              onChanged: (bool? value) {
                                setState(() {
                                  row['selected'] = value as Object;
                                });
                              },
                              selected: false,
                              value: row['selected'] as bool,
                              title: Text(item['name'] ?? ''),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                        body: Container(
                          padding: const EdgeInsets.only(top: 16),
                          margin: const EdgeInsets.only(left: 16, right: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                              width: 1,
                              color: Color(0xffF2F3F5),
                            )),
                          ),
                          child: Column(children: [
                            if (!row['more']) ...[
                              viewField('使用人', item['custodian'], width),
                              viewField('部门', displayOrgName(item), width),
                              viewField('资产状态', stateMap[item['state']] ?? '-',
                                  width),
                              viewField('位置', item['savelocation'], width),
                              viewField('规格/型号', item['model'], width),
                            ],
                            if (row['more']) ...[
                              ViewGoods(
                                item,
                                hasFlowing: false,
                                hasTotal: true,
                              ),
                            ],
                            // 查看更多
                            if (!row['more'])
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                width: 100.w,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: const Text(
                                    '查看更多',
                                    style: TextStyle(color: Color(0xff1A77FF)),
                                  ),
                                  onPressed: () async {
                                    debugPrint('||| 查看更多');
                                    setState(() {
                                      row['more'] = true;
                                    });
                                  },
                                ),
                              ),
                            // hr
                            Container(
                              height: 1,
                              color: const Color(0xffF2F3F5),
                              margin: const EdgeInsets.only(bottom: 10),
                            ),
                            viewItem(
                              '本次维修金额',
                              Input(
                                onChanged: (value) {
                                  item['repairPrice'] = value;
                                },
                                controller: TextEditingController(
                                    text: item['repairPrice'] ?? ''),
                                keyboardType: TextInputType.number,
                              ),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              width: width,
                            ),
                            viewItem(
                              '维修记录',
                              Input(
                                onChanged: (value) {
                                  item['repairDescription'] = value;
                                },
                                controller: TextEditingController(
                                    text: item['repairDescription'] ?? ''),
                                multiline: true,
                              ),
                              // crossAxisAlignment: CrossAxisAlignment.t,
                              width: width,
                            ),
                          ]),
                        ),
                      );
                    }),
                  ],
                ),
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
                  enabled: arr
                      .where((element) => element['selected'] as bool)
                      .toList()
                      .isNotEmpty,
                  onPressed: () async {
                    debugPrint('||| 维修');

                    var chooseList = arr
                        .where((element) => element['selected'] as bool)
                        .map((e) => e['data']);

                    for (var item in chooseList) {
                      var res = await Api.goods.repair(
                        item['id'],
                        item['repairDescription'] ?? '',
                        item['repairPrice'] != ''
                            ? double.tryParse(item['repairPrice'] ?? '0')
                            : 0,
                      );
                      if (res == 0) return;
                    }

                    await alert(context, '提交成功', '当前维修已记录成功');

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
