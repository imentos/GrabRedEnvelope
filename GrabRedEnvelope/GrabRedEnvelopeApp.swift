//
//  GrabRedEnvelopeApp.swift
//  GrabRedEnvelope
//
//  Created by Kuo, Ray on 2/18/26.
//

import SwiftUI

// AppDelegate to control orientation
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct GrabRedEnvelopeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
