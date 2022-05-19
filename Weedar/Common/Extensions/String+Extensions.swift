//
//  String+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 12.10.2021.
//

import Foundation

extension String {
    var countryISO2: String {
        return hasPrefix("+38") ? "UA" : "US"
    }

    var formattedPhoneNumber: String {
        let numbers = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        let mask: PhoneMask = prefix(2) == "+1" ? .american : .ukrainian
        
        for character in mask.rawValue where index < numbers.endIndex {
            if character == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(character)
            }
        }
        
        return result
    }
    
    var countryFlag: String {
        let base: UInt32 = 127397
        var s = ""
        
        for v in countryISO2.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }

        return String(s)
    }
    
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    // Password should contain 1 capital letter, 1 lower letter, 1 digit and to be at least 8 characters length
    var isPasswordValid: Bool {
        let count = count >= 8
        let uppercase = lowercased() != self
        let lowercase = uppercased() != self
        let digits = rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        
        return digits && lowercase && uppercase && count
    }
    
    func showSecure(_ isShow: Bool) -> String {
        return isShow ? self : String(repeating: "*", count: self.count)
    }
    
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
