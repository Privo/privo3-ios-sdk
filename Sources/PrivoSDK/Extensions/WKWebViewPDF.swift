import UIKit
import Foundation
import WebKit

extension WKWebView {
    
    // Call this function when WKWebView finish loading
    func exportAsPdfFromWebView(name: String) -> URL? {
        let pdfData = createPdfFile(printFormatter: self.viewPrintFormatter())
        return saveWebViewPdf(data: pdfData, name: name)
    }
    
    func createPdfFile(printFormatter: UIViewPrintFormatter) -> NSMutableData {
        let originalBounds = bounds
        self.bounds = CGRect(x: originalBounds.origin.x,
                             y: bounds.origin.y,
                             width: bounds.size.width,
                             height: scrollView.contentSize.height)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: scrollView.contentSize.height)
        let printPageRenderer = UIPrintPageRenderer()
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        printPageRenderer.setValue(NSValue(cgRect: UIScreen.main.bounds), forKey: "paperRect")
        printPageRenderer.setValue(NSValue(cgRect: pdfPageFrame), forKey: "printableRect")
        bounds = originalBounds
        return printPageRenderer.generatePdfData()
    }
    
    // Save pdf file in document directory
    func saveWebViewPdf(data: NSMutableData, name: String) -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent(name)
        guard data.write(to: pdfPath, atomically: true) else { return nil }
        return pdfPath
    }
    
}

extension UIPrintPageRenderer {
    
    func generatePdfData() -> NSMutableData {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        prepare(forDrawingPages: NSMakeRange(0, numberOfPages))
        let printRect = UIGraphicsGetPDFContextBounds()
        if numberOfPages > 0 {
            for pdfPage in 0...(numberOfPages - 1) {
                UIGraphicsBeginPDFPage()
                drawPage(at: pdfPage, in: printRect)
            }
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    
}
