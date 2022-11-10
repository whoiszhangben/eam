/// 关于
import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  About({
    super.key,
  });

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleBar('关于宏凯'),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '宏凯实业集团',
                style: TextStyle(fontSize: 20, height: 28 / 20),
              ),
              SizedBox(height: 10),
              Text(
                '宏凯实业集团成立于2008年，旗下拥有香港宏凯实业、江苏金亿达能、江苏瑞恒中显光电、盐城吉凯同、山东济宁汇金升等11家子、分公司和多个事业部。在职员工900余名，分别在广东省深圳市、江苏省镇江市、江苏省盐城市、山东省济宁市拥有4个研发及生产基地。集团总部位于广东省深圳市龙华区宏凯智能产业园，是一家集研发、生产、销售于一体的专业从事移动智能3C、物联网解决方案、供应链解决方案、LCM、PCBA等多元化经营结构的集团企业。经过多年长足发展，宏凯实业集团已跻身国家级高新技术企业行列，并获得多项国家级和省市级荣誉，2020年销售额已突破20亿元。\n\n宏凯经过十多年的努力，现已拥有500多款上线产品，每月出货量100万台以上。截至2020年5月，创立COOLHILLS、GOPHONIC及久疆等六大自主品牌并获专利200余项、国内外合作品牌多达46项以上，在欧洲、南美洲、北美洲、俄罗斯、东南亚等地拥有稳定的客户群体，并先后和中国移动、中国联通、中国电信等建立了长期稳定的合作关系。\n\n凭借宏凯在智能制造业多年沉淀的综合实力，今后我们将一如既往地致力于智能终端产业链的差异化布局，不断提升自己的核心竞争力！',
                style: TextStyle(fontSize: 14, height: 22 / 14),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
