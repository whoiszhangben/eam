/// 组织架构
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/asset_org_add.dart';
import 'package:asset_management_system/asset_org_edit.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetOrg extends StatefulWidget {
  AssetOrg({super.key, required this.list, this.nav});

  final list;
  var nav;

  @override
  State<AssetOrg> createState() => _AssetOrgState();
}

class _AssetOrgState extends State<AssetOrg> {
  @override
  Widget build(BuildContext context) {
    debugPrint('||| AssetOrg widget.list: \n${widget.list}');
    debugPrint('||| AssetOrg widget.nav: \n${widget.nav}');
    List nav = widget.nav ?? [];
    return Scaffold(
      appBar: titleBar('机构管理'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(children: [
            // 顶部导航占位
            if (nav.isNotEmpty) const SizedBox(height: 48),
            // 机构列表
            if (widget.list.length != 0)
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 23, right: 16),
                    // flutter_slidable https://github.com/letsar/flutter_slidable/wiki/FAQ
                    child: SlidableAutoCloseBehavior(
                      child: Column(children: [
                        ...widget.list.asMap().entries.map((entry) {
                          var index = entry.key;
                          var item = entry.value;
                          return Container(
                            // margin: EdgeInsets.only(top: 15),
                            // padding: EdgeInsets.only(bottom: 15),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                width: 1,
                                color: Color(0xffF2F3F5),
                              )),
                            ),
                            child: Slidable(
                              groupTag: '0',
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      debugPrint('||| 编辑');
                                      print(widget.nav);
                                      var editItem =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssetOrgEdit(item: item),
                                        ),
                                      );
                                      debugPrint('||| 编辑页面返回 $editItem');
                                      if (editItem != null) {
                                        // 保留子级信息
                                        editItem['children'] = item['children'];
                                        setState(() {
                                          widget.list[index] = editItem;
                                        });
                                      }
                                    },
                                    backgroundColor: const Color(0xFF1A77FF),
                                    foregroundColor: Colors.white,
                                    label: '编辑',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      debugPrint('||| 删除');
                                      var confirm = await showDialog(
                                        // barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text(
                                            '提示',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            '确认移除机构 #${item['name']}？',
                                            textAlign: TextAlign.center,
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('确定'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      var res = await Api.organization
                                          .remove(item['id']);
                                      if (res == 0) return;
                                      setState(() {
                                        widget.list.removeAt(index);
                                      });
                                      SmartDialog.showToast('删除成功');
                                    },
                                    backgroundColor: const Color(0xFFEE0A24),
                                    foregroundColor: Colors.white,
                                    label: '删除',
                                  ),
                                ],
                              ),
                              child: InkWell(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Text(
                                    item['name'] as String,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        height: 24 / 16,
                                        color: Color(0xff212121)),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 24,
                                    color: Color(0xff9e9e9e),
                                  ),
                                ),
                                onTap: () {
                                  debugPrint('||| 子级$item');
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      settings: RouteSettings(
                                        name: 'org-${item['id']}',
                                      ),
                                      opaque: true,
                                      pageBuilder: (context, _, __) => AssetOrg(
                                          list: item['children'],
                                          nav: [...nav, item]),
                                      transitionsBuilder: (_,
                                          Animation<double> animation,
                                          __,
                                          Widget child) {
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
                                },
                              ),
                            ),
                          );
                        }),
                      ]),
                    ),
                  ),
                ]),
              ),
            // 无机构列表
            if (widget.list.length == 0) ...[
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 126, bottom: 10),
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/org_empty.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '无子机构',
                  style: TextStyle(
                    color: Color(0xff9E9E9E),
                    fontSize: 14,
                    height: 22 / 14,
                  ),
                ),
              ),
            ],
            // 底部导航占位
            const SizedBox(height: 117),
          ]),
          // 顶部导航
          if (nav.isNotEmpty)
            Positioned(
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0f242528),
                      offset: Offset(0, 6), // changes position of shadow
                      blurRadius: 12,
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(left: 16, right: 16),
                width: 100.w,
                height: 48,
                child: BreadCrumb(
                  items: nav.map((item) {
                    return BreadCrumbItem(
                      content: InkWell(
                        onTap: item != nav.last
                            ? () {
                                Navigator.of(context).popUntil((route) {
                                  return route.settings.name ==
                                      'org-${item['id']}';
                                });
                              }
                            : null,
                        child: Text(item['name']),
                      ),
                    );
                  }).toList(),
                  divider: const Icon(Icons.chevron_right),
                  overflow: ScrollableOverflow(
                    keepLastDivider: false,
                    reverse: false,
                    direction: Axis.horizontal,
                  ),
                ),
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
                                        debugPrint('|||新建机构');

                                        var newItem =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AssetOrgAdd(
                                              parent: nav.isNotEmpty
                                                  ? nav.last
                                                  : null,
                                            ),
                                          ),
                                        );
                                        debugPrint('||| 机构新增页返回： $newItem');
                                        if (newItem != null) {
                                          newItem['children'] = [];
                                          setState(() {
                                            widget.list.add(newItem);
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
          )
        ],
      ),
    );
  }
}
