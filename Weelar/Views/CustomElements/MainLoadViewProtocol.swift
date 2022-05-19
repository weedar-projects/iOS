//
//  MainLoadViewProtocol.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI

protocol MainLoadViewProtocol: View {
    
    associatedtype ContentView: View
   
    associatedtype LoaderView: View
    
    var showLoader: Bool { get set }
    
    var content: ContentView { get }
    
    var loader: LoaderView { get }   
}

extension MainLoadViewProtocol {

    @ViewBuilder
    var body: some View {
        if showLoader {
                self.loader
                .edgesIgnoringSafeArea(.all)
        } else {
            self.content
        }
    }
}
