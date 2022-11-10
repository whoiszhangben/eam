import 'dart:convert';
import 'dart:io';

import 'package:asset_management_system/utils.dart';
import 'package:crypto/crypto.dart';

var baseUrl = prefs.getString('baseUrl') ?? 'http://192.168.3.251:8080';

class Api {
  static Account account = Account();
  static Organization organization = Organization();
  static Catalog catalog = Catalog();
  static CatalogChild catalogChild = CatalogChild();
  static Statistics statistics = Statistics();
  static Goods goods = Goods();
  static Vendor vendor = Vendor();
}

class Vendor {
  add(item) async {
    return httpPost('$baseUrl/eam/vendor/add', item);
  }

  query([keyword = '']) async {
    return httpPost('$baseUrl/eam/vendor/query', {
      "pagination": {"pageSize": 1000, "sortBy": "", "page": 1},
      "keyword": keyword,
    });
  }
}

class Account {
  // 登录
  login(String account, String password) async {
    var pwdHash = sha256
        .convert(
          utf8.encode('$account$password'),
        )
        .toString();
    var clientType = Platform.isAndroid ? 2 : 3;
    var res = await httpPost(
      '$baseUrl/eam/account/login',
      {
        'account': account,
        'password': pwdHash,
        'clientType': clientType,
      },
    );
    if (res != 0) {
      prefs.setString('token', res['data']['token']);
      prefs.setString('accountJson', jsonEncode(res['data']));
    }
    return res;
  }

  password(password, oldPassword) async {
    var accountJson = prefs.getString('accountJson');
    var accountInfo = jsonDecode(accountJson ?? '{}');
    var account = accountInfo['account'];
    var pwdHash = sha256
        .convert(
          utf8.encode('$account$password'),
        )
        .toString();
    var oldPasswordHash = sha256
        .convert(
          utf8.encode('$account$oldPassword'),
        )
        .toString();
    return httpPost('$baseUrl/eam/account/modify', {
      'id': accountInfo['id'],
      'password': pwdHash,
      'oldPassword': oldPasswordHash,
    });
  }
}

// 机构
class Organization {
  // 增加
  add(item) async {
    return httpPost('$baseUrl/eam/organization/add', item);
  }

  // 删除
  remove(id) async {
    return httpPost('$baseUrl/eam/organization/remove', {
      'id': [id]
    });
  }

  // 修改
  modify(item) async {
    return httpPost('$baseUrl/eam/organization/modify', item);
  }

  // 列表
  query() async {
    return httpPost('$baseUrl/eam/organization/query');
  }
}

// 资产分类
class Catalog {
  // 增加
  add(item) async {
    return httpPost('$baseUrl/eam/gsort/add', item);
  }

  // 删除
  remove(id) async {
    return httpPost('$baseUrl/eam/gsort/remove', {
      'id': [id]
    });
  }

  // 修改
  modify(item) async {
    return httpPost('$baseUrl/eam/gsort/modify', item);
  }

  //列表
  query() async {
    return httpPost('$baseUrl/eam/gsort/query', {
      "pagination": {"pageSize": 1000, "sortBy": "", "page": 1},
    });
  }
}

// 资产子分类
class CatalogChild {
  // 增加
  add(item) async {
    return httpPost('$baseUrl/eam/childgsort/add', item);
  }

  // 删除
  remove(id) async {
    return httpPost('$baseUrl/eam/childgsort/remove', {
      'id': [id]
    });
  }

  // 修改
  modify(item) async {
    return httpPost('$baseUrl/eam/childgsort/modify', item);
  }

  // 列表
  query(parentId) async {
    return httpPost('$baseUrl/eam/childgsort/query', {
      "pagination": {"pageSize": 1000, "sortBy": "", "page": 1},
      "gsortid": [parentId],
    });
  }
}

class Statistics {
  // 主页简单的统计
  query() async {
    return httpPost('$baseUrl/eam/simplestatistics/query');
  }
}

class Goods {
  // 资产入库
  add(items) async {
    return httpPost('$baseUrl/eam/goods/add', {"goods": items});
  }

  // 领用、归还、转让、报废
  modify(items) async {
    return httpPost('$baseUrl/eam/goods/modify', {"goods": items});
  }

  // 维修
  repair(id, description, price) async {
    return httpPost('$baseUrl/eam/repair/add', {
      "goodsId": id,
      "description": description,
      "price": price,
    });
  }

  // 资产流水
  flowing(id) async {
    return httpPost('$baseUrl/eam/goodsflowing/query', {"goodsId": id});
  }

  // 扫码查询
  query(id) async {
    return httpPost(
      '$baseUrl/eam/goods/scanquery',
      {
        "id": id,
      },
    );
  }
}
