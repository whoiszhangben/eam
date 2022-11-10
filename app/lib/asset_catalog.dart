/// 资产分类
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/asset_catalog_add.dart';
import 'package:asset_management_system/asset_catalog_child_add.dart';
import 'package:asset_management_system/asset_catalog_child_edit.dart';
import 'package:asset_management_system/asset_catalog_edit.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';

class AssetCatalog extends StatefulWidget {
  AssetCatalog({super.key, required this.list, this.nav});

  final list;
  var nav;

  @override
  State<AssetCatalog> createState() => _AssetCatalogState();
}

class _AssetCatalogState extends State<AssetCatalog> {
  late int level;
  late List nav;
  late List list;

  @override
  void initState() {
    super.initState();
    nav = widget.nav ?? [];
    level = nav.length;
    list = widget.list;
  }

  refresh(parentId) async {
    var res = await Api.catalogChild.query(parentId);
    if (res == 0) return;
    setState(() {
      list = res['data']['list'];
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('||| AssetCatalog list: \n${list}');

    print('level: $level');

    return Scaffold(
      appBar: titleBar('资产分类'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(children: [
            // 顶部导航占位
            if (nav.length > 1) const SizedBox(height: 48),
            // 资产分类
            Card(
              margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 20, bottom: 8),
                    child: Text(
                      nav.last['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23, right: 16),
                  // flutter_slidable https://github.com/letsar/flutter_slidable/wiki/FAQ
                  child: list.length != 0
                      ? SlidableAutoCloseBehavior(
                          child: Column(children: [
                            ...list.asMap().entries.map((entry) {
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
                                          var editItem =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return level == 1
                                                    ? AssetCatalogEdit(
                                                        item: item)
                                                    : AssetCatalogChildEdit(
                                                        nav.last,
                                                        item: item,
                                                      );
                                              },
                                            ),
                                          );
                                          debugPrint('||| 编辑页面返回 $editItem');
                                          if (editItem != null) {
                                            setState(() {
                                              list[index] = editItem;
                                            });
                                          }
                                        },
                                        backgroundColor:
                                            const Color(0xFF1A77FF),
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
                                                '确认移除分类 #${item['name']}？',
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
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('确定'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm != true) return;
                                          var res;
                                          if (level == 1) {
                                            res = await Api.catalog
                                                .remove(item['id']);
                                          } else {
                                            res = await Api.catalogChild
                                                .remove(item['id']);
                                          }

                                          if (res == 0) return;
                                          setState(() {
                                            list.removeAt(index);
                                          });
                                          SmartDialog.showToast('删除成功');
                                        },
                                        backgroundColor:
                                            const Color(0xFFEE0A24),
                                        foregroundColor: Colors.white,
                                        label: '删除',
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: nav.length == 1
                                        ? () async {
                                            debugPrint('||| 子级$item');
                                            var res = await Api.catalogChild
                                                .query(item['id']);
                                            if (res == 0) return;

                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                settings: RouteSettings(
                                                  name: 'catalog-${item['id']}',
                                                ),
                                                opaque: true,
                                                pageBuilder: (context, _, __) {
                                                  return AssetCatalog(
                                                      list: res['data']['list'],
                                                      nav: [...nav, item]);
                                                },
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
                                          }
                                        : null,
                                    child: nav.length == 1
                                        ? ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(0),
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
                                          )
                                        : ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(0),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item['name'] as String,
                                                  style: const TextStyle(
                                                      fontSize: 14, height: 2),
                                                ),
                                                Text(
                                                  '${item['code']} ',
                                                  style: const TextStyle(
                                                      fontSize: 14, height: 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ]),
                        )
                      : Column(
                          children: [
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 126, bottom: 10),
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
                                '无子分类',
                                style: TextStyle(
                                  color: Color(0xff9E9E9E),
                                  fontSize: 14,
                                  height: 22 / 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 126),
                          ],
                        ),
                ),
              ]),
            ),
            // 底部导航占位
            const SizedBox(height: 117),
          ]),
          // 顶部导航
          if (nav.length > 1)
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
                                      'catalog-${item['id']}';
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
                          // 新建资产分类
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
                                        debugPrint('|||新建资产分类');

                                        var newItem =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return nav.length == 2
                                                  ? AssetCatalogChildAdd(
                                                      nav.last)
                                                  : AssetCatalogAdd();
                                            },
                                          ),
                                        );
                                        debugPrint('||| 资产分类新增页返回： $newItem');
                                        if (newItem != null) {
                                          setState(() {
                                            list.add(newItem);
                                          });
                                        } else if (nav.length == 2) {
                                          refresh(nav.last['id']);
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
