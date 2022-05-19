//
//  ArrayExtension.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 13.08.2021.
//

extension Array {
    mutating func mapInPlace(_ transform: (Element) -> Element) {
        self = map(transform)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension Int {
    var orderState: OrderState? {
        switch self {
        case 1...4:
                return .processing
        case 5:
            return .packing
        case 6:
            return .inDelivery
        case 7...8:
            return nil
        case 10:
            return .canceled
        default:
            return nil
        }
    }
}
