package main

import (
	_ "github.com/codyguo/godaemon"
	"os"
	"os/signal"
	"printmodule/printm"
	"syscall"
)

func main() {
	printm.Start()
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)
	go func() {
		signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
		<-sigs
		done <- true
	}()
	<-done
}

/*
func main() {
	grpcClient, err := grpc.Dial("127.0.0.1:7000", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		fmt.Println(err.Error())
	}

	//注册客户端
	clent := printm.NewPrintmClient(grpcClient)
	b, err := clent.PrintQr(context.Background(), &printm.PrintMsg{
		Id:           1,
		Savelocation: "aaaaa",
	})

	fmt.Println(b)
}
*/
