import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 返回 0 表示出错
httpPost(String url, [Object? body]) async {
  var headers = {
    "Content-Type": "application/json;charset=utf-8",
  };
  var request;
  try {
    SmartDialog.showLoading(backDismiss: false);
    debugPrint('||| httpPost:\nurl:$url\nbody:$body');
    if (!url.endsWith('/eam/account/login')) {
      headers['token'] = prefs.getString('token') ?? '';
    }

    var client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    request = await client.postUrl(Uri.parse(url));
    request.headers.add("Content-Type", "application/json;charset=utf-8");
    // 非登录接口需要校验 token
    if (!url.endsWith('/eam/account/login')) {
      request.headers.add("token", prefs.getString('token') ?? '');
    }
    request.add(utf8.encode(json.encode(body)));
    final response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    SmartDialog.dismiss(status: SmartStatus.loading);
    client.close();
    debugPrint('||| res.body$responseBody');
    var data = jsonDecode(responseBody);
    debugPrint('||| httpPost response:\n$data');
    if (data['errcode'] != 0) {
      SmartDialog.showToast(data['errmsg']);
      return 0;
    }
    return data;
  } on SocketException catch (_) {
    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.showToast('请求超时');
    debugPrint('||| 请求超时');
    request?.abort();
    return 0;
  } catch (e, stack) {
    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.showToast('请求异常');
    debugPrint('||| http err headers: $headers');
    debugPrint('||| http err url: $url');
    debugPrint('||| http err body: ${json.encode(body)}');
    debugPrint('||| http err e: $e');
    debugPrint('||| http err stack: $stack');
    return 0;
  }
}

late SharedPreferences prefs;

final List<String> shortDate = [yyyy, '-', mm, '-', dd];
final List<String> longDate = [...shortDate, ' ', hh, ':', nn, ':', ss];

double bottomHeight = 0;

Map<int, String> stateMap = {
  1: '闲置',
  2: '领用',
  3: '闲置', // 归还
  4: '遗失',
  5: '领用', // 转让
  6: '报废',
};

Map<int, String> stateFolwingMap = {
  1: '闲置',
  2: '领用',
  3: '归还',
  4: '遗失',
  5: '转让',
  6: '报废',
};

Map<String, String> toMap(org) {
  Map<String, String> obj = {};
  for (var element in org) {
    obj[element['id']] = element['name'].trim();
  }
  return obj;
}
