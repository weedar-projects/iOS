//
//  FirebaseAuth.swift
//  Weelar
//
//  Created by Galym Anuarbek on 20.08.2021.
//

import Foundation
import FirebaseAuth

protocol FirebaseAuth {
    func createUser(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signOut() throws
}

extension Auth: FirebaseAuth { }
