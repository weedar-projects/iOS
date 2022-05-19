
//  StartViewModel.swift
//  Weelar
//

import Combine

class StartViewModel: ObservableObject {
    // MARK: - Properties
    @Published private var isNewUser: Bool = true
    @Published private var isUserAuthenticated: Bool = false
    @Published private var isOver21 = false

    var isNewUserAndOver21: Bool {
        return isNewUser && isOver21
    }
    
    func confirmThatOver21() {
        isOver21 = true
    }
}
