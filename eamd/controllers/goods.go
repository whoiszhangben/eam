package controllers

import (
	"eamd/log"
	"eamd/models"
	"eamd/tools"
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"
	"gorm.io/gorm"
	"net/http"
	"os"
	"strconv"
	"time"
)

type Goods struct {
	AbsAnswer
	AbsPagination  `json:"pagination"`
	OrganizationId []int    `json:"organizationId"`
	Keyword        string   `json:"keyword"`
	State          []int    `json:"state"`
	DeptCode       []string `json:"deptCode"`
	Id             []int64  `json:"id"`
	GSortId        []int64  `json:"gSortId"`
	ChildGsortid   []int64  `json:"childGsortid"`
}

type GoodsAdd struct {
	Goods []models.GoodsModel `json:"goods"`
}

func (this Goods) HandAdd(ctx *gin.Context) {
	var info GoodsAdd
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误"+err.Error())
		return
	}

	err = models.DB.Transaction(func(tx *gorm.DB) error {
		var err error
		for i := 0; i < len(info.Goods); i++ {
			var gsortid int
			err = models.DB.Model(&models.ChildGsortModel{}).Select("gsortid").Where("id = ?", info.Goods[i].ChildGsortid).Scan(&gsortid).Error
			if err != nil {
				return err
			}
			info.Goods[i].State = models.GOODS_STATE_FREE

			var amount int
			amount = int(*info.Goods[i].Amount)
			if amount <= 0 {
				amount = 1
			}
			info.Goods[i].Ctime = time.Now()
			*info.Goods[i].Amount = 1
			var infos []models.GoodsModel

			for i2 := 0; i2 < amount; i2++ {
				infos = append(infos, info.Goods[i])
			}
			err = tx.Model(&models.GoodsModel{}).Omit("pcount", "vendor", "organizationName", "fdescription").Create(&infos).Error

			if err == nil {
				var fInfos []models.GoodsFlowingModel
				for _, v := range infos {
					var fInfo models.GoodsFlowingModel
					fInfo.AcountId = tools.GetUserId(ctx)
					fInfo.State = v.State
					fInfo.CreateTime = time.Now()
					fInfo.GoodsId = v.Id
					fInfo.OrganizationId = v.Orgid
					fInfo.Description = "新增"
					fInfos = append(fInfos, fInfo)
				}
				err = tx.Model(&models.GoodsFlowingModel{}).Create(&fInfos).Error
			}
		}
		return err
	})
	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_ADD, "")
	}
	return
}

func (this Goods) HandRemove(ctx *gin.Context) {
	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Transaction(func(tx *gorm.DB) error {
		var err error
		err = tx.Where("goodsid in ?", ids["id"]).Delete(&models.RepairModel{}).Error
		if err != nil {
			return err
		}

		err = tx.Where("goodsid in ?", ids["id"]).Delete(&models.GoodsFlowingModel{}).Error
		if err != nil {
			return err
		}

		err = tx.Delete(&models.GoodsModel{}, ids["id"]).Error
		if err != nil {
			return err
		}
		return err
	})
	if err != nil {
		this.FailString(ctx, "该资源正在使用，无法删除")
		return
	}
	this.Success(ctx, nil)
	AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_DELETE, "")
}

