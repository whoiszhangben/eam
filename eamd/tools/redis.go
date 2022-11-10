package tools

import (
	"eamd/conf"
	"fmt"
	"github.com/go-redis/redis"
)

var Redisdb *redis.Client

const (
	REDIS_H_ORG_CODE_ID   = "organizationcodeid"
	REDIS_H_ORG_ID_CODE   = "organizationidcode"
	REDIS_H_GSORT_CODE_ID = "gsortcodeid"
	REDIS_H_GSORT_ID_CODE = "gsortidcode"
)

func InitRedis() (err error) {
	Redisdb = redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%v:%v", conf.RedisSetting.Host, conf.RedisSetting.Port),
		Password: conf.RedisSetting.Pwssword,
		DB:       0, // redis一共16个库，指定其中一个库即可
	})
	_, err = Redisdb.Ping().Result()
	return
}
