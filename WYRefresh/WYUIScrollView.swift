//
//  UIScrollView+WYInfiniteScrolling.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/16.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

extension UIScrollView {
    private struct AssociatedKeys {
        static var refreshViewName = "refreshView"
        static var showsPullToRefreshName = "showsPullToRefresh"
    }

    var refreshView: WYRefreshView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshViewName) as? WYRefreshView
        }
        set (value) {
            if let newValue = value {
                self.willChangeValue(forKey: "SVPullToRefreshView")
                objc_setAssociatedObject(self, &AssociatedKeys.refreshViewName, newValue as WYRefreshView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.didChangeValue(forKey: "SVPullToRefreshView")
            }
        }
    }
    var showsPullToRefresh: Bool {
        get {
            return !(refreshView?.isHidden)!
        }
        set (value) {
            refreshView?.isHidden = !value
            if !value {
                if (refreshView?.isObserving)! {
                    self.removeObserver(refreshView!, forKeyPath: "contentOffset")
                    self.removeObserver(refreshView!, forKeyPath: "contentSize")
                    self.removeObserver(refreshView!, forKeyPath: "frame")
                    //refreshView.reset
                    refreshView?.isObserving = false
                }
            } else {
                if !(refreshView?.isObserving)! {
                    self.addObserver(refreshView!, forKeyPath: "contentOffset", options: .new, context: nil)
                    self.addObserver(refreshView!, forKeyPath: "contentSize", options: .new, context: nil)
                    self.addObserver(refreshView!, forKeyPath: "frame", options: .new, context: nil)
                    refreshView?.isObserving = true

                    var yOrigin: CGFloat = 0
                    switch (refreshView?.position)! {
                    case .top:
                        yOrigin = 0 - WYRefreshView.wyRefreshViewHeight
                        break
                    case .bottom:
                        yOrigin = self.contentSize.height
                        break
                    }
                    refreshView?.frame = CGRect(x: 0, y: yOrigin, width: self.bounds.size.width, height: WYRefreshView.wyRefreshViewHeight)
                }
            }
        }
    }

    func addPullToRefreshWithActionHandler(actionHandler: () -> Void, position: WYRefreshPosition = .top) {
        if self.refreshView == nil {
            var yOrigin: CGFloat = 0
            switch position {
            case .top:
                yOrigin = 0 - WYRefreshView.wyRefreshViewHeight
                break
            case .bottom:
                yOrigin = self.contentSize.height
                break
            }

            let view = WYRefreshView(frame: CGRect(x: 0, y: yOrigin, width: self.bounds.size.width, height: WYRefreshView.wyRefreshViewHeight))
//            view.pullToRefreshActionHandler = actionHandler
            view.scrollView = self
            self.addSubview(view)

            view.originalTopInset = self.contentInset.top
            view.originalBottomInset = self.contentInset.bottom
            view.position = position
            self.refreshView = view
            self.showsPullToRefresh = true
        }
    }

    func triggerPullToRefresh() {
        self.refreshView?.state = .triggered
        self.refreshView?.startAnimating()
    }
}
