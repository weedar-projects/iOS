//
//  TutorialView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 27.08.2021.
//

import SwiftUI

struct TutorialPageContent {
    var background: String
    var image: String
    var header: String
    var description: String
    var page: Int
}

struct TutorialsView: View {
    @Binding var isShown: Bool
    @State var currentPage = 0
    var content = [TutorialPageContent(background: "Tutorial-Background-1",
                                       image: "Tutorial-Swipe-Horizontal",
                                       header: "Swipe left and right",
                                       description: "Check out the product from every angle possible",
                                       page: 1),
                   TutorialPageContent(background: "Tutorial-Background-2",
                                       image: "Tutorial-Swipe-Up",
                                       header: "Swipe up to open the box",
                                       description: "Get the product out of the box",
                                       page: 2),
                   TutorialPageContent(background: "Tutorial-Background-3",
                                       image: "Tutorial-Swipe-Down",
                                       header: "Swipe down to close the box",
                                       description: "Get it back where it was before",
                                       page: 3),
                   TutorialPageContent(background: "Tutorial-Background-2",
                                       image: "Tutorial-Swipe-Down",
                                       header: "Tap to put product to carousel",
                                       description: "To close detailed view",
                                       page: 4)
        ]
    

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            VStack {
                Image(content[currentPage].background)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 159, height: 336, alignment: .center)
                    .overlay(Image(content[currentPage].image)
                                .resizable()
                                .scaledToFit()
                                .padding(.bottom, -20)
                                .frame(width: 54, height: 54, alignment: .bottom))
                Text("On Detailed View")
                    .foregroundColor(ColorManager.Catalog.Item.priceColor)
                    .padding(.top, 30)
                Text(content[currentPage].header)
                    .padding(.top, 20)
                Text(content[currentPage].description)
                    .fontStyle(.body)
                    .padding(.top, 18)
                Spacer()
                HStack {
                    VStack {
                    Button(action: { isShown = false })
                        {
                            if currentPage != 3 {
                                Text("SKIP")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                    }.frame(width: 60, height: 24)
                    Spacer()
                    PageControl(current: currentPage)
                    Spacer()
                    VStack {
                    Button(action: {
                        if currentPage == 3 {
                            isShown = false
                        } else {
                            self.currentPage += 1
                        }
                    })
                    {
                        if currentPage != 3 {
                        Text("NEXT")
                            .foregroundColor(.black)
                            .bold()
                        } else {
                        Text("FINISH")
                            .foregroundColor(.black)
                            .bold()
                        }
                    }
                }.frame(width: 60, height: 24)
                }
            }.padding([.leading, .trailing], 16)
            .padding([.top], 62)
            .padding([.bottom], 24)
        }
    }
}

struct PageControl: UIViewRepresentable {
    var current = 0
    
    func makeUIView(context: Context) -> PageControl.UIViewType {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = UIColor(ColorManager.Catalog.Item.priceColor)
        page.numberOfPages = 4
        page.pageIndicatorTintColor = .gray
        return page
    }
    
    func updateUIView(_ uiView: UIPageControl, context: UIViewRepresentableContext<PageControl>)  {
        uiView.currentPage = current
    }
}
