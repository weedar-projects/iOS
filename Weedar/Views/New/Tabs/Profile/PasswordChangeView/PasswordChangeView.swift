//
//  PasswordChangeView.swift
//  Weelar
//
//  Created by vtsyomenko on 30.08.2021.
//

import SwiftUI
import Amplitude

// MARK: - PasswordChangeView
struct PasswordChangeView: View {
    // MARK: - Properties
    @State var loadingIndicatorShow: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    
    // MARK: - View
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                
            PasswordChangeContent(loadingIndicatorShow: $loadingIndicatorShow)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
            }
            
          
        } // VStack
        .navBarSettings("Change password")
        .onTapGesture {
            hideKeyboard()
        }
    } // body
}


// MARK: - PasswordChangeContent
struct PasswordChangeContent: View {
    // MARK: - Properties
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel = PasswordChangeViewModel()
    
    @Binding var loadingIndicatorShow: Bool
    
    var isEmptyFields: Bool {
        return passwordNew.isEmpty || passwordCurrent.isEmpty || self.passwordRepeat.isEmpty
    }
        
    // Password Current
    @State private var passwordCurrent: String = "" {
        didSet {
            passwordCurrentBGColor = ColorManager.Catalog.Category.vapeColor
            isPasswordCurrentRegexWrong = false
        }
    }

    @State private var isPasswordCurrentChange = false
    @State private var isPasswordCurrentRegexWrong = false
    @State private var passwordCurrentBGColor = Color.lightSecondaryE.opacity(0.1)
    @State private var isPasswordCurrentSecureTextEntry = true
    @State private var isPasswordCurrentTextFieldFirstResponder = false
        
    enum PasswordError: CaseIterable {
        case charactersCount
        case oneUppercaseLetter
        case oneDigit
        case oneLowercaseLetter
    }
    
    
    func validatePassword(_ password: String) {
        var errors = [PasswordError]()
        
        switch password {
            case "": errors = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
            case let password where password.range(of: PasswordError.oneLowercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneLowercaseLetter)
                fallthrough
            case let password where password.range(of: PasswordError.oneDigit.pattern, options: .regularExpression) == nil:
                errors.append(.oneDigit)
                fallthrough
            case let password where password.range(of: PasswordError.oneUppercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneUppercaseLetter)
                fallthrough
                
            default:
                if password.trimmingCharacters(in: .whitespaces
                ).count < 8 {
                    errors.append(.charactersCount)
                }
        }
        self.errors = errors
    }
    
    private var passwordCurrentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            HStack {
                Text("passwordchangeview.change_password_current_password_title".localized)
                    .lineLimit(0)
                    .lineSpacing(2.8)
                    .modifier(
                        TextModifier(font: .coreSansC45Regular,
                                     size: 14,
                                     foregroundColor: .black,
                                     opacity: 0.7)
                    )

                Spacer()
            }
            .padding(.top, 26)
            .padding(.horizontal, 16)
            .background(Color.white)
            
