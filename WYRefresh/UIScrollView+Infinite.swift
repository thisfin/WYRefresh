//
//  UIScrollView+Infinite.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

extension UIScrollView {
    private static let infiniteViewAssociated = WYObjectAssociation<WYInfiniteView>()
    private(set) var infiniteView: WYInfiniteView? {
        get {
            return UIScrollView.infiniteViewAssociated[self]
        }
        set {
            willChangeValue(forKey: "WYInfiniteView")
            UIScrollView.infiniteViewAssociated[self] = newValue
            didChangeValue(forKey: "WYInfiniteView")
        }
    }

    var showsInfinite: Bool? {
        get {
            if let infiniteView = infiniteView {
                return !infiniteView.isHidden
            }
            return nil
        }
        set {
            if let infiniteView = infiniteView, let showsInfinite = newValue {
                infiniteView.isHidden = !showsInfinite
                if !showsInfinite {
                    if infiniteView.isObserving {
                        removeObserver(infiniteView, forKeyPath: "contentOffset")
                        removeObserver(infiniteView, forKeyPath: "contentSize")
                        infiniteView.resetScrollViewContentInset()
                        infiniteView.isObserving = false
                    }
                } else {
                    if !infiniteView.isObserving {
                        addObserver(infiniteView, forKeyPath: "contentOffset", options: .new, context: nil)
                        addObserver(infiniteView, forKeyPath: "contentSize", options: .new, context: nil)
                        infiniteView.setScrollViewContentInsetForInfiniteScrolling()
                        infiniteView.isObserving = true
                        infiniteView.setNeedsLayout()
                        infiniteView.frame = CGRect(x: 0, y: contentSize.height, width: infiniteView.bounds.width, height: WYInfiniteView.viewHeight)
                    }
                }
            }
        }
    }

    func addInfiniteWithActionHandler(actionHandler: @escaping () -> Void) {
        if infiniteView == nil {
            infiniteView = {
                let view = WYInfiniteView(frame: CGRect(x: 0, y: contentSize.height, width: bounds.width, height: WYInfiniteView.viewHeight))
                view.infiniteHandler = actionHandler
                view.scrollView = self
                view.originalBottomInset = contentInset.bottom
                return view
            }()
            addSubview(infiniteView!)
            showsInfinite = true
        }
    }

    func triggerInfiniteScrolling() {
        if let infiniteView = infiniteView {
            infiniteView.state = .triggered
            infiniteView.startAnimating()
        }
    }
}
