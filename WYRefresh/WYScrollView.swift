//
//  WYScrollView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/27.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class WYScrollView: UIScrollView {
    var refreshView: WYRefreshView?

    var showsPullToRefresh: Bool {
        get {
            guard let refreshView = refreshView else {
                return false
            }
            return !refreshView.isHidden
        }
        set {
            guard let refreshView = refreshView else {
                return
            }

            refreshView.isHidden = !newValue
            if !newValue {
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
                        yOrigin = 0 - WYRefreshView.wyRefreshViewHeight
                        break
                    case .bottom:
                        yOrigin = contentSize.height
                        break
                    }
                    refreshView.frame = CGRect(x: 0, y: yOrigin, width: bounds.size.width, height: WYRefreshView.wyRefreshViewHeight)
                }
            }
        }
    }

    func addPullToRefreshWithActionHandler(position: WYRefreshPosition = .top, actionHandler: @escaping SimpleBlockNoneParameter) {
        if refreshView == nil {
            var yOrigin: CGFloat = 0
            switch position {
            case .top:
                yOrigin = 0 - WYRefreshView.wyRefreshViewHeight
            case .bottom:
                yOrigin = contentSize.height
            }

            let view = WYRefreshView(frame: CGRect(x: 0, y: yOrigin, width: bounds.size.width, height: WYRefreshView.wyRefreshViewHeight))
            view.pullToRefreshActionHandler = actionHandler
            view.scrollView = self
            addSubview(view)

            view.originalTopInset = contentInset.top
            view.originalBottomInset = contentInset.bottom
            view.position = position
            refreshView = view
            showsPullToRefresh = true
        }
    }

    func triggerPullToRefresh() {
        refreshView?.state = .triggered
        refreshView?.startAnimating()
    }
}