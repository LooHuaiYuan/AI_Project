// Add these dependencies to pubspec.yaml:
// google_mlkit_text_recognition: ^0.11.0
// google_generativeai: ^0.1.0
// qr_code_scanner: ^1.0.1
// image_picker: ^1.0.4

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_generative_ai/google_generative_ai.dart'
    show Content, GenerativeModel;

void main() => runApp(ScannerApp());

class ScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntegratedScannerPage(),
    );
  }
}

class IntegratedScannerPage extends StatefulWidget {
  @override
  _IntegratedScannerPageState createState() => _IntegratedScannerPageState();
}

class _IntegratedScannerPageState extends State<IntegratedScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final textRecognizer = TextRecognizer();
  String? processedText;
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  Future<void> processImage(String imagePath) async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Perform OCR
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract texts similar to your notebook implementation
      List<String> texts = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          texts.add(line.text);
        }
      }

      // Use Gemini to interpret the text
      final result = await interpretWithGemini(texts);

      setState(() {
        processedText = result;
        isProcessing = false;
      });

      // Show results in a dialog
      showResultDialog(context, result);
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        isProcessing = false;
        processedText = 'Error processing image: $e';
      });
    }
  }

  Future<String> interpretWithGemini(List<String> texts) async {
    try {
      // Initialize Gemini
      const apiKey =
          'AIzaSyDaoj0EEGoxypADno2UQFP5JS7s6QIGA90'; // Replace with your API key
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );

      // Create the prompt
      final prompt = '''
        Interpret the texts data and summarize the receipt data in this format:
        Category=
        Each Product and their respective price=
        Total=
        Text data: ${texts.join(' ')}
      ''';

      // Generate content
      final content = await model.generateContent([
        Content.text(prompt), // Wrap the prompt string in Content.text()
      ]);

      return content.text ?? 'No interpretation available';
    } catch (e) {
      return 'Error interpreting text: $e';
    }
  }

  void showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan Results'),
          content: SingleChildScrollView(
            child: Text(result),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await processImage(pickedFile.path);
    }
  }

  Future<void> _captureAndProcess() async {
    try {
      await controller?.pauseCamera();
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        await processImage(image.path);
      }
    } finally {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Scanner", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isProcessing ? null : _pickImageFromGallery,
                      child: Text("From Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isProcessing ? null : _captureAndProcess,
                      child: Text("Capture Receipt"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    controller?.toggleFlash();
                  },
                  icon: Icon(Icons.flashlight_on),
                ),
                if (isProcessing) CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      print("QR Code/Barcode Scanned: ${result?.code}");
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    textRecognizer.close();
    super.dispose();
  }
}
