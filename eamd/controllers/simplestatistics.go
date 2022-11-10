package controllers

import (
	"eamd/models"
	"eamd/tools"
	"fmt"
	"github.com/gin-gonic/gin"
	"time"
)

type SimpeSatatistics struct {
	AbsAnswer
}

func (this SimpeSatatistics) Query(ctx *gin.Context) {

	var use, count, free, scrapLost int
	var prices float64
	waitChan := make(chan int, 5)
	var monthTotal []interface{}
	var baseOrg []interface{}
	var deptOrg []interface{}
	var deptRepair []interface{}
	go func() {
		var bOrg []models.OrganizationModel
		err := models.DB.Model(&models.OrganizationModel{}).Where("parent in (select id from organization where parent is NULL)").Find(&bOrg).Error
		if err != nil {
			waitChan <- 1
			return
		}

		for _, org := range bOrg {
			ids := tools.GetChildOrg(int(org.Id))
			ids = append(ids, int(org.Id))
			var total float64
			err = models.DB.Model(&models.GoodsModel{}).Select("IFNULL(sum(price), 0)").Where(" organizationid in ?", ids).Scan(&total).Error
			if err != nil {
				waitChan <- 1
				return
			}
			baseOrg = append(baseOrg, map[string]interface{}{"title": org.Name, "total": total})
		}
		waitChan <- 1
	}()

	go func() {
		rows, err := models.DB.Raw("select state, count(*) from goods  group by state").Rows()
		if err != nil {
			waitChan <- 1
			return
		}
		defer rows.Close()
		for rows.Next() {
			var state, c int
			rows.Scan(&state, &c)
			count += c
			if state == models.GOODS_STATE_FREE {
				free += c
			} else if state == models.GOODS_STATE_LOSS || state == models.GOODS_STATE_LOSS {
				scrapLost += c
			} else {
				use += c
			}
		}
		waitChan <- 1
	}()

	go func() {
		err := models.DB.Raw("select sum(price) from goods").Scan(&prices)
		if err != nil {
			waitChan <- 1
			return
		}
		waitChan <- 1
	}()

	go func() {
		var bOrg2 []models.OrganizationModel
		err := models.DB.Model(&models.OrganizationModel{}).Select("name", "code").Where("isdept =true").Group("code").Find(&bOrg2).Error
		if err != nil {
			waitChan <- 1
			return
		}

		for _, org := range bOrg2 {
			ids := tools.GetChildOrg(int(org.Id))
			ids = append(ids, int(org.Id))
			var total float64
			err = models.DB.Model(&models.GoodsModel{}).Select("IFNULL(sum(price), 0)").Where(" organizationid in (select id from organization where  code = ?) ", org.Code).Scan(&total).Error
			if err != nil {
				waitChan <- 1
				return
			}
			var total2 float64
			err = models.DB.Model(&models.RepairModel{}).Select("IFNULL(sum(price), 0)").Where(" organizationid in (select id from organization where  code = ? ) ", org.Code).Scan(&total2).Error
			if err != nil {
				waitChan <- 1
				return
			}

			deptRepair = append(deptRepair, map[string]interface{}{"title": org.Name, "total": total2})
			deptOrg = append(deptOrg, map[string]interface{}{"title": org.Name, "total": total})
		}
		waitChan <- 1
	}()

	go func() {
		rows, err := models.DB.Raw("select substr(buytime,1,7),  sum(price) from goods where id<>0  and buytime is not null  group by  substr(buytime,1,7)  order by  substr(buytime,1,7) desc limit 0, 12").Rows()
		if err != nil {
			waitChan <- 1
			return
		}
		defer rows.Close()
		temp := make(map[string]interface{})
		for rows.Next() {
			var btime string
			var sum float64
			err = rows.Scan(&btime, &sum)
			if err != nil {
				fmt.Println("%v", err.Error())
				waitChan <- 1
				return
			}
			temp[btime] = sum
		}
		loc, _ := time.LoadLocation("Local") //获取时区
		endTime, _ := time.ParseInLocation("2006-01", time.Now().Format("2006-01"), loc)
		for i := 12; i >= 1; i-- {
			p, _ := temp[endTime.Format("2006-01")]
			if p == nil {
				p = 0
			}
			monthTotal = append(monthTotal, map[string]interface{}{"title": endTime.Format("2006-01"), "total": p})
			endTime = endTime.AddDate(0, -1, 0)
		}
		waitChan <- 1
	}()

	for i := 0; i < 5; i++ {
		<-waitChan
	}

	this.Success(ctx, map[string]interface{}{
		"use":             use,
		"count":           count,
		"free":            free,
		"scrapLost":       scrapLost,
		"priceToal":       prices,
		"monthTotal":      monthTotal,
		"baseOrg":         baseOrg,
		"deptTotal":       deptOrg,
		"deptRepairTotal": deptRepair,
	})
}
