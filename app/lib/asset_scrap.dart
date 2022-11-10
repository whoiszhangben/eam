/// 资产报废
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetScrap extends StatefulWidget {
  AssetScrap({
    super.key,
    required this.list,
  });

  var list;

  @override
  State<AssetScrap> createState() => _AssetScrapState();
}

class _AssetScrapState extends State<AssetScrap> {
  bool inited = false;
  late List arr;
  @override
  Widget build(BuildContext context) {
    if (!inited) {
      arr = widget.list.map((item) {
        return {
          'selected': true,
          'expanded': true,
          'data': item,
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
                            viewField('使用人', item['custodian']),
                            viewField('部门', displayOrgName(item)),
                            viewField('资产状态', stateMap[item['state']] ?? '-'),
                            viewField('位置', item['savelocation']),
                            viewField('规格/型号', item['model']),
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
                decoration: BoxDecoration(
                  // background: linear-gradient(125.84deg, #FFADA2 24.81%, #FA6157 82.88%);
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.01, 1),
                    colors: [
                      Color(0xffFFADA2),
                      Color(0xffFA6157),
                    ],
                    stops: [0.2481, 0.8288],
                  ),
                  borderRadius: BorderRadius.circular(45.0),
                  // box-shadow: 0px 2px 4px rgba(251, 98, 89, 0.4);
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FB6259),
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    debugPrint('||| 报废');

                    var chooseList = arr
                        .where((element) => element['selected'] as bool)
                        .map((e) => e['data']);

                    var items = chooseList.map((item) {
                      return {
                        'id': item['id'],
                        'state': AssetStateEnum.scrap.index,
                      };
                    }).toList();

                    if (items.isEmpty) {
                      SmartDialog.showToast('未勾选需报废资产');
                      return;
                    }
                    var res = await Api.goods.modify(items);
                    if (res == 0) return;

                    await alert(context, '提交成功', '当前资产已成功归报废');

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('index', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45)),
                  ),
                  child: const Text(
                    '确认报废',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
