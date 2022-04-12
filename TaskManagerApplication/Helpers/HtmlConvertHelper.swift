//
//  HtmlConvertHelper.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 6.02.22.
//

import Foundation
import UIKit

extension NSAttributedString {
    func toHtmlString() -> String? {
        
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes:documentAttributes)
            
            if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
                // записваме в realm като стринг - >
                return htmlString
//                    .replacingOccurrences(of: "Times New Roman", with: ".AppleSystemUIFont")
//                   .replacingOccurrences(of: ".SFUI-Regular", with: ".AppleSystemUIFont")
//                   .replacingOccurrences(of: "TimesNewRomanPS-BoldMT", with: ".AppleSystemUIFont")
//                   .replacingOccurrences(of: ".SFUI-Semibold", with: ".AppleSystemUIFontz")
            }
            
        }
        catch {
            print("error creating HTML from Attributed String")
        }
        
        return nil
    }
}
