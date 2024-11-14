import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove(); // 스플래시 화면을 초기화할 때 제거
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewPage(),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView();
  }

  // 웹 페이지 URL
  final String frontendUrl = "http://172.30.1.6:5173/dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebView Example")),
      body: WebView(
        initialUrl: frontendUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        onPageFinished: (String url) {
          // 페이지 로딩 완료 후 수행할 작업
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('intent://')) {
            // 인텐트를 처리하거나 다른 URL로 이동
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openFileChooser(false), // 이미지 파일 선택
        child: Icon(Icons.attach_file),
      ),
    );
  }

  // 파일 선택기 (이미지, 비디오)
  Future<void> openFileChooser(bool isVideo) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: isVideo ? FileType.video : FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      print('Selected file: ${file.name}');
      // 파일을 선택한 후 처리하는 로직 추가
    } else {
      print('User canceled the picker');
    }
  }

  // 뒤로 가기 동작 제어
  Future<bool> _onWillPop() async {
    bool canGoBack = await _webViewController.canGoBack();
    if (canGoBack) {
      _webViewController.goBack();
      return Future.value(false); // 뒤로 가기 기본 동작 막기
    }
    return Future.value(true); // 기본 뒤로 가기 동작 실행
  }

  // 위치 권한 요청
  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
    }
  }

  // 알림 권한 요청
  void requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted");
    } else {
      print("Notification permission denied");
    }
  }
}

