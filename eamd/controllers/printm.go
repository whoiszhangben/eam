package controllers

import (
	"eamd/printm"
	"github.com/gin-gonic/gin"
)

type Printcontrollers struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
}

func (this Printcontrollers) HandQuery(ctx *gin.Context) {
	info := printm.Clients
	infos := make([]interface{}, 0)

	for _, v := range info {
		infos = append(infos, v)
	}
	this.AbsAnswer.Success(ctx, infos)
}
