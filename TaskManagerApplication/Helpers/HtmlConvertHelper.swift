//
//  HtmlConvertHelper.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 6.02.22.
//

import Foundation


extension NSAttributedString {
    func toHtmlString() -> String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes:documentAttributes)
            
            if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
                // записваме в realm като стринг - >
                return htmlString
            }
        }
        catch {
            print("error creating HTML from Attributed String")
        }
        
        return nil
    }
}