func (this Goods) HandModify(ctx *gin.Context) {

	var infos map[string][]map[string]interface{}
	err := ctx.ShouldBindJSON(&infos)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	err = models.DB.Transaction(func(tx *gorm.DB) error {
		var err error
		for _, v := range infos["goods"] {
			if _, ok := v["gSortId"]; ok {
				v["gsortid"] = v["gSortId"]
				delete(v, "gSortId")
			}

			if _, ok := v["buyTime"]; ok {
				v["buytime"] = v["buyTime"]
				delete(v, "buyTime")
			}
			if _, ok := v["orgId"]; ok {
				v["organizationid"] = v["orgId"]
				delete(v, "orgId")
			}

			vTemp := make(map[string]interface{})
			for k, kv := range v {
				vTemp[k] = kv
			}
			if state, ok := vTemp["state"]; ok {
				if int(state.(float64)) == models.GOODS_STATE_RETURN {
					vTemp["state"] = models.GOODS_STATE_FREE
					vTemp["custodian"] = ""
					vTemp["savelocation"] = ""
				} else if int(state.(float64)) == models.GOODS_STATE_TRANSFER {
					vTemp["state"] = models.GOODS_STATE_USE
				}
			}

			var old models.GoodsModel
			err = tx.Model(&models.GoodsModel{}).Omit("organizationName", "fdescription").Where("id=?", v["id"]).First(&old).Error
			err = tx.Model(&models.GoodsModel{}).Omit("id", "ctime", "fdescription").Where("id=?", v["id"]).Updates(&vTemp).Error
			if err != nil {
				return err
			}
			if state, ok := v["state"]; ok {

				if old.State == models.GOODS_STATE_LOSS || old.State == models.GOODS_STATE_SCRAP {
					fmt.Println(old.State)
					if int(state.(float64)) == models.GOODS_STATE_USE || int(state.(float64)) == models.GOODS_STATE_TRANSFER {
						return errors.New("该物品不支持该操作！")
					}
				}
				if old.State == models.GOODS_STATE_FREE && (int(state.(float64)) == models.GOODS_STATE_RETURN || int(state.(float64)) == models.GOODS_STATE_TRANSFER) {
					return errors.New("该物品不支持该操作！")
				}

				if old.State == models.GOODS_STATE_USE && int(state.(float64)) == models.GOODS_STATE_USE {
					return errors.New("该物品不支持该操作！")
				}

				if int(state.(float64)) != old.State {
					var fInfo models.GoodsFlowingModel
					fInfo.AcountId = tools.GetUserId(ctx)
					fInfo.State = int(state.(float64))
					if savelocation, ok := v["savelocation"]; ok {
						fInfo.Savelocation = savelocation.(string)
					} else {
						fInfo.Savelocation = old.Savelocation
					}

					if organization, ok := v["organization"]; ok {
						fInfo.OrganizationId = int64(organization.(float64))
					} else {
						fInfo.OrganizationId = old.Orgid
					}
					if fdescription, ok := v["fdescription"]; ok {
						fInfo.Description = fdescription.(string)
					}

					fInfo.CreateTime = time.Now()
					if cTime, ok := v["ctime"]; ok {
						if cTime != "" {
							loc, _ := time.LoadLocation("Local") //获取时区
							startTime, err := time.ParseInLocation("2006-01-02 15:04:05", cTime.(string), loc)
							if err == nil {
								fInfo.CreateTime = startTime
							}
						}
					}
					fInfo.GoodsId = int64(v["id"].(float64))
					if custodian, ok := v["custodian"]; ok {
						fInfo.User = custodian.(string)
					}
					err = tx.Create(&fInfo).Error
					if err != nil {
						return err
					}
				}
			}
		}
		return err
	})

	this.Ans(ctx, err)
	if err != nil {
		AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_MODIFY, "")
	}
}

func (this Goods) HandMobileQuery(ctx *gin.Context) {

	var info map[string]interface{}
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var currentGoods []models.GoodsModel
	err = models.DB.Model(&models.GoodsModel{}).Preload("GSortModel").Preload("ChildGsort").Preload("Repair").Preload("Organization").Preload("Vendor").Omit("organizationName", "fdescription").Where("id = ?", info["id"]).Find(&currentGoods).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	if len(currentGoods) == 0 {
		this.Success(ctx, nil)
		return
	}
	if currentGoods[0].State == models.GOODS_STATE_USE {
		var goodsInfos []models.GoodsModel
		err = models.DB.Model(&models.GoodsModel{}).Preload("GSortModel").Preload("ChildGsort").Preload("Repair").Preload("Organization").Preload("Vendor").Omit("ctime", "organizationName", "fdescription").Where(" custodian  = (select  custodian from goods where id =? ) ", info["id"]).Find(&goodsInfos).Error
		if err != nil {
			this.AbsAnswer.Ans(ctx, err)
			return
		}

		for i := 0; i < len(goodsInfos); i++ {
			models.DB.Model(&models.OrganizationModel{}).Select("name").Where("id = (select parent from organization where id = ? ) ", goodsInfos[i].Orgid).Scan(&goodsInfos[i].BaseOrgName)
		}

		this.Success(ctx, goodsInfos)
	} else {
		for i := 0; i < len(currentGoods); i++ {
			models.DB.Model(&models.OrganizationModel{}).Select("name").Where("id = (select parent from organization where id = ? ) ", currentGoods[i].Orgid).Scan(&currentGoods[i].BaseOrgName)
		}
		this.Success(ctx, currentGoods)
	}
}

