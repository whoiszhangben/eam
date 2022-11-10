INSERT INTO `account`(`id`,`account`,`name`,`password`,`role`,enable) VALUES (1,"admin","hk","da9f0af16e337e440951b0c7980d3fdd",1,1);
INSERT INTO `account`(`id`,`account`,`name`,`password`,`role`,enable) VALUES (2,"admin2","hk","e19d5cd5af0378da05f63f891c7467af",1,1);
insert into organization (id, name, code,isdept) values (1, '宏凯集团', 'HK',false);
insert into organization (id, name, code, parent,isdept) values (3,'深圳总部', 'SZ', 1, false);
insert into organization (id, name, code, parent,isdept) values (5,'镇江基地', 'ZJ', 1, false);
insert into organization (id, name, code, parent,isdept) values (7,'盐城基地', 'YC', 1, false);
insert into organization (id, name, code, parent,isdept) values (9,'济宁基地', 'JN', 1, false);


insert into organization (name, code, parent,isdept) values ('董事办', 'A', 3, true);
insert into organization (name, code, parent,isdept) values ('财务中心', 'F', 3, true);
insert into organization (name, code, parent,isdept) values ('人力资源行政中心', 'H', 3, true);
insert into organization (name, code, parent,isdept) values ('投融资部', 'I', 3, true);
insert into organization (name, code, parent,isdept) values ('供应链事业部', 'G', 3, true);
insert into organization (name, code, parent,isdept) values ('智能3C事业部', 'C', 3, true);
insert into organization (name, code, parent,isdept) values ('屏事业部', 'L', 3, true);
insert into organization (name, code, parent,isdept) values ('科创事业部', 'K', 3, true);
insert into organization (name, code, parent,isdept) values ('物联网事业部', 'W', 3, true);
insert into organization (name, code, parent,isdept) values ('制造事业部', 'M', 3, true);
insert into organization (name, code, parent,isdept) values ('SMT事业部', 'S', 3, true);


insert into organization (name, code, parent,isdept) values ('董事办', 'A', 5, true);
insert into organization (name, code, parent,isdept) values ('财务中心', 'F', 5, true);
insert into organization (name, code, parent,isdept) values ('人力资源行政中心', 'H', 5, true);
insert into organization (name, code, parent,isdept) values ('投融资部', 'I', 5, true);
insert into organization (name, code, parent,isdept) values ('供应链事业部', 'G', 5, true);
insert into organization (name, code, parent,isdept) values ('智能5C事业部', 'C', 5, true);
insert into organization (name, code, parent,isdept) values ('屏事业部', 'L', 5, true);
insert into organization (name, code, parent,isdept) values ('科创事业部', 'K', 5, true);
insert into organization (name, code, parent,isdept) values ('物联网事业部', 'W', 5, true);
insert into organization (name, code, parent,isdept) values ('制造事业部', 'M', 5, true);
insert into organization (name, code, parent,isdept) values ('SMT事业部', 'S', 5, true);


insert into organization (name, code, parent,isdept) values ('董事办', 'A', 7, true);
insert into organization (name, code, parent,isdept) values ('财务中心', 'F', 7, true);
insert into organization (name, code, parent,isdept) values ('人力资源行政中心', 'H', 7, true);
insert into organization (name, code, parent,isdept) values ('投融资部', 'I', 7, true);
insert into organization (name, code, parent,isdept) values ('供应链事业部', 'G', 7, true);
insert into organization (name, code, parent,isdept) values ('智能7C事业部', 'C', 7, true);
insert into organization (name, code, parent,isdept) values ('屏事业部', 'L', 7, true);
insert into organization (name, code, parent,isdept) values ('科创事业部', 'K', 7, true);
insert into organization (name, code, parent,isdept) values ('物联网事业部', 'W', 7, true);
insert into organization (name, code, parent,isdept) values ('制造事业部', 'M', 7, true);
insert into organization (name, code, parent,isdept) values ('SMT事业部', 'S', 7, true);


insert into organization (name, code, parent,isdept) values ('董事办', 'A', 9, true);
insert into organization (name, code, parent,isdept) values ('财务中心', 'F', 9, true);
insert into organization (name, code, parent,isdept) values ('人力资源行政中心', 'H', 9, true);
insert into organization (name, code, parent,isdept) values ('投融资部', 'I', 9, true);
insert into organization (name, code, parent,isdept) values ('供应链事业部', 'G', 9, true);
insert into organization (name, code, parent,isdept) values ('智能9C事业部', 'C', 9, true);
insert into organization (name, code, parent,isdept) values ('屏事业部', 'L', 9, true);
insert into organization (name, code, parent,isdept) values ('科创事业部', 'K', 9, true);
insert into organization (name, code, parent,isdept) values ('物联网事业部', 'W', 9, true);
insert into organization (name, code, parent,isdept) values ('制造事业部', 'M', 9, true);
insert into organization (name, code, parent,isdept) values ('SMT事业部', 'S', 9, true);



insert into gsort(name, code, description) values('建筑类', '01', '房屋及其他建筑物');
insert into gsort(name, code, description) values('生产设备', '02', '生产用机械设备');
insert into gsort(name, code, description) values('运输工具', '03', '汽车');
insert into gsort(name, code, description) values('办公设备', '04', '电脑、打印机、复印机、投影仪、照相机、服务器等电子信息化办公硬件设施设备');
insert into gsort(name, code, description) values('办公家具', '05', '沙发、办公桌椅、茶几书柜、文件柜、保险柜');
insert into gsort(name, code, description) values('电器设备', '06', '空调、冰箱、洗衣机、电视机、饮水机、风扇');
insert into gsort(name, code, description) values('软件应用', '07', '有价软件');
insert into gsort(name, code, description) values('环安设备', '08', '环境安全类设施设备');
