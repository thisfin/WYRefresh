//
//  UIScrollView+Pull.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

extension UIScrollView {
    private static let pullViewAssociated = WYObjectAssociation<WYPullView>.init()
    private(set) var pullView: WYPullView? {
        get {
            return UIScrollView.pullViewAssociated[self]
        }
        set {
            willChangeValue(forKey: "WYPullView")
            UIScrollView.pullViewAssociated[self] = newValue
            didChangeValue(forKey: "WYPullView")
        }
    }

    var showsPull: Bool? {
        get {
            if let pullView = pullView {
                return !pullView.isHidden
            }
            return nil
        }
        set {
            if let pullView = pullView, let showsPull = newValue {
                pullView.isHidden = !showsPull
                if !showsPull {
                    if pullView.isObserving {
                        removeObserver(pullView, forKeyPath: "contentOffset")
                        removeObserver(pullView, forKeyPath: "contentSize")
                        removeObserver(pullView, forKeyPath: "frame")
                        pullView.resetScrollViewContentInset()
                        pullView.isObserving = false
                    }
                } else {
                    if !pullView.isObserving {
                        addObserver(pullView, forKeyPath: "contentOffset", options: .new, context: nil)
                        addObserver(pullView, forKeyPath: "contentSize", options: .new, context: nil)
                        addObserver(pullView, forKeyPath: "frame", options: .new, context: nil)
                        pullView.isObserving = true

                        var yOrigin: CGFloat = 0
                        switch pullView.position {
                        case .top:
                            yOrigin = 0 - WYPullView.viewHeight
                            break
                        case .bottom:
                            yOrigin = contentSize.height
                            break
                        }
                        pullView.frame = CGRect(x: 0, y: yOrigin, width: bounds.width, height: WYPullView.viewHeight)
                    }
                }
            }
        }
    }

    func addPullToRefreshWithActionHandler(position: WYRefreshPosition = .top, actionHandler: @escaping () -> Void) {
        if pullView == nil {
            var yOrigin: CGFloat = 0
            switch position {
            case .top:
                yOrigin = 0 - WYPullView.viewHeight
            case .bottom:
                yOrigin = contentSize.height
            }

            let view = WYPullView(frame: CGRect(x: 0, y: yOrigin, width: bounds.size.width, height: WYPullView.viewHeight))
            view.pullToRefreshActionHandler = actionHandler
            view.scrollView = self
            addSubview(view)

            view.originalTopInset = contentInset.top
            view.originalBottomInset = contentInset.bottom
            view.position = position
            pullView = view
            showsPull = true
        }
    }

    func triggerPullToRefresh() {
        if let pullView = pullView {
            pullView.state = .triggered
            pullView.startAnimating()
        }
    }
}
