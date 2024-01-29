//
//  ScrollDelegate.swift
//  Cutter
//
//  Created by Гаджиев Казим on 29.01.2024.
//

import SwiftUI
import UIKit
import SwiftUIIntrospect
import Combine

final class ScrollDelegate: NSObject, UITableViewDelegate, UIScrollViewDelegate {
    var isScrolling: Binding<Bool>?
    var contentOffset: Binding<CGPoint>?
    
    private var subscriptions = Set<AnyCancellable>()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let isScrolling = isScrolling?.wrappedValue,!isScrolling {
            self.isScrolling?.wrappedValue = true
        }
        contentOffset?.wrappedValue = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let isScrolling = isScrolling?.wrappedValue, isScrolling {
            self.isScrolling?.wrappedValue = false
        }
    }
    
    // When the user slowly drags the scrollable control, decelerate is false after the user releases their finger, so the scrollViewDidEndDecelerating method is not called.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let isScrolling = isScrolling?.wrappedValue, isScrolling {
                self.isScrolling?.wrappedValue = false
            }
        }
    }
}

extension View {
    func scrollStatusByIntrospect(
        isScrolling: Binding<Bool>? = nil,
        contentOffset: Binding<CGPoint>? = nil
    ) -> some View {
        modifier(
            ScrollStatusByIntrospectModifier(
                isScrolling: isScrolling ?? .constant(false),
                contentOffset: contentOffset ?? .constant(.zero)
            )
        )
    }
}

struct ScrollStatusByIntrospectModifier: ViewModifier {
    @State var delegate = ScrollDelegate()
    @Binding var isScrolling: Bool
    @Binding var contentOffset: CGPoint
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.delegate.isScrolling = $isScrolling
                self.delegate.contentOffset = $contentOffset
            }
            .introspect(.scrollView, on: .iOS(.v16, .v17), customize: { scrollView in
                scrollView.delegate = delegate
            })
    }
}
