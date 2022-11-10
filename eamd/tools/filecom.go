package tools

import (
	"bufio"
	"crypto/md5"
	"errors"
	"fmt"
	"golang.org/x/crypto/bcrypt"
	"io"
	"os"
)

func FileComp() {
	f, _ := os.Open("D:\\posman\\abc.xlsx")
	ff := bufio.NewReader(f)
	buf, _ := io.ReadAll(ff)
	fmt.Printf("%x", md5.Sum([]byte(buf)))
}

// GeneratePassword 给密码就行加密操作
func GeneratePassword(userPassword string) ([]byte, error) {
	return bcrypt.GenerateFromPassword([]byte(userPassword), bcrypt.DefaultCost)
}

// ValidatePassword 密码比对
func ValidatePassword(userPassword string, hashed string) (isOK bool, err error) {
	if err = bcrypt.CompareHashAndPassword([]byte(hashed), []byte(userPassword)); err != nil {
		return false, errors.New("密码比对错误！")
	}
	return true, nil

}
