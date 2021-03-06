//
//  URL+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 07.10.2021.
//

import Foundation

extension URL {
    mutating func appendQueryItem(name: String, value: String?) {
        guard
            var urlComponents = URLComponents(string: absoluteString)
        else {
            return
        }

        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        queryItems.append(URLQueryItem(name: name, value: value))

        urlComponents.queryItems = queryItems

        self = urlComponents.url!
    }
}
