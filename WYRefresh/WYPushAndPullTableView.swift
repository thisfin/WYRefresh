//
//  PushAndPullTableView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/27.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class WYPushAndPullTableView: UITableView {
    var pullView: WYRefreshView?

    var showsPullToRefresh: Bool {
        get {
            guard let pullView = pullView else {
                return false
            }
            return !refreshView.isHidden
        }
        set {
            guard let pullView = pullView else {
                return
            }

            pullView.isHidden = !newValue
            if !newValue {
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
                        yOrigin = 0 - WYRefreshView.wyRefreshViewHeight
                        break
                    case .bottom:
                        yOrigin = contentSize.height
                        break
                    }
                    pullView.frame = CGRect(x: 0, y: yOrigin, width: bounds.size.width, height: WYRefreshView.wyRefreshViewHeight)
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
