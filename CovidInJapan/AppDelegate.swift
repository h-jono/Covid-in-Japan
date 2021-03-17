//
//  AppDelegate.swift
//  CovidInJapan
//
//  Created by 城野 on 2021/03/13.
//

import UIKit
import Firebase
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        CovidAPI.getPrefecture(completion: {(result: [CovidInfo.Prefecture]) -> Void in
            CovidSingleton.shared.prefecture = result
        })
        
        return true
    }

}

