package controllers

import (
	"eamd/models"
	"github.com/gin-gonic/gin"
)

type Vendor struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
	Keyword       string `json:"keyword"`
}

func (this Vendor) HandAdd(ctx *gin.Context) {
	var info models.VendorModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	err = models.DB.Create(&info).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}

	this.Success(ctx, info)
}

func (this Vendor) HandRemove(ctx *gin.Context) {
	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Delete(&models.VendorModel{}, ids["id"]).Error
	if err != nil {
		this.FailString(ctx, "该资源正在使用，无法删除")
		return
	}
	this.Success(ctx, nil)
}

func (this Vendor) HandModify(ctx *gin.Context) {
	var info models.VendorModel

	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Updates(&info).Error
	this.Ans(ctx, err)
}

func (this Vendor) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var columns string
	var qVaues []interface{}

	if this.Keyword != "" {
		this.Keyword = "%" + this.Keyword + "%"
		columns += "(name like ? or phone like ? or addr like ? or description like ? ) "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword, this.Keyword)
	}

	var gsorts []models.VendorModel
	err = models.DB.Model(&models.VendorModel{}).Where(columns, qVaues...).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&gsorts).Error
	if err != nil {
		this.Ans(ctx, err)
		return
	}
	var count int64
	models.DB.Model(&models.VendorModel{}).Count(&count)
	this.Success(ctx, map[string]interface{}{"list": gsorts, "total": count, "page": this.Page, "pageSize": this.PageSize})
}
