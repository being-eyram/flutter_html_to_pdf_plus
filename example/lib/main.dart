import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrintSize? selectedPrintSize;
  PrintOrientation? selectedPrintOrientation;
  
  // Custom size controller for width and height
  final TextEditingController _widthController = TextEditingController(text: "400");
  final TextEditingController _heightController = TextEditingController(text: "600");

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<String> generateExampleDocument() async {
    const htmlContent = """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
        th, td, p {
          padding: 5px;
          text-align: left;
        }
        </style>
      </head>
      <body>
        <h2>PDF Generated with flutter_html_to_pdf_plus plugin</h2>
        
        <table style="width:100%">
          <caption>Sample HTML Table</caption>
          <tr>
            <th>Month</th>
            <th>Savings</th>
          </tr>
          <tr>
            <td>January</td>
            <td>100</td>
          </tr>
          <tr>
            <td>February</td>
            <td>50</td>
          </tr>
        </table>
        
        <p>Image loaded from web</p>
        <img src="https://i.imgur.com/wxaJsXF.png" alt="web-img">
      </body>
    </html>
    """;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final targetPath = appDocDir.path;
    const targetFileName = "example-pdf";

    if (File("$targetPath/$targetFileName.pdf").existsSync()) {
      File("$targetPath/$targetFileName.pdf").deleteSync();
    }

    // Create configuration with custom size if selected
    PrintPdfConfiguration configuration;
    
    if (selectedPrintSize == PrintSize.Custom) {
      // Parse width and height from text controllers
      final int width = int.tryParse(_widthController.text) ?? 400;
      final int height = int.tryParse(_heightController.text) ?? 600;
      
      configuration = PrintPdfConfiguration(
        targetDirectory: targetPath,
        targetName: targetFileName,
        printSize: PrintSize.Custom,
        printOrientation: selectedPrintOrientation ?? PrintOrientation.Portrait,
        customSize: CustomSize(width: width, height: height),
      );
    } else {
      configuration = PrintPdfConfiguration(
        targetDirectory: targetPath,
        targetName: targetFileName,
        printSize: selectedPrintSize ?? PrintSize.A4,
        printOrientation: selectedPrintOrientation ?? PrintOrientation.Portrait,
      );
    }
    
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      content: htmlContent,
      configuration: configuration,
    );
    return generatedPdfFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Html to PDF'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: selectedPrintOrientation ?? PrintOrientation.Portrait,
              items: [
                ...PrintOrientation.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  );
                })
              ],
              onChanged: (value) =>
                  setState(() => selectedPrintOrientation = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: selectedPrintSize ?? PrintSize.A4,
              items: [
                ...PrintSize.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  );
                })
              ],
              onChanged: (value) => setState(() => selectedPrintSize = value),
            ),
            const SizedBox(height: 16),
            // Show custom size inputs when Custom is selected
            if (selectedPrintSize == PrintSize.Custom)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Width (px)',
                        hintText: 'Enter width in pixels (72 PPI)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (px)',
                        hintText: 'Enter height in pixels (72 PPI)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            if (selectedPrintSize == PrintSize.Custom)
              const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("Open Generated PDF Preview"),
              onPressed: () async {
                final path = await generateExampleDocument();

                await OpenFilex.open(path);
              },
            ),
          ],
        ),
      ),
    );
  }
}
