import 'package:asset_management_system/about.dart';
import 'package:asset_management_system/api.dart';
import 'package:asset_management_system/asset_add.dart';
import 'package:asset_management_system/asset_catalog.dart';
import 'package:asset_management_system/asset_info.dart';
import 'package:asset_management_system/asset_org.dart';
import 'package:asset_management_system/asset_remand.dart';
import 'package:asset_management_system/asset_repair.dart';
import 'package:asset_management_system/asset_scrap.dart';
import 'package:asset_management_system/asset_transfer.dart';
import 'package:asset_management_system/asset_use.dart';
import 'package:asset_management_system/asset_vendor.dart';
import 'package:asset_management_system/password.dart';
import 'package:asset_management_system/utils.dart';
import 'package:asset_management_system/widget/common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

List colors = [
  const Color(0xff042275),
  const Color(0xff249EFF),
  const Color(0xff21CCFF),
  const Color(0xff601986),
  const Color(0xff5FB47A),
  const Color(0xffFFC954),
  const Color(0xffB1E5E5),
  const Color(0xff65CBC9),
  const Color(0xffABC668),
];

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool isChecked = false;
  bool isVisible = false;
  int _selectedIndex = 0;
  String count = '-';
  String free = '-';
  String use = '-';
  int touchedIndex = -1;
  List baseOrg = [];
  int total = 0;

  refresh() {
    Api.statistics.query().then((data) {
      if (data == 0) return;
      setState(() {
        count = data['data']['count'].toString();
        free = data['data']['free'].toString();
        use = data['data']['use'].toString();
        baseOrg = data['data']['baseOrg'];
        total = baseOrg.fold(0, (previousValue, item) {
          return previousValue + item['total'] as int;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PreferredSize https://api.flutter.dev/flutter/widgets/PreferredSize-class.html
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/appbar_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: OverflowBox(
            maxHeight: 400,
            alignment: Alignment.topLeft,
            child: _selectedIndex == 0
                ? Column(
                    children: [
                      const SizedBox(height: 44),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            "宏凯集团资产云管理系统",
                            style: TextStyle(
                              color: Color(0xffffffff),
                              fontSize: 16,
                              height: 3,
                            ),
                          ),
                        ),
                      ),
                      // 总览
                      SizedBox(
                        height: 170,
                        child: Card(
                          margin: const EdgeInsets.only(
                              top: 10, left: 12, right: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                //垂直方向居中对齐
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    count,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    '资产总数',
                                    style: TextStyle(
                                      color: Color(0xff9e9e9e),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    free,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff0A9238),
                                    ),
                                  ),
                                  const Text(
                                    '闲置资产数',
                                    style: TextStyle(
                                      color: Color(0xff9e9e9e),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    use,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff042275),
                                    ),
                                  ),
                                  const Text(
                                    '占用资产数',
                                    style: TextStyle(
                                      color: Color(0xff9e9e9e),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 74),
                    child: Image.asset('images/logo_white.png'),
                  ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(children: [
            // 首页
            if (_selectedIndex == 0) ...[
              // 资产管理
              Card(
                margin: const EdgeInsets.only(top: 90, left: 12, right: 12),
                child: Column(children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 20, bottom: 14),
                      child: Text(
                        "资产管理",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/asset_add.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||入库');
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetAdd(),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('入库'),
                        ]),
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/use.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||领用');
                              var list = await scanquery(context);
                              if (list == null) return;

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetUse(
                                        list: list,
                                      ),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('领用'),
                        ]),
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/remand.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||归还');
                              var list = await scanquery(context);
                              if (list == null) return;

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetRemand(
                                        list: list,
                                      ),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('归还'),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/repair.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||维修');
                              var list = await scanquery(context);
                              if (list == null) return;

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetRepair(
                                        list: list,
                                      ),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('维修'),
                        ]),
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/transfer.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||转让');
                              var list = await scanquery(context);
                              if (list == null) return;

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetTransfer(
                                        list: list,
                                      ),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('转让'),
                        ]),
                        Column(children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Image.asset('images/scrap.png'),
                            iconSize: 44,
                            onPressed: () async {
                              debugPrint('|||报废');
                              var list = await scanquery(context);
                              if (list == null) return;

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => AssetScrap(
                                        list: list,
                                      ),
                                    ),
                                  )
                                  .then((x) => refresh());
                            },
                          ),
                          const Text('报废'),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ]),
                ]),
              ),
              // 资产占比统计图
              if (total != 0)
                Card(
                  margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                  child: Column(children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 20, bottom: 14),
                        child: Text(
                          "资产占比统计图",
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        // 资产占比统计图
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius: 60,
                                sections: baseOrg.asMap().entries.map((entry) {
                                  var item = entry.value;
                                  var index = entry.key;
                                  final isTouched = index == touchedIndex;
                                  final fontSize = isTouched ? 25.0 : 16.0;
                                  final radius = isTouched ? 45.0 : 35.0;
                                  double p = item['total'] / total * 100;

                                  return PieChartSectionData(
                                    color: colors[index],
                                    value: p,
                                    title: '${p.toStringAsFixed(1)}%',
                                    radius: radius,
                                    titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffffffff),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xff000000),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 120,
                              child: Column(children: [
                                const SizedBox(height: 29),
                                const Text(
                                  '资产总金额',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 24 / 16,
                                    color: Color(0xff4E5969),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  NumberFormat().format(total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    height: 1,
                                    color: Color(0xff1D2129),
                                    shadows: [
                                      Shadow(
                                        color: Color(0xffffffff),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        direction: Axis.horizontal,
                        runSpacing: 10,
                        spacing: 10,
                        children: [
                          ...baseOrg.asMap().entries.map((entry) {
                            var index = entry.key;
                            var item = entry.value;
                            return SizedBox(
                              width: (100.w - 12 * 2 - 16 * 2 - 10) / 2,
                              child: Center(
                                child: RichText(
                                  softWrap: false,
                                  text: TextSpan(children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors[index],
                                        ),
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Text(
                                        item['title'],
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              // 基础信息
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 20, bottom: 14),
                      child: Text(
                        "基础信息",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Column(children: [
                    // TODO 结构优化
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0x201A77FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.only(top: 12, bottom: 7),
                            child: Column(children: const [
                              Image(image: AssetImage("images/org.png")),
                              Text('机构管理'),
                            ]),
                          ),
                          onTap: () async {
                            debugPrint('||| 组织架构');
                            var root = [];

                            var res = await Api.organization.query();
                            if (res == 0) return;
                            var map = {};
                            // to map
                            res['data']['list'].forEach((item) {
                              map[item['id']] = item;
                              // 初始化
                              item['children'] = [];
                            });
                            // build tree
                            res['data']['list'].forEach((item) {
                              var parent = map[item['parent']];
                              if (parent != null) {
                                parent['children'].add(item);
                              } else {
                                // 根元素无父节点
                                root.add(item);
                              }
                            });
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => AssetOrg(list: root),
                                  ),
                                )
                                .then((x) => refresh());
                          },
                        ),
                        InkWell(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0x201A77FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.only(top: 12, bottom: 7),
                            child: Column(children: const [
                              Image(image: AssetImage("images/catalog.png")),
                              Text('资产分类'),
                            ]),
                          ),
                          onTap: () async {
                            debugPrint('|||资产分类');
                            var res = await Api.catalog.query();
                            if (res == 0) return;
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(
                                      name: 'catalog--',
                                    ),
                                    builder: (context) => AssetCatalog(
                                      list: res['data']['list'],
                                      nav: const [
                                        {'id': '-', 'name': '资产分类'}
                                      ],
                                    ),
                                  ),
                                )
                                .then((x) => refresh());
                          },
                        ),
                        InkWell(
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0x201A77FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.only(top: 12, bottom: 7),
                            child: Column(children: const [
                              Image(image: AssetImage("images/vendor.png")),
                              Text('供应商管理'),
                            ]),
                          ),
                          onTap: () async {
                            debugPrint('||| 供应商');
                            var res = await Api.vendor.query();
                            if (res == 0) return;
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AssetVendor(list: res['data']['list']),
                                  ),
                                )
                                .then((x) => refresh());
                          },
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
            // 我的
            if (_selectedIndex != 0) ...[
              Card(
                margin: const EdgeInsets.only(top: 20, left: 12, right: 12),
                child: Column(children: [
                  // 修改密码
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        width: 1,
                        color: Color(0xffF2F3F5),
                      )),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Row(children: const [
                        SizedOverflowBox(
                          size: Size(0, 0),
                          child: Icon(Icons.lock, color: Color(0xffd9d9d9)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            '修改密码',
                            style: TextStyle(color: Color(0xff212121)),
                          ),
                        ),
                        Spacer(),
                        SizedOverflowBox(
                          size: Size(0, 0),
                          child: Icon(Icons.arrow_forward_ios,
                              color: Color(0xff9e9e9e)),
                        ),
                      ]),
                      onPressed: () {
                        debugPrint('||| 修改密码');
                        navigator(context, Password());
                      },
                    ),
                  ),
                  // 关于
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        width: 1,
                        color: Color(0xffF2F3F5),
                      )),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Row(children: const [
                        SizedOverflowBox(
                          size: Size(0, 0),
                          child: Icon(Icons.person_sharp,
                              color: Color(0xffd9d9d9)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            '关于',
                            style: TextStyle(color: Color(0xff212121)),
                          ),
                        ),
                        Spacer(),
                        SizedOverflowBox(
                          size: Size(0, 0),
                          child: Icon(Icons.arrow_forward_ios,
                              color: Color(0xff9e9e9e)),
                        ),
                      ]),
                      onPressed: () {
                        debugPrint('||| 关于');
                        navigator(context, About());
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 50, left: 20, right: 20, bottom: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xffF2F5F9),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    width: 100.w,
                    height: 60,
                    child: InkWell(
                      onTap: () {
                        debugPrint('||| 退出登录');
                        Navigator.of(context).popAndPushNamed('login');
                      },
                      child: const Center(
                        child: Text(
                          '退出登录',
                          style: TextStyle(
                            color: Color(0xff9E9E9E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              )
            ],
            // 底部导航占位
            const SizedBox(height: 117),
          ]),
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
                    // appBar: 160 bg: 117 navbar: bottomHeight
                    top: 100.h - 160 - 117 - bottomHeight,
                    child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/bottom_nav_bg.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        // TODO 重构 首页 我的
                        children: <Widget>[
                          // 首页
                          SizedBox(
                            width: (100 / 3).w,
                            child: Column(children: [
                              const SizedBox(height: 21),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                  });
                                },
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      color: Color(_selectedIndex == 0
                                          ? 0xff212121
                                          : 0xff9e9e9e),
                                      Icons.home,
                                      size: 24,
                                    ),
                                    Text(
                                      '首页',
                                      style: TextStyle(
                                          color: Color(_selectedIndex == 0
                                              ? 0xff212121
                                              : 0xff9e9e9e)),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          // 扫码
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
                                      icon: Image.asset('images/scan.png'),
                                      iconSize: 60,
                                      onPressed: () async {
                                        debugPrint('|||查询');
                                        var list = await scanquery(context);
                                        if (list == null) return;
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) => AssetInfo(
                                                  list: list,
                                                ),
                                              ),
                                            )
                                            .then((x) => refresh());
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 我的
                          SizedBox(
                            width: (100 / 3).w,
                            child: Column(children: [
                              const SizedBox(height: 21),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      color: Color(_selectedIndex == 1
                                          ? 0xff212121
                                          : 0xff9e9e9e),
                                      Icons.person_sharp,
                                      size: 24,
                                    ),
                                    Text(
                                      '我的',
                                      style: TextStyle(
                                          color: Color(_selectedIndex == 1
                                              ? 0xff212121
                                              : 0xff9e9e9e)),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
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
