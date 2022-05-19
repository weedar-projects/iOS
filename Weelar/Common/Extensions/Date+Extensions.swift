//
//  Date+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 15.09.2021.
//

import Foundation

extension Date {
    func convertToString(byCalendarIdentifier calendarIdentifier: Calendar.Identifier = .gregorian, dateFormat: DateFormatType = .normal) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: appLanguageValue)
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: self)
    }

    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
