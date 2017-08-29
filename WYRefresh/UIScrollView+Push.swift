//
//  UIScrollView+Push.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

extension UIScrollView {
    private static let pushViewAssociated = WYObjectAssociation<WYPushView>.init()
    private(set) var pushView: WYPushView? {
        get {
            return UIScrollView.pushViewAssociated[self]
        }
        set {
            willChangeValue(forKey: "WYPushView")
            UIScrollView.pushViewAssociated[self] = newValue
            didChangeValue(forKey: "WYPushView")
        }
    }

    var showsPush: Bool? {
        get {
            if let pushView = pushView {
                return !pushView.isHidden
            }
            return nil
        }
        set {
            if let pushView = pushView, let showsPush = newValue {
                pushView.isHidden = !showsPush
                if !showsPush {
                    if pushView.isObserving {
                        removeObserver(pushView, forKeyPath: "contentOffset")
                        removeObserver(pushView, forKeyPath: "contentSize")
                        pushView.resetScrollViewContentInset()
                        pushView.isObserving = false
                    }
                } else {
                    if !pushView.isObserving {
                        addObserver(pushView, forKeyPath: "contentOffset", options: .new, context: nil)
                        addObserver(pushView, forKeyPath: "contentSize", options: .new, context: nil)
                        pushView.setScrollViewContentInsetForInfiniteScrolling()
                        pushView.isObserving = true
                        pushView.setNeedsLayout()
                        pushView.frame = CGRect.init(x: 0, y: contentSize.height, width: pushView.bounds.width, height: WYPushView.viewHeight)
                    }
                }
            }
        }
    }

    func addPushWithActionHandler(actionHandler: @escaping () -> Void) {
        if pushView == nil {
            pushView = {
                let view = WYPushView.init(frame: CGRect.init(x: 0, y: contentSize.height, width: bounds.width, height: WYPushView.viewHeight))
                view.pushHandler = actionHandler
                view.scrollView = self
                view.originalBottomInset = contentInset.bottom
                return view
            }()
            addSubview(pushView!)
            showsPush = true
        }
    }

    func triggerInfiniteScrolling() {
        if let pushView = pushView {
            pushView.state = .triggered
            pushView.startAnimating()
        }
    }
}
