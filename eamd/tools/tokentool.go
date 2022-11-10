package tools

import (
	"eamd/log"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	jwt "github.com/golang-jwt/jwt"
)

// 自定义一个字符串
var jwtkey = []byte("ht-accets")

type Claims struct {
	Id         int64
	UserName   string
	Passwd     string
	Role       int
	ClientType int
	jwt.StandardClaims
}

// 根据用户名和密码生成token
func MakeToen(id int64, username string, passwd string, role int, clientType int) (token string, expireTimestamp int64, err error) {
	nowTime := time.Now()
	exprieTime := nowTime.Add(600 * time.Minute)
	expireTimestamp = exprieTime.Unix()

	claims := &Claims{
		Id:         id,
		UserName:   username,
		Passwd:     passwd,
		Role:       role,
		ClientType: clientType,
		StandardClaims: jwt.StandardClaims{
			IssuedAt:  nowTime.Unix(),
			ExpiresAt: exprieTime.Unix(),
			Issuer:    "gin-blog",
		},
	}
	tokenClaims := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	token, err = tokenClaims.SignedString(jwtkey)
	return
}

func TokenAuth(ctx *gin.Context) {
	token := ctx.Request.Header.Get("token")
	if token == "" {
		ctx.JSON(http.StatusOK, gin.H{
			"result": false,
			"error":  "会话已过期，请重新登录",
		})
		ctx.Abort()
		return
	}
	claims, err := ParseToken(token)
	if err != nil {
		if strings.HasPrefix(err.Error(), "token is expired by") {
			ctx.JSON(http.StatusOK, gin.H{
				"result": false,
				"msg":    err.Error(),
				"error":  "会话已过期，请重新登录",
			})
			ctx.Abort()
			return
		} else {
			ctx.JSON(http.StatusOK, gin.H{
				"result": false,
				"error":  err.Error(),
			})
			ctx.Abort()
			return
		}
		return
	}

	ctx.Set("id", claims.Id)
	ctx.Set("account", claims.UserName)
	AclCheck(claims.Role, ctx)
}

func AclCheck(role int, ctx *gin.Context) {
	fun := ctx.FullPath()
	strS := strings.Split(fun, "/")
	if len(strS) < 4 {
		ctx.Abort()
		ctx.JSON(http.StatusOK, gin.H{
			"error": "url error ",
		})
		return
	}
	fun = strS[2]
	opt := strS[3]
	if fun == "account" && (opt == "query" || opt == "add") {
		if role != 1 {
			ctx.JSON(http.StatusOK, gin.H{
				"errcode": -1,
				"errmsg":  "没有访问权限",
			})
			ctx.Abort()
			return
		}
	}
}

func ParseToken(token string) (rclaims *Claims, rerr error) {
	tokenClaims, err := jwt.ParseWithClaims(token, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return jwtkey, nil
	})

	if tokenClaims != nil {
		if claims, ok := tokenClaims.Claims.(*Claims); ok && tokenClaims.Valid {
			return claims, nil
		}
	}
	return nil, err
}

func GetUserId(ctx *gin.Context) int64 {
	defer func() {
		if err := recover(); err != nil {
			log.Log.Error("", err)
		}
	}()

	claims, err := ParseToken(ctx.Request.Header.Get("token"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"result": false,
			"error":  err.Error(),
		})
		return 0
	}
	return claims.Id
}

func GetClaims(ctx *gin.Context) Claims {
	defer func() {
		if err := recover(); err != nil {
			log.Log.Error("", err)
		}
	}()

	claims, err := ParseToken(ctx.Request.Header.Get("token"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"result": false,
			"error":  err.Error(),
		})
		return Claims{}
	}
	return *claims
}
