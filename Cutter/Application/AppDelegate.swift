//
//  AppDelegate.swift
//  Cutter
//
//  Created by Гаджиев Казим on 19.02.2024.
//

import UIKit
import AVFAudio
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            print("AVAudioSessionCategoryPlayback not work")
        }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        VideoOutputFileManager.shared.deleteFiles()
    }
}
