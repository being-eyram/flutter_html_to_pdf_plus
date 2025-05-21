# flutter_html_to_pdf_plus

[![pub package](https://img.shields.io/pub/v/flutter_html_to_pdf_plus.svg)](https://pub.dartlang.org/packages/flutter_html_to_pdf_plus)

Flutter plugin for generating PDF files from HTML content with support for custom document sizes, orientations, and margins. Works on both Android and iOS.

## Features

- Convert HTML content to PDF
- Support for all standard paper sizes (A0-A10)
- Custom document sizes with user-defined dimensions
- Portrait and landscape orientations
- Customizable page margins
- Support for both Android and iOS
- Support for web images and local images
- Returns both File object and byte data

## Usage

### From a raw HTML content

```dart 
final targetDirectory = "/your/sample/path";
final targetName = "example_pdf_file";

final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
  content: htmlContent, 
  configuration: PrintPdfConfiguration(
    targetDirectory: targetDirectory, 
    targetName: targetName,
    margins: PdfPageMargin(top: 50, bottom: 50, left: 50, right: 50),
    printOrientation: PrintOrientation.Landscape,
    printSize: PrintSize.A4
  ),
);
```

### From an HTML file
```dart
final file = File("/sample_path/example.html");
final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlFile(
  htmlFile: file,
  configuration: PrintPdfConfiguration(
    targetDirectory: targetDirectory, 
    targetName: targetName,
    margins: PdfPageMargin(top: 50, bottom: 50, left: 50, right: 50),
    printOrientation: PrintOrientation.Landscape,
    printSize: PrintSize.A4
  ),
);
```

### From an HTML file path
```dart
final filePath = "/sample_path/example.html";
final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlFilePath(
  htmlFilePath: filePath,
  configuration: PrintPdfConfiguration(
    targetDirectory: targetDirectory, 
    targetName: targetName,
    margins: PdfPageMargin(top: 50, bottom: 50, left: 50, right: 50),
    printOrientation: PrintOrientation.Landscape,
    printSize: PrintSize.A4
  ),
);
```

### Using custom document size

```dart
// Create a configuration with custom size (width and height in pixels at 72 PPI)
final configuration = PrintPdfConfiguration(
  targetDirectory: targetDirectory,
  targetName: targetName,
  printSize: PrintSize.Custom,
  customSize: CustomSize(width: 400, height: 600), // Custom dimensions in pixels (72 PPI)
  printOrientation: PrintOrientation.Portrait,
  margins: PdfPageMargin(top: 50, bottom: 50, left: 50, right: 50),
);

// Generate PDF with custom size
final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
  content: htmlContent,
  configuration: configuration,
);
```

### Getting PDF as bytes

```dart
final pdfBytes = await FlutterHtmlToPdf.convertFromHtmlContentBytes(
  content: htmlContent,
  configuration: PrintPdfConfiguration(
    targetDirectory: targetDirectory,
    targetName: targetName,
    printSize: PrintSize.A4,
  ),
);

// Use the bytes as needed (e.g., upload to server, save to database)
```

### Images
If you want to add local images from the device to your **HTML**, you need to pass the path to the image as the ***src*** value:

```html
<img src="file:///storage/example/your_sample_image.png" alt="local-img">
```

Or if you want to use an image ***File*** object:
```html
<img src="${imageFile.path}" alt="file-img">
```

Web images are also supported:
```html
<img src="https://example.com/image.jpg" alt="web-img">
```

**Note:** Many images inside your document can significantly affect the final file size. We suggest using [flutter_image_compress](https://github.com/OpenFlutter/flutter_image_compress) plugin to compress images before generating PDF.

## Supported Paper Sizes

- A0 - A10 standard sizes
- Custom size with user-defined dimensions

## Supported Orientations

- Portrait
- Landscape

## Contributing

If you want to contribute, please submit a [pull request](https://github.com/originoss/flutter_html_to_pdf_plus/pulls) or [create an issue](https://github.com/originoss/flutter_html_to_pdf_plus/issues).

## Credits

- Thanks to [Afur](https://github.com/afur) for the initial work on this plugin
- Thanks to [raister21](https://github.com/raister21) for their work on PDF Size & Orientation
- Thanks to [wiseminds](https://github.com/wiseminds) for the inspiration for margins customization