func (this Goods) HandQuery(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var columns string
	var qVaues []interface{}
	oids := make([]int, 0)
	if len(this.OrganizationId) > 0 {
		for _, oid := range this.OrganizationId {
			oids = append(oids, tools.GetChildOrg(oid)...)
			oids = append(oids, oid)
		}

		columns = "organizationid in ? "
		qVaues = append(qVaues, oids)
	}

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "(name like ? or custodian like ? or model like ? or savelocation like ? or description like ? ) "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword, this.Keyword, this.Keyword)
	}

	if len(this.DeptCode) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " organizationid  in  (select id  from organization where code in ?  ) "
		qVaues = append(qVaues, this.DeptCode)
	}

	if len(this.State) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " state  in  ? "
		qVaues = append(qVaues, this.State)
	}

	if len(this.GSortId) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " gsortid  in  ?  "
		qVaues = append(qVaues, this.GSortId)
	}

	if len(this.ChildGsortid) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " childgsortid  in  ? "
		qVaues = append(qVaues, this.ChildGsortid)
	}

	var sortBy string
	var order string
	if this.Order == 1 {
		order = "asc"
	} else {
		order = "desc"
	}
	if this.SortBy == "custodian" {
		sortBy = " convert(custodian using gbk)  " + order
	} else {
		if this.SortBy == "" {
			sortBy = "id " + order
		} else {
			sortBy = this.SortBy + " " + order
		}
	}

	var orgInfo []models.GoodsModel
	err = models.DB.Model(&models.GoodsModel{}).Omit("vendor", "organizationName", "fdescription").Preload("Vendor").Preload("Organization").Preload("GSortModel").Where(columns, qVaues...).Order(sortBy).Offset((this.Page - 1) * this.PageSize).Limit(this.PageSize).Find(&orgInfo).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	var count int64
	models.DB.Model(&models.GoodsModel{}).Where(columns, qVaues...).Count(&count)
	this.Success(ctx, map[string]interface{}{"list": orgInfo, "total": count, "page": this.Page, "pageSize": this.PageSize})
}

