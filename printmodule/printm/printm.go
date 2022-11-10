package printm

import "C"
import (
	"context"
	"encoding/json"
	"unsafe"
)

/*
// C 标志io头文件，你也可以使用里面提供的函数

#include <windows.h>
#include<string.h>
#include <stdio.h>

//#define  l_w  50 * 12
static int l_w = 50 * 12;
static int l_h = 30 * 12;
static int  t_h;
static int  i_h;
static int  mm;

typedef int(_cdecl *F_PTK_OpenUSBPort)(int);
typedef int(_cdecl *F_PTK_DrawText)(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int, unsigned int ,char, const char* );
typedef int(_cdecl *F_PTK_PrintLabel)(unsigned int number, unsigned int cpnumber);
typedef int(_cdecl *F_PTK_SetLabelWidth)(unsigned int lwidth);
typedef int(_cdecl *F_PTK_SetLabelHeight)(unsigned int lheight, unsigned int gapH, int gapOffset, BOOL bFlag);
typedef int(_cdecl *F_PTK_ClearBuffer)();
typedef int(_cdecl *F_PTK_SetDirection)(char);
typedef int(_cdecl *F_PTK_DrawBar2D_QR)(unsigned int x, unsigned int y,unsigned int w, unsigned int v,unsigned int o, unsigned int r,unsigned int m, unsigned int g,unsigned int s, LPTSTR pstr);
typedef int(_cdecl *F_PTK_DrawText_TrueType)(unsigned int x, unsigned int y, unsigned int FHeight, unsigned int FWidth,LPCTSTR FType, unsigned int Fspin, unsigned int FWeight, BOOL FItalic, BOOL FUnline, BOOL FStrikeOut, LPCTSTR data);
typedef int(_cdecl *F_PTK_DrawRectangle)(unsigned int px, unsigned int py, unsigned int thickness, unsigned int pEx,unsigned int pEy);
typedef int(_cdecl *F_PTK_DrawLineXor)(unsigned int px, unsigned int py,unsigned int pL, unsigned int pH);
typedef int(_cdecl *F_PTK_MediaDetect)(void);
typedef int(_cdecl *F_PTK_AnyGraphicsPrintFromMemory)(int px, int py, LPTSTR pcxname, unsigned int imageType,unsigned int imageSize,float ratio, unsigned int width, unsigned int height, unsigned int iDire, unsigned char* imageBuffer);


HMODULE hMod;

F_PTK_SetLabelWidth setLabelWidth;
F_PTK_SetLabelHeight setLabelHeight;
F_PTK_ClearBuffer clearBuffer;
F_PTK_DrawBar2D_QR drawBar2D_QR;
F_PTK_DrawText_TrueType drawText_TrueType;
F_PTK_DrawRectangle drawRectangle;
F_PTK_PrintLabel printLabel;
F_PTK_DrawText drawText;
F_PTK_DrawLineXor drawLineXor;
F_PTK_MediaDetect mediaDetect;
F_PTK_AnyGraphicsPrintFromMemory anyGraphicsPrintFromMemory;

unsigned char imagebuff[1024 * 1024] = { 0 };
int imagesize = 0;

 int openPrint(){
	printf(" load CDFPSK64.dll \n");
    hMod = LoadLibrary("CDFPSK64.dll");
    if (hMod == NULL){
		printf( "open dll error \n");
		return	-1;
    }

  	F_PTK_OpenUSBPort openUsb = (F_PTK_OpenUSBPort)GetProcAddress(hMod, "PTK_OpenUSBPort");
	F_PTK_SetDirection setDirection = (F_PTK_SetDirection)GetProcAddress(hMod, "PTK_SetDirection");

	int nValue = openUsb(255);
	setDirection('T');

	drawText = (F_PTK_DrawText)GetProcAddress(hMod, "PTK_DrawText");
	setLabelWidth = (F_PTK_SetLabelWidth)GetProcAddress(hMod, "PTK_SetLabelWidth");
	setLabelHeight = (F_PTK_SetLabelHeight)GetProcAddress(hMod, "PTK_SetLabelHeight");
	clearBuffer = (F_PTK_ClearBuffer)GetProcAddress(hMod, "PTK_ClearBuffer");
	drawBar2D_QR = (F_PTK_DrawBar2D_QR)GetProcAddress(hMod, "PTK_DrawBar2D_QR");
	drawText_TrueType = (F_PTK_DrawText_TrueType)GetProcAddress(hMod, "PTK_DrawText_TrueType");
	drawRectangle = (F_PTK_DrawRectangle)GetProcAddress(hMod, "PTK_DrawRectangle");
	printLabel = (F_PTK_PrintLabel)GetProcAddress(hMod, "PTK_PrintLabel");
	drawLineXor = (F_PTK_DrawLineXor)GetProcAddress(hMod, "PTK_DrawLineXor");
	mediaDetect = (F_PTK_MediaDetect)GetProcAddress(hMod, "PTK_MediaDetect");
	anyGraphicsPrintFromMemory = (F_PTK_AnyGraphicsPrintFromMemory)GetProcAddress(hMod, "PTK_AnyGraphicsPrintFromMemory");


	FILE * fp = NULL;
	char file_name[256] = "logo.png";

	fopen_s(&fp, file_name, "rb");
	imagesize = fread(imagebuff, sizeof(unsigned char), sizeof(imagebuff) - 1, fp);
	fclose(fp);

	setLabelWidth(l_w);
	setLabelHeight(l_h, 2*mm, 0, TRUE);

	return nValue;
 }

int setwh(int w, int h){
	l_w  = w * 12;
	l_h = h * 12;

	t_h =  l_h / 10;
 	i_h = (l_h - 2*mm) / 4;
 	mm =  12;
}

int printmsg(char* strNo, char *title, char *savelocation, char *org, char* qr){

	clearBuffer();
	//qR(30*12, 12*3, 0,0,0,6,0,0,8, input);
	//px：起始点的 X 坐标，以点(dots)为单位；
	//py：起始点的 Y 坐标，以点(dots)为单位；
	//thickness：边框的粗细，以点(dots)为单位；
	//pEx：终止点的 X 坐标，以点(dots)为单位；
	//pEy：终止点的 Y 坐标，以点(dots)为单位。
	drawRectangle(1*mm, 1*mm, 4, l_w - 1*mm, l_h - 1*mm);

	drawLineXor(1*mm, 1*mm + i_h , l_w - 2*mm, 2);
	drawLineXor(1*mm, 1*mm + i_h * 2, l_w - 2*mm, 2);
	drawLineXor(1*mm, 1*mm + i_h * 3, l_w - 2*mm -  (l_h - 2*mm) / 4 * 2, 2);
	drawLineXor(l_w - 1*mm - i_h * 2 ,  1*mm + (l_h - 2*mm) / 4 * 2,  2,  (l_h - 2*mm) / 4 * 2);

	//设置 X 坐标，以点(dots)为单位；
	//设置 Y 坐标，以点(dots)为单位；
	//字型高度，以点(dots)为单位；
	//字型宽度，以点(dots)为单位
	//FType：字型名称；
	//Fspin：字体旋转角度:
	//Fweight：字体粗细
	//Fitalic：斜体，0 -> FALSE、1 -> TRUE
	//Funline：文字加底线，0 -> FALSE、1 -> TRUE；
	//FstrikeOut：文字加删除线，0 -> FALSE、1 -> TRUE；
	//data：字符串内容
	//drawText_TrueType(l_w / 20 * 12, 12 * 3, l_h / 8 * 12,  0, "宋体",1, 700, FALSE, FALSE, FALSE, title);

	anyGraphicsPrintFromMemory((l_w - 2*mm)/2 - ((l_h - 2*mm) / 4 / 10 * 9*4 / 2) ,  1.5*mm +  i_h / 20, "P1", 4, imagesize, 0,  (l_h - 2*mm) / 4 / 10 * 9*4 ,  (l_h - 2*mm) / 4 / 10 * 9, 0, imagebuff);
	drawText_TrueType(3*mm, 1*mm + i_h + i_h/2 - t_h / 2, t_h,  0, "宋体",1, 400, FALSE, FALSE, FALSE, title );
	drawText_TrueType(l_w-1*mm - t_h * 8 *0.5, 1*mm + i_h + i_h/2 - t_h / 3, t_h * 0.8,  0, "宋体",1, 400, FALSE, FALSE, FALSE, strNo );
	drawText_TrueType(3*mm, 1*mm + i_h *2 + i_h/2 - t_h / 2, t_h,  0, "宋体",1, 400, FALSE, FALSE, FALSE, savelocation);
	drawText_TrueType(3*mm, 1*mm + i_h *3 + i_h/2 - t_h / 2, t_h,  0, "宋体",1, 400, FALSE, FALSE, FALSE, org);
	drawBar2D_QR(l_w - 1*mm - i_h * 2 + 6, 1*mm + (l_h - 2*mm) / 4 * 2 + 6, 0, 0, 0, 7, 0, 0, 8, qr);
	return printLabel(1, 1);
	return 0;
}

*/
import "C" // 切勿换行再写这个

