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
    private var onIsScrolling: ((Bool) -> Void)?
    private var onOffsetChanged: ((CGPoint) -> Void)?
    
    @ViewBuilder let content: () -> Content
    
    init(
        _ axis: Axis.Set = .vertical,
        contentSize: CGSize,
        showsIndicators: Bool = true,
        contentOffset: CGPoint? = nil,
        contentInset: UIEdgeInsets = .zero,
        onIsScrolling: ((Bool) -> Void)? = nil,
        onOffsetChanged: ((CGPoint) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.contentSize = contentSize
        self.showsIndicators = showsIndicators
        self.contentOffset = contentOffset
        self.contentInset = contentInset
        self.onIsScrolling = onIsScrolling
        self.onOffsetChanged = onOffsetChanged
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
        context.coordinator.hostingController?.view.frame = CGRect(origin: .zero, size: contentSize)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: UIKScrollView
        var hostingController: UIHostingController<Content>?
        
        private var isScrolling = false
        
        init(_ parent: UIKScrollView) {
            self.parent = parent
            print("Init UIKScrollView coordinator")
        }
        
        deinit {
            print("Deinit UIKScrollView coordinator")
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if !isScrolling {
                isScrolling = true
                parent.onIsScrolling?(true)
            }
            let contentOffset = scrollView.contentOffset
            let contentInset = scrollView.contentInset
            parent.onOffsetChanged?(
                .init(
                    x: contentOffset.x + contentInset.left,
                    y: contentOffset.y + contentInset.top
                )
            )
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if isScrolling {
                isScrolling = false
                parent.onIsScrolling?(false)
            }
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                if isScrolling {
                    isScrolling = false
                    parent.onIsScrolling?(false)
                }
            }
        }
    }
}
