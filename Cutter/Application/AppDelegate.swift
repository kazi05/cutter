//
//  AppDelegate.swift
//  Cutter
//
//  Created by Гаджиев Казим on 19.02.2024.
//

import UIKit
import AVFAudio

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            print("AVAudioSessionCategoryPlayback not work")
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        VideoOutputFileManager.shared.deleteFile()
    }
}
