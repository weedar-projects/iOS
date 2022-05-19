//
//  DateHelper.swift
//  Weelar
//
//  Created by vtsyomenko on 23.09.2021.
//

import Foundation

class DateHelper {
    static func toDate(_ dateString:String, format: String = "dd MMM yyyy") -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = format
        if let date = dateFormatterGet.date(from: dateString) {
             return dateFormatterPrint.string(from: date)
        }
        return nil
    }
}
