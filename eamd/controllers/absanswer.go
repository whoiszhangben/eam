package controllers

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type AbsAnswer struct {
}

type AbsPagination struct {
	PageSize int    `json:"pageSize"`
	SortBy   string `json:"sortBy"`
	Page     int    `json:"page"`
	Order    int    `json:"order"`
}

func (this *AbsAnswer) FailError(ctx *gin.Context, err error) {
	ctx.JSON(http.StatusOK, gin.H{
		"errcode": -1,
		"errmsg":  err.Error(),
	})
}

func (this *AbsAnswer) FailString(ctx *gin.Context, str string) {
	ctx.JSON(http.StatusOK, gin.H{
		"errcode": -1,
		"errmsg":  str,
	})
}

func (this *AbsAnswer) Success(ctx *gin.Context, data interface{}) {
	ctx.JSON(http.StatusOK, gin.H{
		"data":    data,
		"errcode": 0,
		"errmsg":  "",
	})
}

func (this *AbsAnswer) Ans(ctx *gin.Context, err error) {
	if err != nil {
		this.FailError(ctx, err)
	} else {
		this.Success(ctx, nil)
	}
}
