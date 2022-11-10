package controllers

import (
	"eamd/models"
	"eamd/tools"
	"github.com/gin-gonic/gin"
	"sort"
)

type ChildGsort struct {
	AbsAnswer
	AbsPagination `json:"pagination"`
	Id            []int  `json:"id"`
	GsortId       []int  `json:"gsortId"`
	Keyword       string `json:"keyword"`
	Statistics    bool   `json:"statistics"`
}

type ChildGsortStatistics struct {
	AbsAnswer
	ChildGsortId []int `json:"childGsortId"`
}

func (this ChildGsort) HandAdd(ctx *gin.Context) {
	var info models.ChildGsortModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误")
		return
	}

	var count int64
	err = models.DB.Model(&models.ChildGsortModel{}).Where("gsortid=? and code = ?", info.Gsortid, info.Code).Count(&count).Error
	if err != nil {
		this.FailString(ctx, err.Error())
		return
	}
	if count > 0 {
		this.FailString(ctx, "该子分类已经存在，不能重复增加")
		return
	}

	err = models.DB.Model(&models.ChildGsortModel{}).Create(&info).Error
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_CHILD_GSORT, models.OPT_TYPE_ADD, "")
	}
}

func (this ChildGsort) HandRemove(ctx *gin.Context) {
	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Delete(&models.ChildGsortModel{}, ids["id"]).Error
	if err != nil {
		this.FailString(ctx, "该资源正在使用，无法删除")
		return
	}
	this.Success(ctx, nil)
	AddLog(ctx, models.TABLE_TYPE_CHILD_GSORT, models.OPT_TYPE_DELETE, "")
}

func (this ChildGsort) HandModify(ctx *gin.Context) {
	var info models.ChildGsortModel

	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var count int64
	err = models.DB.Model(&models.ChildGsortModel{}).Where("id<>? and code = ?", info.Id, info.Code).Count(&count).Error
	if err != nil {
		this.FailError(ctx, err)
		return
	}
	if count > 0 {
		this.FailString(ctx, "该分类编号已经存在！")
		return
	}

	err = models.DB.Model(&models.ChildGsortModel{}).Where("id = ?", info.Id).Updates(info).Error
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_CHILD_GSORT, models.OPT_TYPE_MODIFY, "")
	}
}

func (this ChildGsort) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var columns string
	var qVaues []interface{}

	if len(this.Id) > 0 {
		columns = "id in ? "
		qVaues = append(qVaues, this.Id)
	}

	if len(this.GsortId) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns = "gsortid in ? "
		qVaues = append(qVaues, this.GsortId)
	}
	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "name like ? or code like ? or description like ? "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword)
	}

	var childGsort []models.ChildGsortModel
	err = models.DB.Model(&models.ChildGsortModel{}).Preload("GSort").Where(columns, qVaues...).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&childGsort).Error
	if err != nil {
		this.Ans(ctx, err)
		return
	}
	var count int64
	models.DB.Model(&models.ChildGsortModel{}).Where(columns, qVaues...).Count(&count)

	if this.Statistics {
		for i := 0; i < len(childGsort); i++ {
			var counts []models.ChildGoodsCount
			err = models.DB.Model(&models.GoodsModel{}).Select("state", "count(*) count").Where("childgsortid = ?", childGsort[i].Id).Group("state").Find(&counts).Error
			if err != nil {
				this.Ans(ctx, err)
				return
			}

			for _, item := range counts {
				switch item.State {
				case models.GOODS_STATE_USE:
					childGsort[i].UseCount = item.Count
					childGsort[i].Total += item.Count
					break
				case models.GOODS_STATE_LOSS:
					childGsort[i].LossCount = item.Count
					childGsort[i].Total += item.Count
					break
				case models.GOODS_STATE_SCRAP:
					childGsort[i].ScrapCount = item.Count
					childGsort[i].Total += item.Count
					break
				default:
					childGsort[i].Total += item.Count
				}
			}
		}
	}

	this.Success(ctx, map[string]interface{}{"list": childGsort, "total": count, "page": this.Page, "pageSize": this.PageSize})
}

func (this ChildGsort) HandDistributeQuery(ctx *gin.Context) {
	var queryInfo ChildGsortStatistics
	err := ctx.ShouldBindJSON(&queryInfo)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var bOrg []models.OrganizationModel
	err = models.DB.Model(&models.OrganizationModel{}).Select("name", "code").Where("isdept =true").Group("code").Find(&bOrg).Error
	if err != nil {
		this.Ans(ctx, err)
		return
	}

	var totalSort []int
	deptTotal := make(map[int][]interface{})
	var deptOrg []interface{}
	for _, org := range bOrg {
		ids := tools.GetChildOrg(int(org.Id))
		ids = append(ids, int(org.Id))

		var counts []models.ChildGoodsCount
		err = models.DB.Model(&models.GoodsModel{}).Select("state", "count(*) count").Where(" organizationid in (select id from organization where  code = ?)  and childgsortid in ?", org.Code, queryInfo.ChildGsortId).Group("state").Find(&counts).Error
		if err != nil {
			this.Ans(ctx, err)
			return
		}

		var count, useCount, lossCount, scrapCount int64
		for _, item := range counts {
			switch item.State {
			case models.GOODS_STATE_USE:
				useCount = item.Count
				count += item.Count
				break
			case models.GOODS_STATE_LOSS:
				lossCount = item.Count
				count += item.Count
				break
			case models.GOODS_STATE_SCRAP:
				scrapCount = item.Count
				count += item.Count
				break
			default:
				count += item.Count
			}
		}
		if tools.Findint64(totalSort, int(count)) == false {
			totalSort = append(totalSort, int(count))
		}

		deptTotal[int(count)] = append(deptTotal[int(count)], map[string]interface{}{"title": org.Name, "total": count, "useCount": useCount, "lossCount": lossCount, "scrapCount": scrapCount})
	}

	sort.Ints(totalSort)
	for i := len(totalSort) - 1; i >= 0; i-- {
		for _, v := range deptTotal[totalSort[i]] {
			deptOrg = append(deptOrg, v)
		}
	}

	this.Success(ctx, deptOrg)
}
