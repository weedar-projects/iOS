//
//  FontStyles.swift
//  Weelar
//
//  Created by AnyMac Store on 15.09.2021.
//

import SwiftUI

extension Font {
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }

    /// Create a font with the title text style.
    public static var title: Font {
        return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom("CoreSansC-35Light", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
    }

    /// Create a font with the body text style.
    public static var body: Font {
           return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
       }

    /// Create a font with the callout text style.
    public static var callout: Font {
           return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
       }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
           return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
       }

    /// Create a font with the caption text style.
    public static var caption: Font {
           return Font.custom("CoreSansC-45Regular", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
       }

    public static func system(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        var font = "CoreSansC-45Regular"
        switch weight {
        case .bold: font = "CoreSansC-65Bold"
        case .heavy: font = "CoreSansC-75ExtraBold"
        case .light: font = "CoreSansC-35Light"
        case .medium: font = "CoreSansC-45Regular"
        case .semibold: font = "CoreSansC-55Medium"
        case .thin: font = "CoreSansC-15Thin"
        case .ultraLight: font = "CoreSansC-25ExtraLight"
        default: break
        }
        return Font.custom(font, size: size)
    }
}
