package controllers

import (
	"eamd/models"
	"eamd/tools"
	"github.com/gin-gonic/gin"
	"time"
)

type Log struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
	Keyword       string `json:"keyword"`
}

func AddLog(ctx *gin.Context, table int, opt int, desc string) {
	var logInfo models.LogModel

	claims := tools.GetClaims(ctx)
	logInfo.Ctime = time.Now()
	logInfo.AccountId = claims.Id
	logInfo.OprType = table
	logInfo.Opt = opt
	logInfo.RemoteIp = ctx.RemoteIP()
	logInfo.Description = desc
	logInfo.ClientType = claims.ClientType

	models.DB.Model(&models.LogModel{}).Create(&logInfo)
}

func AddLoginLog(ctx *gin.Context, table int, opt int, desc string, userId int64, clientType int) {
	var logInfo models.LogModel
	logInfo.Ctime = time.Now()
	logInfo.AccountId = userId
	logInfo.OprType = table
	logInfo.Opt = opt
	logInfo.RemoteIp = ctx.RemoteIP()
	logInfo.Description = desc
	logInfo.ClientType = clientType

	models.DB.Model(&models.LogModel{}).Create(&logInfo)
}

func (this Log) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误"+err.Error())
		return
	}

	var columns string
	var qVaues []interface{}

	if this.Keyword != "" {
		this.Keyword = "%" + this.Keyword + "%"
		columns += "remoteip like ? or description like ? "
		qVaues = append(qVaues, this.Keyword, this.Keyword)
	}

	var log []models.LogModel
	models.DB.Model(&models.LogModel{}).Where(columns, qVaues...).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Order("ctime desc").Find(&log)
	var count int64
	models.DB.Model(&models.LogModel{}).Where(columns, qVaues...).Count(&count)
	this.AbsAnswer.Success(ctx, map[string]interface{}{"list": log, "total": count, "page": this.Page, "pageSize": this.PageSize})
}
