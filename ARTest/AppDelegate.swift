//
//  AppDelegate.swift
//  ARTest
//
//  Created by Vadym F on 21.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }
}