import "fmt"

type PrintS struct {
}

type GoodsModel struct {
	Id               int64   `json:"id"`
	Name             string  `json:"name"`
	Orgid            int64   `json:"orgId"`
	BuyTime          *string `json:"buyTime"`
	Amount           *int64  `json:"amount"`
	Unit             string  `json:"unit"`
	Model            string  `json:"model"`
	Price            float64 `json:"price"`
	GSortId          int64   `json:"gSortId"`
	State            int     `json:"state"`
	Savelocation     string  `json:"savelocation"`
	Custodian        string  `json:"custodian"`
	Description      string  `json:"description"`
	Pcount           int64   `json:"pcount"`
	OrganizationName string  `json:"organizationName"`
}

func (this PrintS) PrintQr(c context.Context, req *PrintMsg) (*PrintResult, error) {
	fmt.Println(req)
	return &PrintResult{
		Id:       req.Id,
		Result:   false,
		Strerror: "",
	}, nil
}

func init() {

	//1.初始化grpc
	/*grpcServer := grpc.NewServer()
	RegisterPrintmServer(grpcServer, &PrintS{})
	liseter, err := net.Listen("tcp", "127.0.0.1:7000")
	if err != nil {
		fmt.Println(err)
	}

	go func() {
		defer liseter.Close()
		grpcServer.Serve(liseter)
	}()*/

	//b := C.openPrint()
	//.Log.Debug("open print_label:%v", b)

	C.setwh(C.int(LabelSetting.Width), C.int(LabelSetting.Height))
	//TestPrintMsg()
	//Start()

}

