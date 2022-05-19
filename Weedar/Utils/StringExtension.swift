//
//  DateFormatter.swift
//  Weelar
//
//  Created by vtsyomenko on 20.08.2021.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}

extension String {
  
  //    var localized: String {
  //           return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
  //       }
  //
  //       func localized(byLang lang: String) -> String {
  //           let path = Bundle.main.path(forResource: lang, ofType: "lproj")
  //           let bundle = Bundle(path: path!)
  //           return NSLocalizedString(self, tableName: nil, bundle: bundle ?? Bundle.localizedBundle(), value: "", comment: "")
  //       }
  
  mutating func toDate(_ format: String = "dd MMM yyyy HH:mm") -> String? {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = format
    
    if let date = dateFormatterGet.date(from: self) {
      return dateFormatterPrint.string(from: date)
    }
    
    return nil
  }
}

extension Double {
  enum TextFormat {
    case ounce, percent, gramm, rounded, int
  }
  
  func formattedString(format: TextFormat) -> String {
    switch format {
    case .gramm:
        return String(format: "%.2f", self)
    case .ounce:
        return String(format: "%.3f", self)
    case .percent:
        return String(format: "%.2f", self)
    case .rounded:
        return String(Int(self.rounded()))
    case .int:
        return String(format: "%.0f", self)
    }
  }
    
  func percentsString() -> String {
    return String(format: "%.2f", self)
  }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        
        // Check empty string
        if self.isEmpty {
            return true
        }
        
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}
