//
//  UIScrollView+Refresh.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

extension UIScrollView {
    private static let refreshViewAssociated = WYObjectAssociation<WYRefreshView>.init()
    private(set) var refreshView: WYRefreshView? {
        get {
            return UIScrollView.refreshViewAssociated[self]
        }
        set {
            willChangeValue(forKey: "WYRefreshView")
            UIScrollView.refreshViewAssociated[self] = newValue
            didChangeValue(forKey: "WYRefreshView")
        }
    }

    var showsRefresh: Bool? {
        get {
            if let refreshView = refreshView {
                return !refreshView.isHidden
            }
            return nil
        }
        set {
            if let refreshView = refreshView, let showsRefresh = newValue {
                refreshView.isHidden = !showsRefresh
                if !showsRefresh {
                    if refreshView.isObserving {
                        removeObserver(refreshView, forKeyPath: "contentOffset")
                        removeObserver(refreshView, forKeyPath: "contentSize")
                        removeObserver(refreshView, forKeyPath: "frame")
                        refreshView.resetScrollViewContentInset()
                        refreshView.isObserving = false
                    }
                } else {
                    if !refreshView.isObserving {
                        addObserver(refreshView, forKeyPath: "contentOffset", options: .new, context: nil)
                        addObserver(refreshView, forKeyPath: "contentSize", options: .new, context: nil)
                        addObserver(refreshView, forKeyPath: "frame", options: .new, context: nil)
                        refreshView.isObserving = true

                        var yOrigin: CGFloat = 0
                        switch refreshView.position {
                        case .top:
                            yOrigin = 0 - WYRefreshView.viewHeight
                            break
                        case .bottom:
                            yOrigin = contentSize.height
                            break
                        }
                        refreshView.frame = CGRect(x: 0, y: yOrigin, width: bounds.width, height: WYRefreshView.viewHeight)
                    }
                }
            }
        }
    }

    func addRefreshWithActionHandler(position: WYRefreshPosition = .top, actionHandler: @escaping () -> Void) {
        if refreshView == nil {
            var yOrigin: CGFloat = 0
            switch position {
            case .top:
                yOrigin = 0 - WYRefreshView.viewHeight
            case .bottom:
                yOrigin = contentSize.height
            }

            let view = WYRefreshView(frame: CGRect(x: 0, y: yOrigin, width: bounds.width, height: WYRefreshView.viewHeight))
            view.refreshHandler = actionHandler
            view.scrollView = self
            addSubview(view)

            view.originalTopInset = contentInset.top
            view.originalBottomInset = contentInset.bottom
            view.position = position
            refreshView = view
            showsRefresh = true
        }
    }

    func triggerRefresh() {
        if let refreshView = refreshView {
            refreshView.state = .triggered
            refreshView.startAnimating()
        }
    }
}