func (this Goods) Import(ctx *gin.Context) {

	form, _ := ctx.MultipartForm()
	files := form.File["fcontent"]
	var file_path string
	for _, file := range files { // 循环
		unix_int := time.Now().Unix()                    // 时间戳，int类型
		time_unix_str := strconv.FormatInt(unix_int, 10) // 讲int类型转为string类型，方便拼接，使用sprinf也可以
		file_path = "./" + time_unix_str + file.Filename // 设置保存文件的路径，不要忘了后面的文件名
		ctx.SaveUploadedFile(file, file_path)            // 保存文件
	}

	ftemp, err := os.Open(file_path)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"error":  "上传失败！" + err.Error(),
			"result": false,
		})
		return
	}
	ftemp.Close()
	defer os.Remove(file_path)

	f, err := excelize.OpenFile(file_path)
	if err != nil {
		log.Log.Error("open xlsx file falil, %v", err.Error())
		return
	}

	codeId := make(map[string]int64)

	childValue, _ := f.GetCellValue("sheet1", "P3")
	if childValue != "" {
		var nameIdTemp []models.ChildGsortCodeId
		models.DB.Model(&models.ChildGsortModel{}).Select("code", "id").Find(&nameIdTemp)

		for _, v := range nameIdTemp {
			codeId[v.Code] = v.Id
		}
	}

	rows, err := f.GetRows("sheet1")
	var goods []models.GoodsModel
	for cIndex := 4; cIndex <= len(rows); cIndex++ {
		item := models.GoodsModel{}
		gSort, _ := f.GetCellValue("sheet1", "C"+fmt.Sprintf("%v", cIndex))
		strNo, _ := f.GetCellValue("sheet1", "B"+fmt.Sprintf("%v", cIndex))
		base, _ := f.GetCellValue("sheet1", "L"+fmt.Sprintf("%v", cIndex))
		dept, _ := f.GetCellValue("sheet1", "M"+fmt.Sprintf("%v", cIndex))
		item.GSortId, item.Orgid, err = this.GetParam(strNo, gSort, base, dept)
		if err != nil {
			this.AbsAnswer.FailError(ctx, err)
			return
		}

		state, _ := f.GetCellValue("sheet1", "O"+fmt.Sprintf("%v", cIndex))
		if state != "" {
			nState, _ := strconv.Atoi(state)
			if nState < models.GOODS_STATE_FREE && nState > models.GOODS_STATE_SCRAP {
				item.State = 1
			}
			item.State = nState
		}

		item.Custodian, _ = f.GetCellValue("sheet1", "O"+fmt.Sprintf("%v", cIndex))
		if item.Custodian != "" && item.State != models.GOODS_STATE_LOSS && item.State != models.GOODS_STATE_SCRAP {
			item.State = models.GOODS_STATE_USE
		}

		item.Name, _ = f.GetCellValue("sheet1", "D"+fmt.Sprintf("%v", cIndex))
		item.Model, _ = f.GetCellValue("sheet1", "E"+fmt.Sprintf("%v", cIndex))
		item.Unit, _ = f.GetCellValue("sheet1", "I"+fmt.Sprintf("%v", cIndex))
		item.Savelocation, _ = f.GetCellValue("sheet1", "N"+fmt.Sprintf("%v", cIndex))

		childCode, _ := f.GetCellValue("sheet1", "Q"+fmt.Sprintf("%v", cIndex))
		if childValue != "" {
			if id, ok := codeId[childCode]; ok {
				item.ChildGsortid = id
			}
		}

		amount, _ := f.GetCellValue("sheet1", "H"+fmt.Sprintf("%v", cIndex))
		if amount != "" {
			namount, _ := strconv.Atoi(amount)
			if namount <= 0 {
				namount = 1
			}
			item.Amount = new(int64)
			*item.Amount = 1

			for i := 0; i < namount; i++ {
				goods = append(goods, item)
			}
		}
	}

	var omit []string
	omit = append(omit, "vendor", "RepairModel", "organizationName", "pcount", "fdescription")
	if childValue == "" {
		omit = append(omit, "childgsortid")
	}

	err = models.DB.Model(&models.GoodsModel{}).Omit(omit...).Create(&goods).Error

	if err == nil {
		go func() {
			var fInfos []models.GoodsFlowingModel
			for _, v := range goods {
				var fInfo models.GoodsFlowingModel
				fInfo.AcountId = tools.GetUserId(ctx)
				fInfo.State = v.State
				fInfo.CreateTime = time.Now()
				fInfo.GoodsId = v.Id
				fInfo.Description = "导入数据"
				fInfo.User = v.Custodian
				fInfo.Savelocation = v.Savelocation
				if v.Orgid <= 0 {
					continue
				} else {
					fInfo.OrganizationId = v.Orgid
				}
				fInfos = append(fInfos, fInfo)
			}
			models.DB.Create(&fInfos)
		}()
	}

	this.Ans(ctx, err)
	if err == nil {
		AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_IMPORT, "")
	}
}

