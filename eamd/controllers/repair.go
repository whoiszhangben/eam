package controllers

import (
	"eamd/models"
	"eamd/tools"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"
	"os"
	"time"
)

type Repair struct {
	AbsAnswer
	AbsPagination  `json:"pagination"`
	GoodsId        []int64  `json:"goodsId"`
	OrganizationId []int    `json:"organizationId"`
	DeptCode       []string `json:"deptCode"`
	Keyword        string   `json:"keyword"`
}

func (this Repair) HandAdd(ctx *gin.Context) {
	var info models.RepairModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	err = models.DB.Model(&models.GoodsModel{}).Select("organizationid").Where("id = ?", info.GoodsId).Scan(&info.OrganizationId).Error
	if err != nil {
		this.Ans(ctx, err)
	}
	info.Ctime = time.Now()
	err = models.DB.Model(&models.RepairModel{}).Create(&info).Error
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_REPAIR, models.OPT_TYPE_ADD, "")
	}
}

func (this Repair) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	var columns string
	var qVaues []interface{}
	oids := make([]int, 0)
	if len(this.OrganizationId) > 0 {
		for _, oid := range this.OrganizationId {
			oids = append(oids, tools.GetChildOrg(oid)...)
			oids = append(oids, oid)
		}

		columns = "repair.organizationid in ? "
		qVaues = append(qVaues, oids)
	}

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "(repair.description like ? or  repair.goodsid in (select id from goods where name like ? ) ) "
		qVaues = append(qVaues, this.Keyword)
	}

	if len(this.DeptCode) > 0 {
		if columns != "" {
			columns += " and "
		}

		columns += " repair.organizationid  in  (select id  from organization where code in ?  ) "
		qVaues = append(qVaues, this.DeptCode)
	}

	if len(this.GoodsId) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " repair.goodsid  in  ? "
		qVaues = append(qVaues, this.GoodsId)
	}

	var repair []models.RepairExportModel
	err = models.DB.Model(&models.RepairModel{}).Select("repair.*, goods.name gname, goods.model gmodel, organization.name oname, gsort.gsname ").
		Joins("left join goods  on repair.goodsid= goods.id ").Joins("left join  organization on organization.id = repair.organizationid ").
		Joins("left join (select goods.id goodsid,  gsort.name gsname  from goods  left join gsort on  gsort.id= goods.id ) as gsort on  gsort.goodsid = repair.goodsid").
		Where(columns, qVaues...).Order("ctime desc").Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&repair).Error

	var count int64
	models.DB.Model(&models.RepairModel{}).Where(columns, qVaues...).Count(&count)
	this.Success(ctx, map[string]interface{}{"list": repair, "total": count, "page": this.Page, "pageSize": this.PageSize})
}

func (this Repair) Export(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	var columns string
	var qVaues []interface{}

	oids := make([]int, 0)
	if len(this.OrganizationId) > 0 {
		for _, oid := range this.OrganizationId {
			oids = append(oids, tools.GetChildOrg(oid)...)
			oids = append(oids, oid)
		}

		columns = "repair.organizationid in ? "
		qVaues = append(qVaues, oids)
	}

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "(repair.description like ? or  repair.goodsid in (select id from goods where name like ? ) ) "
		qVaues = append(qVaues, this.Keyword)
	}

	if len(this.DeptCode) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " repair.organizationid  in  (select id  from organization where code in ?  ) "
		qVaues = append(qVaues, this.DeptCode)
	}

	if len(this.GoodsId) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " repair.goodsid  in  ? "
		qVaues = append(qVaues, this.GoodsId)
	}

	var repair []models.RepairExportModel
	err = models.DB.Model(&models.RepairModel{}).Select("repair.*, goods.name gname, goods.model gmodel, organization.name oname, gsort.gsname ").
		Joins("left join goods  on repair.goodsid= goods.id ").
		Joins("left join  organization on organization.id = repair.organizationid ").
		Joins("left join (select goods.id goodsid,  gsort.name gsname from goods  left join gsort on  gsort.id= goods.id ) as gsort on  gsort.goodsid = repair.goodsid").Where(columns, qVaues...).Find(&repair).Error
	if err != nil {
		this.FailString(ctx, "查询维修记录列表失败！")
		return
	}

	filePath, err := this.SaveMsg(repair)
	if err != nil {
		this.FailString(ctx, "导出数据失败！")
		return
	}

	ctx.File(filePath)
	os.Remove(filePath)
	AddLog(ctx, models.TABLE_TYPE_REPAIR, models.OPT_TYPE_EXPORT, "")
}

func (this Repair) SaveMsg(infos []models.RepairExportModel) (string, error) {
	f := excelize.NewFile()
	title := "固定资产维修清单"
	sheet := "Sheet1"
	err := f.MergeCell(sheet, "A1", "H1")
	f.SetSheetRow(sheet, "A1", &[]interface{}{title}) //设置工作表的名称
	if err != nil {
		return "", err
	}
	Al_style, err := f.NewStyle(`{"alignment":{
    "horizontal":"center",
    "vertical":"center"
}}`)

	f.SetSheetRow(sheet, "A2", &[]interface{}{"序号", "资产名称", "规格/型号", "类别", "使用部门", "维修金额", "维修时间", "备注"})

	index := 1
	for _, item := range infos {
		code, _ := tools.Redisdb.HGet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", item.Id)).Result()
		code += fmt.Sprintf("%05v", item.Id)

		f.SetSheetRow(sheet, fmt.Sprintf("A%v", index+2), &[]interface{}{index, item.Gname, item.Gmodel, item.Gsname, item.Oname, item.Price,
			item.Ctime.Format("2006-01-02 15:04:05"), item.Description})
		index++
	}

	if err := f.SetCellStyle(sheet, "A1", fmt.Sprintf("O%v", index+2), Al_style); err != nil {
		return "", err
	}

	filename := time.Now().Format("20060102150405") + ".xlsx"
	err = f.SaveAs(filename)
	if err != nil {
		fmt.Println(fmt.Sprintf("保存文件失败,错误:%s", err))
		return "", err
	}
	f.Close()

	return filename, nil
}
