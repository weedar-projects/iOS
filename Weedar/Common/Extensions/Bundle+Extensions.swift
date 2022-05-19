//
//  Bundle+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 15.09.2021.
//

import UIKit

let appLanguageKey: String = "appLanguage"

var appLanguageValue: String {
    return UserDefaults.standard.string(forKey: appLanguageKey) ?? Locale.current.languageCode ?? "en"
}

extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let path = Bundle.main.path(forResource: appLanguageValue, ofType: "lproj") ?? ""
            bundle = Bundle(path: path)
        }

        return bundle
    }

    public static func set(language: String) {
        UserDefaults.standard.set(language, forKey: appLanguageKey)
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}
