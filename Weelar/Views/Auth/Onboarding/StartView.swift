//
//  WelcomeView.swift
//  Weelar
//

import SwiftUI
import Amplitude

struct StartView: View {

    // MARK: - Properties
    let title: String
    let subTitle: String
    let description: String?
    let leaveButtonTitle: String
    let enterButtonTitle: String
    let isLastViewForConfirmation: Bool

    @Binding var showOnboardingSecondView: Bool
    @Binding var showOnboarding: Bool
    
    @StateObject private var viewModel = StartViewModel()
    @State var screenSize = CGSize.zero
    @State private var isPresentedLocationView = false
    @State private var noTapped = false

    @Environment(\.openURL) var openURL

    // MARK: - View
    var body: some View {
        ZStack(alignment: .top) {

            // background color and image with lines
            ZStack(alignment: .top) {
                Color.lightOnSurfaceB
                    .ignoresSafeArea()

                Image("splash-background-lines")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .top)
                    .opacity(0.6)
            }

            // UI's elements
            VStack(spacing: 10) {
                VStack(spacing: 25) {
                    Image("logo_new")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 0.45 * UIScreen.main.bounds.width)

                    Text(title)
                        .multilineTextAlignment(.center)
                        .modifier(TextModifier(font: .coreSansC65Bold, size: 45, foregroundColor: .lightOnSurfaceA, opacity: 1.0))
                        .lineSpacing(8)
                        .minimumScaleFactor(0.1)

                    Text(subTitle)
                        .modifier(TextModifier(font: .coreSansC45Regular, size: 20, foregroundColor: .lightOnSurfaceA, opacity: 0.6))
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.1)

                    if let description = description {
                        Text(description)
                            .modifier(TextModifier(font: .coreSansC65Bold, size: 18, foregroundColor: .lightOnSurfaceA, opacity: 0.9))
                            .lineSpacing(8)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.1)
                    }
                } // VStack (Logo, title & subtitle)
                .padding(.top, UIScreen.main.bounds.height / 6)
                Spacer()
                HStack(spacing: 12) {
                    DefaultButton(text: leaveButtonTitle, style: .secondary,
                                  action: {
                        noTapped = true
                    })
                        .alert(isPresented: $noTapped, content: {
                            Alert(title: Text("Dear customer,"),
                                  message: Text("startview.open_weel_site_alert_description".localized),
                                  primaryButton: .cancel(Text("Cancel")),
                                  secondaryButton: .destructive(Text("Go to site"),
                                                                action: {
                                if let url = URL(string: "https://cannabis.ca.gov/consumers/whats-legal") {
                                    openURL(url)
                                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                    Amplitude.instance().logEvent("site_age_alert")
                                    }
                            }
                        }))
                    })
                    DefaultButton(text: enterButtonTitle,
                                  action: {
                        if isLastViewForConfirmation {
                            print("hide root")
                            showOnboarding = false
                            UserDefaultsService().set(value: false, forKey: .showOnboarding)
                        }else{
                            print("second root")
                            showOnboardingSecondView = true
                        }
                        
                    })
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}


