import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AssetInfo extends StatefulWidget {
  AssetInfo({
    super.key,
    required this.list,
  });

  var list;

  @override
  State<AssetInfo> createState() => _AssetInfoState();
}

class _AssetInfoState extends State<AssetInfo> {
  @override
  Widget build(BuildContext context) {
    widget.list;
    debugPrint('||| widget.list: ${widget.list}');

    var cards = widget.list.map((item) {
      return Card(
        margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 17, left: 15),
          child: Column(children: [
            // 名称
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                  width: 1,
                  color: Color(0xffF2F3F5),
                )),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            ViewGoods(item),
          ]),
        ),
      );
    });

    return Scaffold(
      appBar: titleBar('当前资产信息'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(children: [
            ...cards,
            // 底部导航占位
            const SizedBox(height: 98),
          ]),
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
                  '确定',
                  onPressed: () {
                    debugPrint('|||确定');
                    Navigator.pop(context);
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
