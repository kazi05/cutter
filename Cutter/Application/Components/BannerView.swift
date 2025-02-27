//
//  BannerView.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.02.2024.
//

import SwiftUI
import UIKit
import YandexMobileAds

struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero

    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        return bannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        (uiViewController as? BannerViewController)?.showAd()
    }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

class BannerViewController: UIViewController, AdViewDelegate {
    private lazy var adView: AdView = {
        let width = view.safeAreaLayoutGuide.layoutFrame.width
        let adSize = BannerAdSize.stickySize(withContainerWidth: width)
        let unitId = "R-M-7339203-1"
        let adView = AdView(adUnitID: unitId, adSize: adSize)
        adView.delegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false
        return adView
    }()

    func showAd() {
        adView.displayAtBottom(in: view)
        adView.loadAd()
    }
}
