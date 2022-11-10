package controllers

import (
	"crypto/md5"
	"eamd/models"
	"eamd/tools"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type AccountInfo struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
	Keyword       string `json:"keyword"`
}

type AccountModifyPasswd struct {
	AbsAnswer
	Id          int64  `json:"id"`
	OldPassword string `json:"oldPassword"`
	NewPassword string `json:"newPassword"`
}

func (this AccountInfo) HandLogin(ctx *gin.Context) {

	var accountjson models.AccountModel
	err := ctx.ShouldBindJSON(&accountjson)
	if err != nil {
		this.AbsAnswer.FailString(ctx, "json格式错误！")
		return
	}

	accountInfoList := []models.AccountModel{}
	models.DB.Where("account=? and password=? and enable = true", accountjson.Account, fmt.Sprintf("%x", md5.Sum([]byte(accountjson.Password)))).First(&accountInfoList)
	if len(accountInfoList) > 0 {
		token, expireTimestamp, err := tools.MakeToen(accountInfoList[0].Id, accountjson.Account, accountjson.Password, accountInfoList[0].Role, accountjson.ClientType)
		if err != nil {
			this.AbsAnswer.FailError(ctx, err)
			return
		}
		ctx.Header("token", token)
		this.Success(ctx, map[string]interface{}{"id": accountInfoList[0].Id, "role": accountInfoList[0].Role, "name": accountInfoList[0].Name, "account": accountInfoList[0].Account, "token": token, "expireTime": expireTimestamp})
		AddLoginLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_LOGIN, "", accountInfoList[0].Id, accountjson.ClientType)
	} else {
		this.AbsAnswer.FailString(ctx, "账户或者用户名错误！")
	}
}

func (this AccountInfo) HandAdd(ctx *gin.Context) {
	var accountjson models.AccountModel
	err := ctx.ShouldBindJSON(&accountjson)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	accessList := []models.AccountModel{}
	models.DB.Where("account = ?", accountjson.Account).Find(&accessList)
	fmt.Println(accountjson.Account, len(accessList))
	if len(accessList) > 0 {
		fmt.Println(accessList[0].Enable)
		if accessList[0].Enable == false {
			accountjson.Id = accessList[0].Id
			accessList[0] = accountjson
			accessList[0].Password = fmt.Sprintf("%x", md5.Sum([]byte(accountjson.Password)))
			accessList[0].Ctime = time.Now()
			accessList[0].Enable = true
			err := models.DB.Save(&accessList).Error
			this.AbsAnswer.Ans(ctx, err)
			return
		}
		this.AbsAnswer.FailString(ctx, "该用户名已经存在，无法添加！")
		return
	}

	accountjson.Enable = true
	accountjson.Ctime = time.Now()
	accountjson.Password = fmt.Sprintf("%x", md5.Sum([]byte(accountjson.Password)))
	err = models.DB.Create(&accountjson).Error
	this.Ans(ctx, err)
	AddLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_ADD, "")
}

func (this AccountInfo) HandRemove(ctx *gin.Context) {

	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	err = models.DB.Debug().Model(&models.AccountModel{}).Where("id in ?", ids["id"]).Update("enable", false).Error
	if err != nil {
		this.AbsAnswer.FailString(ctx, "删除用户失败："+err.Error())
		return
	} else {
		this.AbsAnswer.Success(ctx, nil)
	}
	AddLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_DELETE, "")
}

func (this AccountInfo) HandModify(ctx *gin.Context) {
	var accountjson models.AccountModel
	err := ctx.ShouldBindJSON(&accountjson)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}
	var selects []interface{}
	if accountjson.Password != "" {
		accountjson.Password = fmt.Sprintf("%x", md5.Sum([]byte(accountjson.Password)))
		selects = append(selects, "password")
	}
	if accountjson.Name != "" {
		selects = append(selects, "name")
	}

	if accountjson.Role != 0 {
		selects = append(selects, "role")
	}

	if accountjson.Description != "" {
		selects = append(selects, "description")
	}

	err = models.DB.Model(&accountjson).Select(selects[0], selects[1:]...).Updates(&accountjson).Error
	if err != nil {
		this.AbsAnswer.FailString(ctx, "修改失败："+err.Error())
	} else {
		this.AbsAnswer.Success(ctx, nil)
		AddLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_MODIFY, "")
	}
}

func (this AccountInfo) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	var columns string
	var qVaues []interface{}

	columns = " enable = ? "
	qVaues = append(qVaues, true)

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "account like ? or name like ? or description like ? "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword)
	}

	var accountList []models.AccountModelApi
	models.DB.Model(&models.AccountModel{}).Where(columns, qVaues...).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&accountList)
	var count int64
	models.DB.Where("enable = true").Table("account").Count(&count)
	this.AbsAnswer.Success(ctx, map[string]interface{}{"list": accountList, "total": count, "page": this.Page, "pageSize": this.PageSize})
}

func (this AccountInfo) HandTokenModify(ctx *gin.Context) {
	token := ctx.Request.Header.Get("token")
	c, _ := tools.ParseToken(token)

	var count int64
	models.DB.Where("account=? and password=? and enable = true", c.UserName, fmt.Sprintf("%x", md5.Sum([]byte(c.Passwd)))).Count(&count)

	if count <= 0 {
		this.AbsAnswer.FailString(ctx, "账户或者用户名错误！")
		return
	}

	token, expireTimestamp, err := tools.MakeToen(c.Id, c.UserName, c.Passwd, c.Role, c.ClientType)
	fmt.Println(token)
	if err != nil {
		this.AbsAnswer.FailError(ctx, err)
		return
	}
	ctx.Header("token", token)
	this.Success(ctx, map[string]interface{}{"token": token, "expireTime": expireTimestamp})
	AddLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_MODIFY, "")
}

func (this AccountInfo) HandModifypassword(ctx *gin.Context) {
	var accountjson AccountModifyPasswd
	err := ctx.ShouldBindJSON(&accountjson)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var info models.AccountModel
	err = models.DB.Model(&models.AccountModel{}).Where("id = ?", accountjson.Id).First(&info).Error
	if err != nil {
		this.FailString(ctx, "修改失败："+err.Error())
	}

	if fmt.Sprintf("%x", md5.Sum([]byte(accountjson.OldPassword))) != info.Password {
		this.FailString(ctx, "旧密码填写错误！")
		return
	}
	info.Password = fmt.Sprintf("%x", md5.Sum([]byte(accountjson.NewPassword)))
	err = models.DB.Model(&info).Select("password").Updates(&info).Error

	if err != nil {
		this.AbsAnswer.FailString(ctx, "修改失败："+err.Error())
	} else {
		this.AbsAnswer.Success(ctx, nil)
		AddLog(ctx, models.TABLE_TYPE_ACCOUNT, models.OPT_TYPE_MODIFY, "")
	}
}
