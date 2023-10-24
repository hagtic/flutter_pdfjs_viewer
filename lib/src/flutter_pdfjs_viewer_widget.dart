import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jaguar/jaguar.dart';
import 'package:http/http.dart' as http;

class PDFJSViewerWidget extends StatefulWidget {
  /// support assets path, file path，http link
  final String? filePath;
  /// isAssets default false
  /// isAssets is true,filePath != null
  /// use rootBundle.load(widget.filePath!)
  final bool isAssets;
  final Uint8List? fileData;
  /// exit page to clear webView cache,default true
  final bool clearCache;
  const PDFJSViewerWidget._({super.key, this.filePath,this.fileData,this.isAssets = false,this.clearCache = true}):assert(filePath != null || fileData != null);

  @override
  State<PDFJSViewerWidget> createState() => _PDFJSViewerWidgetState();

  factory PDFJSViewerWidget.data(Uint8List data,[bool clearCache = true,Key? key]){
    return PDFJSViewerWidget._(fileData:data,clearCache: clearCache,key: key,);
  }

  factory PDFJSViewerWidget.network(String url,[bool clearCache = true,Key? key]){
    return PDFJSViewerWidget._(filePath:url,clearCache: clearCache,key: key,);
  }

  factory PDFJSViewerWidget.file(String absolutePath,[bool clearCache = true,Key? key]){
    return PDFJSViewerWidget._(filePath:absolutePath,clearCache: clearCache,key: key,);
  }

  factory PDFJSViewerWidget.assets(String asset,[bool clearCache = true,Key? key]){
    return PDFJSViewerWidget._(filePath:asset,isAssets: true,clearCache: clearCache,key: key,);
  }
}

class _PDFJSViewerWidgetState extends State<PDFJSViewerWidget> {
  late Jaguar server;
  late final WebViewController _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
  late final String interceptUrl;
  @override
  void initState() {
    final random = Random();
    const minPort = 10000;
    const maxPort = 65535;
    int randomPort = minPort + random.nextInt(maxPort - minPort + 1);
    interceptUrl = 'http://127.0.0.1:$randomPort/pdfjs/web/viewer.html?file=/api/intercept';
    server = Jaguar(port: randomPort);
    _startServer();
    super.initState();
  }

  _startServer()async{
    server.addRoute(_serveFlutterAssets());
    server.get('/api/intercept', (Context ctx)async{
      List<int>? bytes;
      if(widget.fileData != null){
        log('Processing Uint8List data：：：：',name: 'flutter_pdfjs_viewer');
        bytes = widget.fileData!;
      }else if(widget.filePath!.startsWith('http')) {
        log('Processing Network data：：：：',name: 'flutter_pdfjs_viewer');
        final response = await http.get(Uri.parse(widget.filePath!));
        if(response.statusCode == 200){
          bytes = response.bodyBytes;
        }
      }else if(widget.isAssets){
        log('Processing Assets data：：：：',name: 'flutter_pdfjs_viewer');
         assert(widget.filePath != null);
         final byteData = await rootBundle.load(widget.filePath!);
         bytes = Uint8List.view(byteData.buffer);
      }else{
        log('Processing File data：：：：',name: 'flutter_pdfjs_viewer');
        bytes = await File(widget.filePath!).readAsBytes();
      }
      return ByteResponse(body: bytes, mimeType: 'application/pdf ');
    });
    await server.serve();
    Future.delayed(Duration.zero,(){
      _controller.loadRequest(Uri.parse(interceptUrl));
    });
  }

  Route _serveFlutterAssets(
      {String path = '*',
        bool stripPrefix = true,
        String prefix = '',
        Map<String, String>? pathRegEx,
        ResponseProcessor? responseProcessor}) {
    Route route;
    int skipCount = -1;
    route = Route.get(path, (ctx) async {
      Iterable<String> segs = ctx.pathSegments;
      if (skipCount > 0) segs = segs.skip(skipCount);

      String lookupPath =
          segs.join('/') + (ctx.path.endsWith('/') ? 'index.html' : '');
      final body = (await rootBundle.load('packages/flutter_pdfjs_viewer/assets/$prefix$lookupPath'))
          .buffer
          .asUint8List();

      String? mimeType;
      if (!ctx.path.endsWith('/')) {
        if (ctx.pathSegments.isNotEmpty) {
          final String last = ctx.pathSegments.last;
          if (last.contains('.')) {
            mimeType = MimeTypes.fromFileExtension[last.split('.').last];
          }
        }
      } else {
        mimeType = 'text/html';
      }

      ctx.response = ByteResponse(body: body, mimeType: mimeType);
    }, pathRegEx: pathRegEx, responseProcessor: responseProcessor);

    if (stripPrefix) skipCount = route.pathSegments.length - 1;

    return route;
  }

  @override
  void didUpdateWidget(covariant PDFJSViewerWidget oldWidget) {
    if(widget.filePath != oldWidget.filePath || widget.fileData != oldWidget.fileData || widget.isAssets != oldWidget.isAssets){
      _controller.reload();
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  void dispose() {
    server.close();
    if(widget.clearCache){
      _controller.clearCache();
      _controller.clearLocalStorage();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
