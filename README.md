## Features
**only support android and iOS**,
Based on the PDF file browser encapsulated in **pdf.js**, this plugin can help you find out how the PDF you are using cannot display relevant information such as signatures.

## Getting started

```dart
import 'package:flutter_pdfjs_viewer/flutter_pdfjs_viewer.dart';
```

## iOS config ATS for info.plist file
```
<key>NSAppTransportSecurity</key>
<dict>
   <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## android config 

AndroidManifest.xml requires configuring HTTP access permissions

```
<uses-permission android:name="android.permission.INTERNET" />
```
```
   <application
        android:usesCleartextTraffic="true"
        ......

  or custom network_security_config.xml in res/xml directory

   <application
        android:networkSecurityConfig="@xml/network_security_config"
        ...... 
```

## Usage

Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfjs_viewer/flutter_pdfjs_viewer.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Detail'),),
      // body: PDFJSViewerWidget.data(data),
      // body: PDFJSViewerWidget.file(path),
      // body: PDFJSViewerWidget.network(path),
      // body: PDFJSViewerWidget.assets(path),
    );
  }
}

```
