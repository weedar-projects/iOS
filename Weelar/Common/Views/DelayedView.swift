//
//  LoadingView.swift
//  Weelar
//
//  Created by Galym Anuarbek on 03.11.2021.
//

import SwiftUI

protocol DelayedViewProtocol: View {
    
    associatedtype ContentView: View
   
    associatedtype LoaderView: View
    
    var showLoader: Bool { get set }
    
    var content: ContentView { get }
    
    var loader: LoaderView { get }
    
    func loadContentData()
}

extension DelayedViewProtocol {

    @ViewBuilder
    var body: some View {
        if showLoader {
                self.loader
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    loadContentData()
                }
        } else {
            self.content
        }
    }
}
