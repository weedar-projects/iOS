//
//  FirebaseStorageHelper.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import Foundation
import Firebase

class FirebaseStorageHelper {
    
    static private let cloudStorage = Storage.storage()
    
    class func asyncDownloadToFilesystem(relativePath: String, handler: @escaping (_ fileUrl: URL) -> Void) {
        // Create local filesystem URL
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = docsUrl.appendingPathComponent(relativePath)
        
        // Check if the asset is already in the local filesystem.
        // If it is, load that asset and return.
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            handler(fileUrl)
            return
        }
        
        // Create a reference to the asset
        let storageRef = cloudStorage.reference(withPath: relativePath)
        
        // Download to the local filesystem
        storageRef.write(toFile: fileUrl) { url, error in
            guard let localUrl = url else {
                print("Firebase Storage: Error downloading file with relativePath: \(relativePath).")
                return
            }
            
            handler(localUrl)
        }.resume()
    }
}
