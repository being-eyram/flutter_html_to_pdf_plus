import Cocoa
import WebKit
import PDFKit

class PDFCreator {
    
    /**
     Creates a PDF using the given HTML content and saves it to the user's document directory.
     - returns: The generated PDF path.
     */
    class func create(htmlContent: String, width: Double, height: Double, orientation: String, margins: [Int]?) -> URL {
        // Create a data representation of the HTML content
        guard let htmlData = htmlContent.data(using: .utf8) else {
            fatalError("Failed to convert HTML content to data")
        }
        
        // Create an attributed string from HTML
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            fatalError("Failed to create attributed string from HTML")
        }
        
        // Calculate the page size and margins
        let pageSize = NSSize(width: width, height: height)
        let marginLeft = CGFloat(margins?[0] ?? 50)
        let marginTop = CGFloat(margins?[1] ?? 50)
        let marginRight = CGFloat(margins?[2] ?? 50)
        let marginBottom = CGFloat(margins?[3] ?? 50)
        
        // Create a PDF document with the attributed string
        let pdfData = NSMutableData()
        
        // Create a PDF context
        var mediaBox = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        guard let dataConsumer = CGDataConsumer(data: pdfData as CFMutableData),
              let context = CGContext(consumer: dataConsumer, mediaBox: &mediaBox, nil) else {
            fatalError("Could not create PDF context")
        }
        
        // Begin PDF page
        let pdfInfo = [kCGPDFContextMediaBox as String: mediaBox] as CFDictionary
        context.beginPDFPage(pdfInfo)
        
        // Set up the drawing area with margins
        let drawingRect = CGRect(
            x: marginLeft,
            y: marginTop,
            width: pageSize.width - marginLeft - marginRight,
            height: pageSize.height - marginTop - marginBottom
        )
        
        // Create a text container with the drawing size
        let textContainer = NSTextContainer(size: drawingRect.size)
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Create a graphics context for drawing
        let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        
        // Draw the text
        layoutManager.drawGlyphs(forGlyphRange: NSRange(location: 0, length: attributedString.length), at: drawingRect.origin)
        
        // End PDF page and context
        NSGraphicsContext.restoreGraphicsState()
        context.endPDFPage()
        context.closePDF()
        
        // Write the PDF data to a file
        guard nil != (try? pdfData.write(to: createdFileURL, options: .atomic)) else {
            fatalError("Failed to write PDF data to file")
        }
        
        return createdFileURL
    }
    
    /**
     Creates temporary PDF document URL
     */
    private class var createdFileURL: URL {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, 
                                                          in: .userDomainMask, 
                                                          appropriateFor: nil, 
                                                          create: true)
            else { fatalError("Error getting user's document directory.") }
        
        let url = directory.appendingPathComponent("generatedPdfFile").appendingPathExtension("pdf")
        return url
    }
}
