package controllers

import (
	"eamd/models"
	"eamd/printm"
	"github.com/gin-gonic/gin"
)

type PrintLabel struct {
	AbsAnswer
	GoodsId []int64 `json:"goodsId"`
	Print   string  `json:"print"`
}

type PrintLabelAll struct {
	OrgId    []int64  `json:"orgId"`
	Keyword  string   `json:"keyword"`
	DeptCode []string `json:"DeptCode"`
	Print    string   `json:"print"`
}

func (this PrintLabel) HandCheck(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}
	var goods []models.GoodsModel
	err = models.DB.Model(&models.GoodsModel{}).Select("goods.*, organization.name organizationName").Where("goods.id in ?", this.GoodsId).Joins("left join organization on goods.organizationid = organization.id").Find(&goods).Error
	if err != nil {
		this.FailString(ctx, "查询资产列表失败！")
		return
	}

	go func() {
		printm.PrintLabel(this.Print, goods)
	}()
	this.Ans(ctx, err)
	AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_PRINT, "")
}

func (this PrintLabel) HandAll(ctx *gin.Context) {
	var info PrintLabelAll
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var condition string
	var value []interface{}

	if len(info.OrgId) > 0 {
		condition = "organizationid in ?"
		value = append(value, info.OrgId)
	}

	if info.Keyword != "" {
		if condition != "" {
			condition += " and "
		}
		info.Keyword = "%" + info.Keyword + "%"
		condition += "(goods.name like ? or goods.custodian like ? or goods.model like ? or goods.savelocation like ? or goods.description like ? ) "
		value = append(value, info.Keyword, info.Keyword, info.Keyword, info.Keyword, info.Keyword)
	}

	if len(info.DeptCode) > 0 {
		if condition != "" {
			condition += " and "
		}
		condition += " organizationid  in  (select id  from organization where code in ?  ) "
		value = append(value, info.DeptCode)
	}

	var goods []models.GoodsModel
	err = models.DB.Model(&models.GoodsModel{}).Select("goods.*, organization.name organizationName").Where(condition, value...).Joins("left join organization on goods.organizationid = organization.id").Scan(&goods).Error
	if err != nil {
		this.FailString(ctx, "查询资产列表失败！")
		return
	}

	go func() {
		printm.PrintLabel(info.Print, goods)
	}()
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_PRINT, "")
	}
}
