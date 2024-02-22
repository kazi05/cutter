//
//  UIKScrollView.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import SwiftUI
import UIKit

struct UIKScrollView<Content:View>: UIViewRepresentable {
    
    private let axis: Axis.Set
    private let contentSize: CGSize
    private let showsIndicators: Bool
    private let contentOffset: CGPoint?
    private let contentInset: UIEdgeInsets

    private var _onIsScrolling: ((Bool) -> Void)?
    private var _onOffsetChanged: ((CGPoint) -> Void)?

    @ViewBuilder private let content: () -> Content
    
    init(
        _ axis: Axis.Set = .vertical,
        contentSize: CGSize,
        showsIndicators: Bool = true,
        contentOffset: CGPoint? = nil,
        contentInset: UIEdgeInsets = .zero,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.contentSize = contentSize
        self.showsIndicators = showsIndicators
        self.contentOffset = contentOffset
        self.contentInset = contentInset
        self.content = content
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsHorizontalScrollIndicator = showsIndicators
        scrollView.showsVerticalScrollIndicator = showsIndicators
        scrollView.alwaysBounceVertical = axis == .vertical
        scrollView.alwaysBounceHorizontal = axis == .horizontal
        scrollView.contentInset = contentInset
        
        let hostingController = UIHostingController(rootView: content())
        context.coordinator.hostingController = hostingController
        let contentView = hostingController.view ?? UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content()
        uiView.contentSize = contentSize
        context.coordinator.hostingController?.view.frame = CGRect(
            origin: .zero,
            size: contentSize
        )
        if let contentOffset, !context.coordinator.isScrolling {
            uiView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onIsScrolling: _onIsScrolling, onOffsetChanged: _onOffsetChanged)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: UIKScrollView
        var hostingController: UIHostingController<Content>?
        
        private(set) var isScrolling = false
        private(set) var isDecelerating = false
        private var onIsScrolling: ((Bool) -> Void)?
        private var onOffsetChanged: ((CGPoint) -> Void)?

        init(_ parent: UIKScrollView, onIsScrolling: ((Bool) -> Void)?, onOffsetChanged: ((CGPoint) -> Void)?) {
            self.parent = parent
            self.onIsScrolling = onIsScrolling
            self.onOffsetChanged = onOffsetChanged
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            if !isScrolling {
                isScrolling = true
                onIsScrolling?(true)
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard isScrolling else { return }
            let contentOffset = scrollView.contentOffset
            let contentInset = scrollView.contentInset
            onOffsetChanged?(
                .init(
                    x: contentOffset.x + contentInset.left,
                    y: contentOffset.y + contentInset.top
                )
            )
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isDecelerating = false
            if isScrolling {
                isScrolling = false
                onIsScrolling?(false)
            }
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            isDecelerating = decelerate
            if !decelerate {
                if isScrolling {
                    isScrolling = false
                    onIsScrolling?(false)
                }
            }
        }
    }
}

extension UIKScrollView {
    func onIsScrolling(_ handler: @escaping (Bool) -> Void) -> Self {
        var copy = self
        copy._onIsScrolling = handler
        return copy
    }

    func onOffsetChanged(_ handler: @escaping (CGPoint) -> Void) -> Self {
        var copy = self
        copy._onOffsetChanged = handler
        return copy
    }
}
