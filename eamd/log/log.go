package log

import (
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego/logs"
)

var Log *logs.BeeLogger

func init() {
	log := logs.NewLogger(50)
	log.EnableFuncCallDepth(true)
	log.SetLogFuncCallDepth(3)
	Log = log
}

//初始化系统日志
//logWay： file-输入到文件；console-输出到控制台
//logGile：日志文件
//logLevel：日志等级
//disableLogColor：是否显示颜色
// tags: 日志显示tag
func InitLog(logway, logFile string, maxlines, maxsize int64, disableLogColor bool) {
	setLogFile(logway, logFile, maxlines, maxsize, disableLogColor)
}

//设置日志文件参数
//logway： file，console
func setLogFile(logWay, logFile string, maxlines, maxsize int64, disableLogColor bool) {
	if logWay == "console" {
		params := ""
		if disableLogColor {
			params = `{"color": false}`
		}
		_ = logs.SetLogger(logWay, params)
	} else {
		config := make(map[string]interface{})
		config["filename"] = logFile
		config["level"] = logs.LevelDebug
		config["maxlines"] = maxlines
		config["maxsize"] = maxsize

		configStr, err := json.Marshal(config)
		if err != nil {
			fmt.Println("marshal failed!")
			return
		}
		logs.SetLogger(logs.AdapterFile, string(configStr))
		logs.EnableFuncCallDepth(true)
		logs.Debug("this is test log") // 打印日
	}
}

//设置日志显示等级
func setLogLeve(logLeve string) {
	level := 4
	switch logLeve {
	case "error":
		level = 3
	case "warn":
		level = 4
	case "info":
		level = 6
	case "debug":
		level = 7
	case "trace":
		level = 8
	default:
		level = 4
	}
	Log.SetLevel(level)
}
