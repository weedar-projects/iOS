//
//  FirebaseAuthManager.swift
//  Weelar
//
//  Created by Galym Anuarbek on 20.08.2021.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager: NSObject {
    static var shared = FirebaseAuthManager()
    
    private let auth: FirebaseAuth
    
    private var verificationID: String!
    
    init(with auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    func createUser(with email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let authResult = authResult {
                completion(.success(authResult.user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func signIn(with email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let authResult = authResult {
                completion(.success(authResult.user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func signIn(with credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(with: credential) { authResult, error in
            if let authResult = authResult {
                completion(.success(authResult.user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func signOut(_ completion: (Result<(), Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    func getConfirmationCode(_ phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        PhoneAuthProvider
            .provider()
            .verifyPhoneNumber(phoneNumber.replacingOccurrences(of: " ", with: ""), uiDelegate: nil) { verificationID, error in
                if let error = error {
                    completion(.failure(error))
                    return
                } else if let verificationID = verificationID {
                    self.verificationID = verificationID
                    completion(.success(verificationID))
                }
            }
        
    }
    
    func signInWith(verificationID: String?, confirmationCode: String, completion: @escaping (Result<User, Error>) -> Void) {
        let credential =
        PhoneAuthProvider
            .provider()
            .credential(withVerificationID: verificationID ?? self.verificationID!, verificationCode: confirmationCode)
        
        signIn(with: credential, completion: completion)
    }
}
