// 流水信息
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/utils.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Flowing extends StatefulWidget {
  Flowing(
    this.item, {
    super.key,
  });

  var item;

  @override
  State<Flowing> createState() => _FlowingState();
}

class _FlowingState extends State<Flowing> {
  bool showFlowing = false;
  var flowings;

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    if (showFlowing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 90,
              child: Text(
                '流水信息',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  height: 16 / 14,
                  color: Color(0xff212121),
                ),
                strutStyle: StrutStyle(leading: .5),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    ...flowings.map((flowing) {
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
                                [
                                  formatDate(
                                    DateTime.parse(flowing['createTime']),
                                    shortDate,
                                  ),
                                  flowing['user'],
                                  stateFolwingMap[flowing['state']],
                                ].join(' '),
                                if (flowing['description'] != '')
                                  '备注信息：${flowing['description']}',
                              ].join('\n'),
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
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
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
            var res = await Api.goods.flowing(item['id']);
            if (res == 0) return;
            flowings = res['data'];
            setState(() {
              showFlowing = true;
            });
          },
        ),
      );
    }
  }
}
