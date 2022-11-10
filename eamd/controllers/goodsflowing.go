package controllers

import (
	"eamd/models"
	"github.com/gin-gonic/gin"
)

type GoodsFlowing struct {
	//Goods models.GoodsFlowingModel `json:"goods"`
	AbsAnswer
}

func (this GoodsFlowing) HandQuery(ctx *gin.Context) {
	var infos map[string]interface{}
	err := ctx.ShouldBindJSON(&infos)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}
	var flowing []models.GoodsFlowingModel
	err = models.DB.Model(&models.GoodsFlowingModel{}).Where("goodsid = ?", infos["goodsId"]).Find(&flowing).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	this.Success(ctx, flowing)
}
