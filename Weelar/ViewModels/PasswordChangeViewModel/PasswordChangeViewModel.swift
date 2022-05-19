//
//  PasswordChangeViewModel.swift
//  Weelar
//
//  Created by vtsyomenko on 30.08.2021.
//

import Foundation

class PasswordChangeViewModel: ObservableObject {
    func changePassword(_ oldPassword: String,
                        newPassword: String,
                        finished: @escaping (Bool)->Void) {
        UserRepository.shared.updatePassword(oldPassword, newPassword: newPassword) { result in
            switch result {
            case .success(_):
                finished(true)
            case .failure(_):
                finished(false)
            }
        }
    }
}
