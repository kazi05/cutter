//
//  AdCoordinator.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.02.2024.
//

import GoogleMobileAds

final class AdCoordinator: NSObject {
    func presentAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-6480251473919291/3742029760", request: GADRequest()
        ) { ad, error in
            if let error = error {
                return print("Failed to load ad with error: \(error.localizedDescription)")
            }

            ad?.present(fromRootViewController: nil)
        }
    }
}
