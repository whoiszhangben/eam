import 'package:asset_management_system/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with SingleTickerProviderStateMixin {
  var result = false;
  Color mask = const Color(0xb2000000);

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();

    return Scaffold(
      body: Stack(children: [
        // 相机内容
        Container(
          width: 100.w,
          height: 100.h,
          color: Colors.red,
          child: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              // TODO 多个扫码结果优化
              print('||| barcode.corners ${barcode.corners}');
              if (result) return;
              result = true;
              if (barcode.rawValue == null) {
                debugPrint('|||Failed to scan Barcode');
                Navigator.pop(context);
              } else {
                final String code = barcode.rawValue!;
                debugPrint('|||Barcode found! $code');
                Navigator.pop(context, code);
              }
            },
          ),
        ),
        // mask
        Positioned(
          top: 0,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.none,
                alignment: Alignment.topCenter,
                image: AssetImage("images/scan_mask.png"),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
        // 扫码线
        Positioned(
          top: 239,
          left: 0,
          right: 0,
          child: SizedBox(
            width: 254,
            height: 254,
            child: Stack(children: [
              ImageScannerAnimation(
                animation: _controller,
              ),
            ]),
          ),
        ),
        // 闪光灯
        Positioned(
          top: 530,
          left: 0,
          right: 0,
          child: ValueListenableBuilder(
            valueListenable: cameraController.torchState,
            builder: (context, state, child) {
              switch (state) {
                case TorchState.off:
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          cameraController.toggleTorch();
                        },
                        icon: Image.asset('images/light_off.png'),
                      ),
                      const Text(
                        '轻触点亮',
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    ],
                  );
                case TorchState.on:
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          cameraController.toggleTorch();
                        },
                        icon: Image.asset('images/light.png'),
                      ),
                      const Text(
                        '轻触关闭',
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
        // 标题
        Positioned(
          child: TitleContent('扫一扫'),
        ),
      ]),
    );
  }
}

class ImageScannerAnimation extends AnimatedWidget {
  const ImageScannerAnimation({
    Key? key,
    required Animation<double> animation,
  }) : super(
          key: key,
          listenable: animation,
        );

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    // print(animation.value * 244);

    return Positioned(
      bottom: animation.value * 244, // 0~244
      left: 0,
      right: 0,
      child: SizedBox(
        height: 10,
        child: Image.asset('images/scan_line.png'),
      ),
    );
  }
}
