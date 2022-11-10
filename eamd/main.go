package main

import (
	"eamd/startup"
	_ "github.com/codyguo/godaemon"
	"os"
	"os/signal"
	"syscall"
)

func main() {

	startup.StartUp()
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)
	go func() {
		signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
		<-sigs
		done <- true
	}()
	<-done
}