func TestPrintMsg() {
	C.openPrint()
	strNo := C.CString("(NO:00001)")
	title := C.CString("i5-12代主机")
	savelocation := C.CString(fmt.Sprintf("位置:%v", "二楼大厅"))
	org := C.CString(fmt.Sprintf("部门:%v", "人力资源"))
	user := C.CString(fmt.Sprintf("使用人:%v", "郭诏艺"))
	qr := C.CString("1")
	C.printmsg(strNo, title, savelocation, org, qr)

	C.free(unsafe.Pointer(strNo))
	C.free(unsafe.Pointer(title))
	C.free(unsafe.Pointer(savelocation))
	C.free(unsafe.Pointer(org))
	C.free(unsafe.Pointer(user))
	C.free(unsafe.Pointer(qr))
}

func PrintLabel(goods []GoodsModel) {
	C.openPrint()
	for _, v := range goods {

		if len(v.Savelocation) > 5 {
			savelocationTemp := []rune(v.Savelocation)
			v.Savelocation = string(savelocationTemp[0:5])
		}
		if len(v.OrganizationName) > 5 {
			organizationNameTemp := []rune(v.OrganizationName)
			v.OrganizationName = string(organizationNameTemp[0:5])
		}
		title := C.CString(v.Name)
		strNo := C.CString(fmt.Sprintf("(NO.%05v)", v.Id))
		savelocation := C.CString(fmt.Sprintf("位置:%v", v.Savelocation))
		org := C.CString(fmt.Sprintf("部门:%v", v.OrganizationName))
		qr := C.CString(fmt.Sprintf("%v", v.Id))
		a := C.printmsg(strNo, title, savelocation, org, qr)

		C.free(unsafe.Pointer(strNo))
		C.free(unsafe.Pointer(title))
		C.free(unsafe.Pointer(savelocation))
		C.free(unsafe.Pointer(org))
		C.free(unsafe.Pointer(qr))
		ans := make(map[string]interface{}, 0)
		ans["id"] = v.Id
		if a == 0 {
			ans["result"] = true
		} else {
			ans["result"] = false
			ans["errMsg"] = "打印失败"
		}
		fmt.Printf("打印（%v）：%v\n", v.Id, a == 0)

		buff, err := json.Marshal(ans)
		if err != nil {
		}
		PublishMsg(fmt.Sprintf("eam/answer/%v", MqttSetting.ClientId), string(buff))
	}
}
