//
//  HomeTutorialView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 05.11.2021.
//

import SwiftUI

struct Tutorial : View {
    enum Stage {
        case wait, waitToStart, hide, show, swipeLeftRight, tapChoose, swipeUp, swipeDown
    }
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @Binding var stage: Tutorial.Stage
    
    var body: some View {
        ZStack {
            switch stage {
            case .waitToStart:
                VStack{ EmptyView().onAppear() {
                    tabBarManager.show()
                } }

            case .hide:
                VStack{ EmptyView().navigationBarHidden(false).onAppear() {
                    tabBarManager.show()
                } }
            case .wait:
                VStack{ EmptyView().onAppear() {
                    tabBarManager.show()
                } }
            case .show:
                VStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Welcome to WEEDAR")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                      Text("Follow the tutorial to learn how to use AR space and interact with products")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                        HStack {
                            Spacer()
                            
                                
                           ZStack{
                                Text("Skip")
                                    .font(.system(size: 14))
                                    .padding([.trailing, .leading], 12)
                                    .padding([.bottom], 10)
                                    .padding([.top], 12)
                            }
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10.0)
                            .frame(width: 61, height: 27, alignment: .center)
                            .onTapGesture {
                                stage = .hide
                            }
                            
                            
                            
                                
                      ZStack{
                                Text("Show")
                                    .bold()
                                    .font(.system(size: 14))
                                    .padding([.trailing, .leading], 12)
                                    .padding([.bottom], 10)
                                    .padding([.top], 12)
                            }
                            .foregroundColor(.black)
//                            .background(Color.black.opacity(0.4))
                            .background(ColorManager.Buttons.buttonActiveColor)
                            .cornerRadius(10.0)
                            .onTapGesture {
                                stage = .swipeLeftRight
                            }
                            
//                            .frame(width: 61, height: 27, alignment: .center)
                            
                        }
                    }
                    .padding(24)
                    .background(Blur(style: .systemUltraThinMaterialDark))
                    .cornerRadius(16)
                    Spacer()
                }.onAppear() {
                    tabBarManager.show()
                }
            case .swipeLeftRight:
                TutorialCapsule(count: 1,
                                header: "Swipe left and right",
                                description: "Scroll the carousel to browse the menu.",
                                stage: $stage,
                                nextStage: .tapChoose
                                )
            case .tapChoose:
                TutorialCapsule(count: 2,
                                header: "Tap to select",
                                description: "Zoom in and zoom out. Enjoy 360° view.",
                                stage: $stage,
                                nextStage: .swipeUp
                                )
            case .swipeUp:
                TutorialCapsule(count: 3,
                                header: "Swipe Up",
                                description: "Check what's inside.",
                                stage: $stage,
                                nextStage: .swipeDown
                                )
            case .swipeDown:
                TutorialCapsule(count: 4,
                                header: "Swipe Down",
                                description: "Put the product back.",
                                stage: $stage,
                                nextStage: .hide
                ).onDisappear {
                    tabBarManager.show()
                }
            }
        }
    }
}

struct TutorialCapsule: View {
    let count: Int
    let header: String
    let description :String

    
    @Binding var stage: Tutorial.Stage
    let nextStage: Tutorial.Stage

    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Tutorial")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text("\(count) of 4")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { stage = .hide
                    tabBarManager.show()
                },
                       label: {
                        VStack(alignment : .center) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }.frame(width: 30, height: 30, alignment: .center)
                        .contentShape(Rectangle())
                       })
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4.0) {
                Text(header)
                    .bold()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .padding(.top, 12)
                Text(description)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                
            }
            .frame(maxWidth: .infinity)
            .padding(26)
            .background(Color.black.opacity(0.4))
            .background(Blur(style: .systemUltraThinMaterialDark))
            .cornerRadius(16)
        }
        .navigationBarHidden(true)
        .onAppear() {
//            tabBarManager.hide()
        }
    }
}
