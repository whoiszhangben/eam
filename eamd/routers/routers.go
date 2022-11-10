package routers

import (
	"eamd/conf"
	"eamd/controllers"
	"eamd/tools"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

func RoutreInit() {
	r := gin.Default()

	//r.StaticFile("/", conf.HttpDirSetting.Httpdir+"/index.html")
	//r.StaticFile("/favicon.ico", conf.HttpDirSetting.Httpdir+"/favicon.ico")
	/*//r.StaticFile("/index.html", conf.HttpDirSetting.Httpdir+"/index.html")
	r.StaticFS("/css", http.Dir(conf.HttpDirSetting.Httpdir)+"/css")
	r.StaticFS("/fonts", http.Dir(conf.HttpDirSetting.Httpdir)+"/fonts")
	r.StaticFS("/js", http.Dir(conf.HttpDirSetting.Httpdir)+"/js")
	r.StaticFS("/res", http.Dir(conf.HttpDirSetting.Httpdir)+"/res")*/
	//r.StaticFS("/main", http.Dir(conf.HttpSetting.Httpdir))
	//r.StaticFS("/main", http.Dir("./web"))
	r.StaticFS("/main", http.Dir(conf.HttpSetting.Httpdir))

	r.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusMovedPermanently, "/main")
	})

	loginG := r.Group("/eam/account")
	{
		loginG.POST("login", controllers.AccountInfo{}.HandLogin)
		loginG.POST("add", tools.TokenAuth, controllers.AccountInfo{}.HandAdd)
		loginG.POST("modify", tools.TokenAuth, controllers.AccountInfo{}.HandModify)
		loginG.POST("remove", tools.TokenAuth, controllers.AccountInfo{}.HandRemove)
		loginG.POST("query", tools.TokenAuth, controllers.AccountInfo{}.HandQuery)
		loginG.POST("modifypassword", tools.TokenAuth, controllers.AccountInfo{}.HandModifypassword)
	}

	tokenG := r.Group("/eam/token")
	{
		tokenG.GET("modify", tools.TokenAuth, controllers.AccountInfo{}.HandTokenModify)
		tokenG.POST("modify", tools.TokenAuth, controllers.AccountInfo{}.HandTokenModify)
	}

	OrganizationG := r.Group("/eam/organization")
	{
		OrganizationG.Use(tools.TokenAuth)
		OrganizationG.POST("add", controllers.OrgInfo{}.HandAdd)
		OrganizationG.GET("query", controllers.OrgInfo{}.HandQuery)
		OrganizationG.POST("query", controllers.OrgInfo{}.HandQuery)
		OrganizationG.POST("remove", controllers.OrgInfo{}.HandRemove)
		OrganizationG.POST("modify", controllers.OrgInfo{}.HandModify)
	}

	Gsort := r.Group("/eam/gsort")
	{
		Gsort.Use(tools.TokenAuth)
		Gsort.POST("add", controllers.Gsort{}.HandAdd)
		Gsort.POST("query", controllers.Gsort{}.HandQuery)
		Gsort.POST("remove", controllers.Gsort{}.HandRemove)
		Gsort.POST("modify", controllers.Gsort{}.HandModify)
	}

	ChildGsort := r.Group("/eam/childgsort")
	{
		ChildGsort.Use(tools.TokenAuth)
		ChildGsort.POST("add", controllers.ChildGsort{}.HandAdd)
		ChildGsort.POST("query", controllers.ChildGsort{}.HandQuery)
		ChildGsort.POST("remove", controllers.ChildGsort{}.HandRemove)
		ChildGsort.POST("modify", controllers.ChildGsort{}.HandModify)
	}
	DistributeG := r.Group("/eam/distribute")
	{
		DistributeG.Use(tools.TokenAuth)
		DistributeG.POST("query", controllers.ChildGsort{}.HandDistributeQuery)
	}

	GoodsG := r.Group("/eam/goods")
	{
		GoodsG.Use(tools.TokenAuth)
		GoodsG.POST("add", controllers.Goods{}.HandAdd)
		GoodsG.POST("remove", controllers.Goods{}.HandRemove)
		GoodsG.POST("modify", controllers.Goods{}.HandModify)
		GoodsG.POST("import", controllers.Goods{}.Import)
		GoodsG.POST("export", controllers.Goods{}.Export)
		GoodsG.GET("query", controllers.Goods{}.HandQuery)
		GoodsG.POST("query", controllers.Goods{}.HandQuery)
		GoodsG.POST("scanquery", controllers.Goods{}.HandMobileQuery)
	}

	TemplateG := r.Group("/eam/template")
	{
		TemplateG.Use(tools.TokenAuth)
		TemplateG.GET("query", controllers.Goods{}.HandTemplate)
		TemplateG.POST("query", controllers.Goods{}.HandTemplate)
	}

	RepairG := r.Group("/eam/repair")
	{
		RepairG.Use(tools.TokenAuth)
		RepairG.POST("add", controllers.Repair{}.HandAdd)
		RepairG.POST("query", controllers.Repair{}.HandQuery)
		RepairG.POST("export", controllers.Repair{}.Export)
	}

	simpleStatiG := r.Group("/eam/simplestatistics")
	{
		simpleStatiG.Use(tools.TokenAuth)
		simpleStatiG.GET("query", controllers.SimpeSatatistics{}.Query)
		simpleStatiG.POST("query", controllers.SimpeSatatistics{}.Query)
	}

	printG := r.Group("/eam/print")
	{
		printG.Use(tools.TokenAuth)
		printG.POST("check", controllers.PrintLabel{}.HandCheck)
		printG.POST("all", controllers.PrintLabel{}.HandAll)
	}

	GoodsFlowingG := r.Group("/eam/goodsflowing")
	{
		GoodsFlowingG.Use(tools.TokenAuth)
		GoodsFlowingG.POST("query", controllers.GoodsFlowing{}.HandQuery)
	}

	PrintG := r.Group("/eam/print")
	{
		PrintG.Use(tools.TokenAuth)
		PrintG.GET("query", controllers.Printcontrollers{}.HandQuery)
		PrintG.POST("query", controllers.Printcontrollers{}.HandQuery)
	}

	VendorG := r.Group("/eam/vendor")
	{
		VendorG.Use(tools.TokenAuth)
		VendorG.POST("add", controllers.Vendor{}.HandAdd)
		VendorG.POST("query", controllers.Vendor{}.HandQuery)
		VendorG.POST("remove", controllers.Vendor{}.HandRemove)
		VendorG.POST("modify", controllers.Vendor{}.HandModify)
	}

	backupdbG := r.Group("/eam/config")
	{
		backupdbG.Use(tools.TokenAuth)
		backupdbG.GET("query", controllers.Config{}.HandQuery)
		backupdbG.POST("query", controllers.Config{}.HandQuery)
		backupdbG.POST("modify", controllers.Config{}.HandModify)

	}

	LogG := r.Group("/eam/log")
	{
		LogG.Use(tools.TokenAuth)
		LogG.POST("query", controllers.Log{}.HandQuery)
	}

	r.Run(fmt.Sprintf(":%d", conf.HttpSetting.ListenPort))
}
