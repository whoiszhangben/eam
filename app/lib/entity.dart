class Goods {
  final int id;
  final String name;
  final int orgid;
  final int buytime;
  final String model;
  final int amount;
  final String unit;
  final double price;
  final int sortid;
  final int state;
  final String description;

  const Goods({
    required this.id,
    required this.name,
    required this.orgid,
    required this.buytime,
    required this.model,
    required this.amount,
    required this.unit,
    required this.price,
    required this.sortid,
    required this.state,
    required this.description,
  });

  factory Goods.fromJson(Map<String, dynamic> json) {
    return Goods(
      id: json['id'],
      name: json['name'],
      orgid: json['orgid'],
      buytime: json['buytime'],
      model: json['model'],
      amount: json['amount'],
      unit: json['unit'],
      price: json['price'],
      sortid: json['sortid'],
      state: json['state'],
      description: json['description'],
    );
  }
}

class Organization {
  final int id;
  final String name;
  final String code;
  final int parent;
  final String description;

  const Organization({
    required this.id,
    required this.name,
    required this.code,
    required this.parent,
    required this.description,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      parent: json['parent'],
      description: json['description'],
    );
  }
}

class Gsort {
  final int id;
  final String name;
  final String code;
  final String description;

  const Gsort({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory Gsort.fromJson(Map<String, dynamic> json) {
    return Gsort(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
    );
  }
}

class Account {
  final int id;
  final String account;
  final String password;
  final int role;
  final String description;
  final bool enable;
  final int ctime;

  const Account({
    required this.id,
    required this.account,
    required this.password,
    required this.role,
    required this.description,
    required this.enable,
    required this.ctime,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      account: json['account'],
      password: json['password'],
      role: json['role'],
      description: json['description'],
      enable: json['enable'],
      ctime: json['ctime'],
    );
  }
}

class Flowinglog {
  final int id;
  final int accountid;
  final int createtime;
  final int goodsid;
  final String user;
  final int state;
  final String description;

  const Flowinglog({
    required this.id,
    required this.accountid,
    required this.createtime,
    required this.goodsid,
    required this.user,
    required this.state,
    required this.description,
  });

  factory Flowinglog.fromJson(Map<String, dynamic> json) {
    return Flowinglog(
      id: json['id'],
      accountid: json['accountid'],
      createtime: json['createtime'],
      goodsid: json['goodsid'],
      user: json['user'],
      state: json['state'],
      description: json['description'],
    );
  }
}
