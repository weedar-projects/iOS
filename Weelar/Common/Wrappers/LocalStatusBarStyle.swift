//
//  LocalStatusBarStyle.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 05.10.2021.
//

import SwiftUI

class LocalStatusBarStyle {
    fileprivate var getter: () -> UIStatusBarStyle = { .default }
    fileprivate var setter: (UIStatusBarStyle) -> Void = {_ in}

    var currentStyle: UIStatusBarStyle {
        get { self.getter() }
        set { self.setter(newValue) }
    }
}

struct LocalStatusBarStyleKey: EnvironmentKey {
    static let defaultValue: LocalStatusBarStyle = LocalStatusBarStyle()
}

extension EnvironmentValues {
    var localStatusBarStyle: LocalStatusBarStyle {
        get {
            return self[LocalStatusBarStyleKey.self]
        }
    }
}

class MyHostingController<Content>: UIHostingController<Content> where Content: View {
    private var internalStyle = UIStatusBarStyle.default

    @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            internalStyle
        }
        set {
            internalStyle = newValue
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override init(rootView: Content) {
        super.init(rootView:rootView)

        LocalStatusBarStyleKey.defaultValue.getter = { self.preferredStatusBarStyle }
        LocalStatusBarStyleKey.defaultValue.setter = { self.preferredStatusBarStyle = $0 }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