func (this Goods) Export(ctx *gin.Context) {
	err := ctx.ShouldBindJSON(&this)
	if err != nil {
		this.FailString(ctx, "json格式错误！")
		return
	}

	var columns string
	var qVaues []interface{}
	if len(this.OrganizationId) > 0 {
		columns = "organizationid in ? "
		qVaues = append(qVaues, this.OrganizationId)
	}

	if this.Keyword != "" {
		if columns != "" {
			columns += " and "
		}
		this.Keyword = "%" + this.Keyword + "%"
		columns += "(name like ? or custodian like ? or model like ? or savelocation like ? or description like ? ) "
		qVaues = append(qVaues, this.Keyword, this.Keyword, this.Keyword, this.Keyword, this.Keyword)
	}

	if len(this.DeptCode) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " organizationid  in  (select id  from organization where code in ?  ) "
		qVaues = append(qVaues, this.DeptCode)
	}
	if len(this.Id) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " id  in  ? "
		qVaues = append(qVaues, this.Id)
	}

	if len(this.State) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " state  in  ? "
		qVaues = append(qVaues, this.State)
	}

	if len(this.GSortId) > 0 {
		if columns != "" {
			columns += " and "
		}
		columns += " gsortid  in  ? "
		qVaues = append(qVaues, this.GSortId)
	}

	var sortBy string
	if this.SortBy == "custodian" {
		sortBy = " convert(custodian using gbk)  asc "
	} else {
		if this.SortBy == "" {
			sortBy = "id desc "
		} else {
			sortBy = this.SortBy + " asc "
		}
	}
	var goods []models.GoodsModel
	err = models.DB.Omit("vendor", "organizationName", "fdescription").Preload("GSortModel").Preload("Organization").Preload("ChildGsort").Where(columns, qVaues...).Order(sortBy).Find(&goods).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	filePath, err := SaveMsg(goods)
	if err != nil {
		this.FailString(ctx, "导出数据失败！")
		return
	}

	ctx.File(filePath)
	os.Remove(filePath)
	AddLog(ctx, models.TABLE_TYPE_GOODS, models.OPT_TYPE_EXPORT, "")
}

func SaveMsg(goods []models.GoodsModel) (string, error) {
	f := excelize.NewFile()
	title := "固定资产管理盘点清单"
	sheet := "Sheet1"
	err := f.MergeCell(sheet, "A1", "O1")
	f.SetSheetRow(sheet, "A1", &[]interface{}{title}) //设置工作表的名称
	if err != nil {
		return "", err
	}
	Al_style, err := f.NewStyle(`{"alignment":{
    "horizontal":"center",
    "vertical":"center"
}}`)

	f.MergeCell(sheet, "A2", "A3")
	f.SetSheetRow(sheet, "A2", &[]interface{}{"序号"})

	f.MergeCell(sheet, "B2", "B3")
	f.SetSheetRow(sheet, "B2", &[]interface{}{"固定资产编号"})

	f.MergeCell(sheet, "C2", "D2")
	f.SetSheetRow(sheet, "C2", &[]interface{}{"类别"})

	f.MergeCell(sheet, "E2", "G2")
	f.SetSheetRow(sheet, "E2", &[]interface{}{"固定资产信息"})

	f.MergeCell(sheet, "H2", "L2")
	f.SetSheetRow(sheet, "H2", &[]interface{}{"固定资产经济信息"})

	f.MergeCell(sheet, "M2", "P2")
	f.SetSheetRow(sheet, "M2", &[]interface{}{"使用/管理者信息"})

	f.SetSheetRow(sheet, "C3", &[]interface{}{"大类", "子类", "名称", "规格/型号", "购买时间", "票单", "数量", "单位", "单价", "单位原值", "部门", "储存位置", "保管人", "设备状态"})

	index := 1
	for _, item := range goods {
		code, _ := tools.Redisdb.HGet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", item.Orgid)).Result()
		code += fmt.Sprintf("%05v", item.Id)

		if item.BuyTime != nil && *item.BuyTime != "" {
			str := *item.BuyTime
			*item.BuyTime = str[0:10]
		}

		var strBuyTime string
		if item.BuyTime != nil {
			strBuyTime = *item.BuyTime
		}

		f.SetSheetRow(sheet, fmt.Sprintf("A%v", index+3), &[]interface{}{index, code, item.GSortModel.Name, item.ChildGsort.Name, item.Name, item.Model,
			strBuyTime, "", 1, item.Unit, item.Price, nil, item.Organization.Name, item.Savelocation, item.Custodian, tools.GetStateString(item.State)})
		index++
	}

	if err := f.SetCellStyle(sheet, "A1", fmt.Sprintf("P%v", index+3), Al_style); err != nil {
		return "", err
	}

	timeStyle, err := f.NewStyle("2001年3月7日")
	if err := f.SetCellStyle(sheet, "F4", fmt.Sprintf("F%v", index+3), timeStyle); err != nil {
		return "", err
	}

	filename := time.Now().Format("20060102150405") + ".xlsx"
	err = f.SaveAs(filename)
	if err != nil {
		fmt.Println(fmt.Sprintf("保存文件失败,错误:%s", err))
		return "", err
	}
	f.Close()

	return filename, nil
}