            // Password TextField
            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    if isPasswordCurrentSecureTextEntry {
                        PasswordTextFieldWrapper(text: $passwordCurrent,
                                                 isSecureTextEntry: .constant(true),
                                                 becomeFirstResponder: $isPasswordCurrentTextFieldFirstResponder,
                                                 placeholder: "passwordchangeview.change_password_current_password_placeholder".localized)
                    } else {
                        PasswordTextFieldWrapper(text: $passwordCurrent,
                                                 isSecureTextEntry: .constant(false),
                                                 becomeFirstResponder: .constant(true),
                                                 placeholder: "passwordchangeview.change_password_current_password_placeholder".localized)
                    }
                }
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)

                // Hide/show password
                Button(action: {
                    isPasswordCurrentSecureTextEntry.toggle()
                }) {
                    Image(isPasswordCurrentSecureTextEntry ? "welcome-content-eye-splash" : "welcome-content-eye")
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(.lightOnSurfaceB)
                }
                
                
            } // HStack (Password TextField)
            .modifier(
                TextFieldModifier(cornerRadius: 12,
                                  borderWidth: 2,
                                  height: 48,
                                  borderColor: $passwordCurrentBGColor,
                                  font: .coreSansC45Regular,
                                  size: 16,
                                  textAlignment: .leading)
            )
            
            if isPasswordCurrentRegexWrong {
                Text("passwordchangeview.change_password_current_password_error".localized)
                    .foregroundColor(.red)
                    .lineLimit(3)
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14))

            }
        } // VStack
    }
    
    // New Password
    @State private var passwordNew: String = "" {
        didSet {
            passwordNewBGColor = Color.lightSecondaryE.opacity(0.1)
            isPasswordNewRegexWrong = false
        }
    }
    
    @State private var isPasswordNewMatch: Bool = false
    @State private var isPasswordNewRegexWrong = false
    @State private var passwordNewBGColor = Color.lightSecondaryE.opacity(0.1)
    @State private var isPasswordNewSecureTextEntry = true
    @State private var isPasswordNewTextFieldFirstResponder = false

    @State var errors: [PasswordError] = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
    
    private var passwordNewView: some View {
        VStack(alignment: .leading, spacing: 4)
        {
            // Title
            HStack {
                Text("passwordchangeview.change_password_new_password_title".localized)
                    .lineLimit(0)
                    .lineSpacing(2.8)
                    .modifier(
                        TextModifier(font: .coreSansC45Regular,
                                     size: 14,
                                     foregroundColor: .black,
                                     opacity: 0.7)
                    )

                Spacer()
            }
            .padding(.top, 26)
            .padding(.horizontal, 16)
            .background(Color.white)
            
            // Password TextField
            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    if isPasswordNewSecureTextEntry {
                        PasswordTextFieldWrapper(text: $passwordNew,
                                                 isSecureTextEntry: .constant(true),
                                                 becomeFirstResponder: $isPasswordNewTextFieldFirstResponder,
                                                 placeholder: "passwordchangeview.change_password_new_password_placeholder".localized)
                    } else {
                        PasswordTextFieldWrapper(text: $passwordNew,
                                                 isSecureTextEntry: .constant(false),
                                                 becomeFirstResponder: .constant(true),
                                                 placeholder: "passwordchangeview.change_password_new_password_placeholder".localized)
                    }
                }
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)

                // Hide/show password
                Button(action: {
                    isPasswordNewSecureTextEntry.toggle()
                }) {
                    Image(isPasswordNewSecureTextEntry ? "welcome-content-eye-splash" : "welcome-content-eye")
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(.lightOnSurfaceB)
                }
            } // HStack (Password TextField)
            .modifier(
                TextFieldModifier(cornerRadius: 12,
                                  borderWidth: 2,
                                  height: 48,
                                  borderColor: $passwordNewBGColor,
                                  font: .coreSansC45Regular,
                                  size: 16,
                                  textAlignment: .leading)
            )
            .onChange(of: passwordNew) { newValue in
                validatePassword(newValue)
            }
            if !passwordNew.isEmpty{
                //passowrdError stack
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()), GridItem(.flexible())
                    ],
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [],
                    content: {
                        ForEach(PasswordChangeContent.PasswordError.allCases, id:\.self) { item in
                            errorStackMessage(for: item, isChecked: !errors.contains(item))
                        }
                    })
                    .animation(.linear, value: passwordNew.isEmpty)
                    
                    .padding(.top, 8)
            }
            
            
            // Error
            
            
        } // VStack
    }

    // Repeat Password
    @State private var passwordRepeat: String = "" {
        didSet {
            passwordRepeatBGColor = Color.lightSecondaryE.opacity(0.1)
            isPasswordRepeatRegexWrong = false
        }
    }
    
    @State private var isPasswordRepeatRegexWrong = false
    @State private var passwordRepeatBGColor = Color.lightSecondaryE.opacity(0.1)
    @State private var isPasswordRepeatSecureTextEntry = true
    @State private var isPasswordRepeatTextFieldFirstResponder = false

    private var passwordRepeatView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            HStack {
                Text("passwordchangeview.change_password_repeat_new_password_title".localized)
                    .lineLimit(0)
                    .lineSpacing(2.8)
                    .modifier(
                        TextModifier(font: .coreSansC45Regular,
                                     size: 14,
                                     foregroundColor: .black,
                                     opacity: 0.7)
                    )

                Spacer()
            }
            .padding(.top, 26)
            .padding(.horizontal, 16)
            .background(Color.white)
            
            // Password TextField
            HStack(alignment: .center, spacing: 8) {
                ZStack {
                    if isPasswordRepeatSecureTextEntry {
                        PasswordTextFieldWrapper(text: $passwordRepeat,
                                                 isSecureTextEntry: .constant(true),
                                                 becomeFirstResponder: $isPasswordRepeatTextFieldFirstResponder,
                                                 placeholder: "passwordchangeview.change_password_repeat_new_password_placeholder".localized)
                    } else {
                        PasswordTextFieldWrapper(text: $passwordRepeat,
                                                 isSecureTextEntry: .constant(false),
                                                 becomeFirstResponder: .constant(true),
                                                 placeholder: "passwordchangeview.change_password_repeat_new_password_placeholder".localized)
                    }
                }
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)

                // Hide/show password
                Button(action: {
                    isPasswordRepeatSecureTextEntry.toggle()
                }) {
                    Image(isPasswordRepeatSecureTextEntry ? "welcome-content-eye-splash" : "welcome-content-eye")
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(.lightOnSurfaceB)
                }
            } // HStack (Password TextField)
            .modifier(
                TextFieldModifier(cornerRadius: 12,
                                  borderWidth: 2,
                                  height: 48,
                                  borderColor: $passwordNewBGColor,
                                  font: .coreSansC45Regular,
                                  size: 16,
                                  textAlignment: .leading)
            )
            
            // Error
            VStack(alignment:.leading) {
                if isPasswordNewRegexWrong {
                    Text("passwordchangeview.change_password_repeat_new_password_error_regex".localized)
                        .foregroundColor(.red)
                        .lineLimit(3)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.leading)

                }
            
                if isPasswordNewMatch {
                    Text("passwordchangeview.change_password_repeat_new_password_error_match".localized)
                        .foregroundColor(.red)
                        .lineLimit(3)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 14))

                }
            } // VStack (Error)
        } // VStack
    }

    
    // MARK: - View
    var body: some View {
        VStack(alignment:.leading) {
            // Current Password
            passwordCurrentView
            
            // New Password
            passwordNewView
            
            // Repeat New Password
            passwordRepeatView
            
            Spacer()
            
            DefaultButton(text: "Save", isDisabled: isEmptyFields, action: {
                hideKeyboard()
                
                guard
                    passwordNew == passwordRepeat
                else {
                    isPasswordNewMatch = false
                    passwordRepeatBGColor = .red
                    passwordNewBGColor = .red
                    return
                }
                
                isPasswordNewMatch = true
                
                guard
                    passwordNew.isPasswordValid
                else {
                    passwordNewBGColor = .red
                    isPasswordNewRegexWrong = true
                    return
                }
                
                loadingIndicatorShow = true
                
                viewModel.changePassword(passwordCurrent, newPassword: passwordNew) { isSuccess in
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){

                    Amplitude.instance().logEvent("change_pass_success")
                    }
                    isPasswordCurrentChange = isSuccess
                    isPasswordCurrentRegexWrong = !isSuccess
                }
            })
                .padding(.top)
                .padding(.bottom, 24)
                .alert(isPresented: $isPasswordCurrentChange, content: {
                    Alert(title: Text("Congratulations!"),
                          message: Text("Your password is successfully changed."),
                          dismissButton: .default(Text("Okay"),
                                                  action: {
                        isPasswordCurrentChange = false
                        presentationMode.wrappedValue.dismiss()
                    }))
                })
        } // VStack
        .onTapGesture {
            hideKeyboard()
        }
    } // body
    
    @ViewBuilder
    func errorStackMessage(for error: PasswordChangeContent.PasswordError, isChecked: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isChecked ? "checkmark" : "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(isChecked ? .lightSecondaryF : .red)
            Text(error.errorMessage.localized)
                .modifier(
                    TextModifier(font: .coreSansC45Regular,
                                 size: 14,
                                 foregroundColor: isChecked ? .lightSecondaryF : .lightSecondaryB,
                                 opacity: 1.0)
                )
        }
        .padding(.bottom, 10)
    }
}

extension PasswordChangeContent.PasswordError {
    var errorMessage: String {
        switch self {
            case .charactersCount: return "Eight characters"
            case .oneDigit: return "One digit"
            case .oneLowercaseLetter: return "One lowercase letter"
            case .oneUppercaseLetter: return "One uppercase letter"
        }
    }
    
    var pattern: String {
        switch self {
            case .oneUppercaseLetter: return #"(?=.*[A-Z])"#
            case .oneDigit: return #"(?=.*\d)"#
            case .oneLowercaseLetter: return #"(?=.*[a-z])"#
            case .charactersCount: return #"(?=.{8,})"#
        }
    }
}


class PasswordChangeViewModel: ObservableObject {
    func changePassword(_ oldPassword: String,
                        newPassword: String,
                        finished: @escaping (Bool)->Void) {
        UserRepository.shared.updatePassword(oldPassword, newPassword: newPassword) { result in
            switch result {
            case .success(_):
                finished(true)
            case .failure(let error):
                Amplitude.instance().logEvent("change_pass_success", withEventProperties: ["error_type" : error.localizedDescription])
                finished(false)
            }
        }
    }
}
