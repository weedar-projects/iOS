//
//  NSMutableAttributedString+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 22.09.2021.
//

import Foundation

extension NSMutableAttributedString {
    func apply(link: String, subString: String)  {
        if let range = self.string.range(of: subString) {
            self.apply(link: link, onRange: NSRange(range, in: self.string))
        }
    }
    
    private func apply(link: String, onRange: NSRange) {
        self.addAttributes([NSAttributedString.Key.link: link], range: onRange)
    }
}
