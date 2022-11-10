package controllers

import (
	"eamd/models"
	"eamd/tools"
	"fmt"
	"github.com/gin-gonic/gin"
)

type Gsort struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
	Keyword       string `json:"keyword"`
}

func (this Gsort) HandAdd(ctx *gin.Context) {
	var info models.GSortModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	if info.Code == "" {
		this.FailString(ctx, "非法的类别编号")
		return
	}
	if len(info.Code) < 2 {
		info.Code = "0" + info.Code
	}

	var count int64
	err = models.DB.Model(&models.GSortModel{}).Where("code= ?", info.Code).Count(&count).Error
	if err != nil {
		this.Ans(ctx, err)
		return
	}
	if count > 0 {
		this.FailString(ctx, "该编号已经存在")
		return
	}
	err = models.DB.Create(&info).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}

	tools.Redisdb.HSet(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", info.Id), info.Code)
	tools.Redisdb.HSet(tools.REDIS_H_GSORT_CODE_ID, info.Code, info.Id)
	this.Success(ctx, info)
	AddLog(ctx, models.TABLE_TYPE_GSORT, models.OPT_TYPE_ADD, "")
}

func (this Gsort) HandRemove(ctx *gin.Context) {
	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Delete(&models.GSortModel{}, ids["id"]).Error
	if err != nil {
		this.FailString(ctx, "该资源正在使用，无法删除")
		return
	}
	for _, v := range ids["id"] {
		code, _ := tools.Redisdb.HGet(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", v)).Result()
		tools.Redisdb.HDel(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", v))
		tools.Redisdb.HDel(tools.REDIS_H_GSORT_CODE_ID, code)
	}
	this.Success(ctx, nil)
	AddLog(ctx, models.TABLE_TYPE_GSORT, models.OPT_TYPE_DELETE, "")
}

func (this Gsort) HandModify(ctx *gin.Context) {
	var info models.GSortModel

	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Save(&info).Error
	if err == nil {
		code, _ := tools.Redisdb.HGet(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", info.Id)).Result()
		if code != info.Code {
			tools.Redisdb.HDel(tools.REDIS_H_GSORT_CODE_ID, code)
			tools.Redisdb.HSet(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", info.Id), info.Code)
			tools.Redisdb.HSet(tools.REDIS_H_GSORT_CODE_ID, info.Code, info.Id)
		}
	}
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_GSORT, models.OPT_TYPE_MODIFY, "")
	}
}

func (this Gsort) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var columns string
	var qVaues []interface{}

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "name like ? or code like ? or description like ? "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword)
	}

	var gsorts []models.GSortModel
	err = models.DB.Model(&models.GSortModel{}).Preload("ChildGsort").Where(columns, qVaues...).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&gsorts).Error
	if err != nil {
		this.Ans(ctx, err)
		return
	}
	var count int64
	models.DB.Model(&models.GSortModel{}).Count(&count)
	this.Success(ctx, map[string]interface{}{"list": gsorts, "total": count, "page": this.Page, "pageSize": this.PageSize})
}
