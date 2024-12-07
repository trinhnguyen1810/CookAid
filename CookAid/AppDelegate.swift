//
//  AppDelegate.swift
//  CookAid
//
//  Created by Vivian Nguyen on 12/6/24.
//

import UIKit
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Initialize Firebase
        return true
    }
}
