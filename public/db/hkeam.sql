/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2022-11-07 16:48:35                          */
/*==============================================================*/


drop table if exists account;

drop table if exists childgsort;

drop table if exists goods;

drop table if exists goodsflowing;

drop table if exists gsort;

drop table if exists log;

drop table if exists organization;

drop table if exists repair;

drop table if exists vendor;

/*==============================================================*/
/* Table: account                                               */
/*==============================================================*/
create table account
(
   id                   int not null auto_increment,
   account              varchar(32),
   password             varchar(64),
   name                 varchar(32),
   role                 int,
   description          varchar(32),
   enable               bool,
   ctime                datetime,
   primary key (id)
);

alter table account comment '账户';

/*==============================================================*/
/* Table: childgsort                                            */
/*==============================================================*/
create table childgsort
(
   id                   int not null auto_increment,
   name                 varchar(32),
   code                 varchar(32),
   gsortid              int,
   description          varchar(65),
   primary key (id)
);

/*==============================================================*/
/* Table: goods                                                 */
/*==============================================================*/
create table goods
(
   id                   int not null auto_increment,
   name                 varchar(32),
   gsortid              int,
   model                varchar(128),
   buytime              datetime,
   ctime	            datetime,
   price                decimal(8,2),
   organizationid       int,
   amount               int,
   unit                 varchar(10),
   state                int,
   savelocation         varchar(64) comment '存储位置',
   custodian            varchar(20) comment '保管人',
   description          varchar(32),
   lastuser             varchar(20) comment '最后的使用人',
   vendorid             int,
   warrantyperiod       int,
   pcount               int,
   childgsortid         int,
   primary key (id)
);

/*==============================================================*/
/* Table: goodsflowing                                          */
/*==============================================================*/
create table goodsflowing
(
   id                   int not null auto_increment,
   accountid            int,
   createtime           datetime,
   goodsid              int,
   user                 varchar(20),
   savelocation         varchar(32),
   organizationid       int,
   state                int,
   description          varchar(32),
   primary key (id)
);

/*==============================================================*/
/* Table: gsort                                                 */
/*==============================================================*/
create table gsort
(
   id                   int not null auto_increment,
   name                 varchar(32),
   code                 varchar(32),
   description          varchar(128),
   utime                datetime,
   primary key (id)
);

/*==============================================================*/
/* Table: log                                                   */
/*==============================================================*/
create table log
(
   id                   int not null auto_increment,
   accountid            int,
   oprtype              int,
   opt                  int,
   description          varchar(32),
   remoteip              varchar(21),
   clienttype           int,
   ctime                datetime,
   primary key (id)
);

/*==============================================================*/
/* Table: organization                                          */
/*==============================================================*/
create table organization
(
   id                   int not null auto_increment,
   name                 varchar(32),
   code                 varchar(32),
   parent               int,
   description          varchar(32),
   isdept               bool,
   primary key (id)
);

alter table organization comment '机构';

/*==============================================================*/
/* Table: repair                                                */
/*==============================================================*/
create table repair
(
   id                   int not null auto_increment,
   goodsid              int,
   price                decimal(8,2),
   ctime                datetime,
   description          varchar(128),
   organizationid       int,
   primary key (id)
);

alter table repair comment '维修记录表';

/*==============================================================*/
/* Table: vendor                                                */
/*==============================================================*/
create table vendor
(
   id                   int not null auto_increment,
   name                 varchar(32),
   phone                varchar(15),
   addr                 varchar(64),
   description          varchar(64),
   primary key (id)
);

alter table childgsort add constraint FK_children_gsort_id foreign key (gsortid)
      references gsort (id) on delete restrict on update restrict;

alter table goods add constraint FK_Relationship_12 foreign key (childgsortid)
      references childgsort (id) on delete restrict on update restrict;

alter table goods add constraint FK_goods_org_id foreign key (organizationid)
      references organization (id) on delete restrict on update restrict;

alter table goods add constraint FK_goods_sort_id foreign key (gsortid)
      references gsort (id) on delete restrict on update restrict;

alter table goods add constraint FK_goods_vendor_id foreign key (vendorid)
      references vendor (id) on delete restrict on update restrict;

alter table goodsflowing add constraint FK_flowinglog_account_id foreign key (accountid)
      references account (id) on delete restrict on update restrict;

alter table goodsflowing add constraint FK_flowinglog_organization foreign key (organizationid)
      references organization (id) on delete restrict on update restrict;

alter table goodsflowing add constraint FK_goodsflowing_goods_id foreign key (goodsid)
      references goods (id) on delete restrict on update restrict;

alter table log add constraint FK_log_account_id foreign key (accountid)
      references account (id) on delete restrict on update restrict;

alter table repair add constraint FK_repair_goods_id foreign key (goodsid)
      references goods (id) on delete restrict on update restrict;

alter table repair add constraint FK_reqpair_orgianzaiton_id foreign key (organizationid)
      references organization (id) on delete restrict on update restrict;

