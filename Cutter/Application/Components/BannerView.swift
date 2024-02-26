//
//  BannerView.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.02.2024.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
    private let adUnitID = "ca-app-pub-6480251473919291/1805335404"

    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerViewController.view.addSubview(bannerView)
        bannerView.load(GADRequest())
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(
                equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
        ])
        bannerViewController.delegate = context.coordinator

        return bannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }

        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate {
        let parent: BannerView

        init(_ parent: BannerView) {
            self.parent = parent
        }

        // MARK: - BannerViewControllerWidthDelegate methods

        func bannerViewController(
            _ bannerViewController: BannerViewController, didUpdate width: CGFloat
        ) {
            parent.viewWidth = width
        }

        // MARK: - GADBannerViewDelegate methods

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("DID NOT RECEIVE AD: \(error.localizedDescription)")
        }
    }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

class BannerViewController: UIViewController {

    weak var delegate: BannerViewControllerWidthDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        delegate?.bannerViewController(
            self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.delegate?.bannerViewController(
                self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size.width)
        }
    }
}
