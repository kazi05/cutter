//
//  AdCoordinator.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.02.2024.
//

import YandexMobileAds

final class AdCoordinator: NSObject {
    private lazy var interstitialAdLoader: InterstitialAdLoader = {
        let loader = InterstitialAdLoader()
        loader.delegate = self
        return loader
    }()
    private var interstitialAd: InterstitialAd?

    static let shared = AdCoordinator()

    func loadAd() {
        let unitId = "R-M-7339203-2"
        let configuration = AdRequestConfiguration(adUnitID: unitId)
        interstitialAdLoader.loadAd(with: configuration)
    }

    private func showAd() {
        if let viewController = UIApplication.shared.firstKeyWindow?.rootViewController {
            interstitialAd?.show(from: viewController)
        }
    }
}

extension AdCoordinator: InterstitialAdLoaderDelegate {
    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didLoad interstitialAd: YandexMobileAds.InterstitialAd) {
        self.interstitialAd = interstitialAd
        showAd()
    }
    
    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
        print(error.error.localizedDescription)
    }
}