func (this Goods) GetParam(strParm string, gSort, base, dept string) (gSortId int64, orgId int64, err error) {
	var strOrg string
	if len(base+dept) < 3 {
		if len(strParm) < 5 {
			err = errors.New("固定资产编号，无法解析！")
			return
		}
		strOrg = strParm[2:5]
	} else {
		strOrg = base + dept
	}

	gSort = ""
	if len(gSort) < 2 {
		gSort = "0" + gSort
	}
	gId, err := tools.Redisdb.HGet(tools.REDIS_H_GSORT_CODE_ID, gSort).Result()
	if err != nil {
		if gId == "" {
			gId, err = tools.Redisdb.HGet(tools.REDIS_H_GSORT_CODE_ID, strParm[0:2]).Result()
			if err != nil {
				err = errors.New("未知的类别！")
				return
			}
		}
	}

	id, err := strconv.Atoi(gId)
	if err != nil {
		log.Log.Error("%v", err.Error())
		return
	}
	gSortId = int64(id)

	strOrg, err = tools.Redisdb.HGet(tools.REDIS_H_ORG_CODE_ID, strOrg).Result()
	if err != nil {
		err = errors.New("该设备机构错误， 请核实")
		return
	}

	oid, err := strconv.Atoi(strOrg)
	if err != nil {
		log.Log.Error("%v", err.Error())
		return
	}
	orgId = int64(oid)
	return
}

func (this Goods) HandTemplate(ctx *gin.Context) {
	f := excelize.NewFile()
	title := "深圳基地固定资产管理盘点清单（机密：Y）"
	sheet := "Sheet1"
	err := f.MergeCell(sheet, "A1", "O1")
	f.SetSheetRow(sheet, "A1", &[]interface{}{title}) //设置工作表的名称
	if err != nil {
		this.FailError(ctx, err)
		return
	}
	Al_style, err := f.NewStyle(`{"alignment":{
    "horizontal":"center",
    "vertical":"center"
}}`)

	f.MergeCell(sheet, "A2", "A3")
	f.SetSheetRow(sheet, "A2", &[]interface{}{"序号"})

	f.MergeCell(sheet, "B2", "B3")
	f.SetSheetRow(sheet, "B2", &[]interface{}{"固定资产编号"})

	f.MergeCell(sheet, "C2", "C3")
	f.SetSheetRow(sheet, "C2", &[]interface{}{"类别"})

	f.MergeCell(sheet, "D2", "F2")
	f.SetSheetRow(sheet, "D2", &[]interface{}{"固定资产信息"})

	f.MergeCell(sheet, "G2", "K2")
	f.SetSheetRow(sheet, "G2", &[]interface{}{"固定资产经济信息"})

	f.MergeCell(sheet, "L2", "Q2")
	f.SetSheetRow(sheet, "L2", &[]interface{}{"使用/管理者信息"})
	f.SetSheetRow(sheet, "D3", &[]interface{}{"名称", "规格/型号", "购买时间", "票单", "数量", "单位", "单价", "单位原值", "基地编码", "部门编号", "储存位置", "保管人", "设备状态", "子类别编码"})

	f.SetSheetRow(sheet, "A4", &[]interface{}{"1", "04SZF001", 4, "电脑", "CPU:I3-4160 内存：4G 硬盘：机械500G 显示器:HOESD", "2022-10-01", "", 1, "台", 2999, "", "", "SZ", "F", "财务部", "刘晓梅", "DN"})
	f.SetSheetRow(sheet, "A5", &[]interface{}{"2", "05SZF001", 5, "椅子", "滑轮椅子", "2022-10-01", "", 1, "把", 88, "", "", "SZ", "F", "财务部", "刘晓梅", "YZ"})

	f.SetCellStyle(sheet, "A1", "Q5", Al_style)

	fName := "导入模板.xlsx"
	err = f.SaveAs(fName)
	if err != nil {
		this.FailError(ctx, err)
		return
	}
	f.Close()
	ctx.File(fName)
	os.Remove(fName)
}
