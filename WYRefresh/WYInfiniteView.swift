//
//  WYInfiniteView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class WYInfiniteView: UIView {
    static let viewHeight: CGFloat = 60

    weak var scrollView: UIScrollView?
    var infiniteHandler: (() -> Void)?
    var originalBottomInset: CGFloat = 0
    var isObserving = false

    private var viewForState: [UIView?] = [nil, nil, nil]

    var state: WYRefreshState = .stopped {
        didSet {
            if state == oldValue {
                return
            }

            viewForState.forEach { (view) in
                if let view = view {
                    view.removeFromSuperview()
                }
            }

            if let customView = viewForState[state.rawValue] {
                addSubview(customView)
                let origin = CGPoint(x: ((bounds.width - customView.bounds.width) / 2).rounded(), y: ((bounds.height - customView.bounds.height) / 2).rounded())
                customView.frame.origin = origin
            } else {
                let origin = CGPoint(x: ((bounds.width - activityIndicatorView.bounds.width) / 2).rounded(), y: ((bounds.height - activityIndicatorView.bounds.height) / 2).rounded())
                activityIndicatorView.frame.origin = origin

                switch state {
                case .stopped:
                    activityIndicatorView.stopAnimating()
                case .triggered:
                    activityIndicatorView.startAnimating()
                case .loading:
                    activityIndicatorView.startAnimating()
                default:
                    ()
                }
            }

            if let handler = infiniteHandler, oldValue == .triggered, state == .loading {
                handler()
            }
        }
    }

    lazy private var activityIndicatorView: UIActivityIndicatorView = { // 如果这里用非 lazy 的时候, self. 会报错, 初始化时机的问题
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
        return activityIndicatorView
    }()

    /// 自定义设置菊花样式
    public var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return activityIndicatorView.activityIndicatorViewStyle
        }
        set {
            activityIndicatorView.activityIndicatorViewStyle = newValue
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = .flexibleWidth
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView, let showsInfinite = scrollView.showsInfinite, showsInfinite, newSuperview == nil, isObserving {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
            scrollView.removeObserver(self, forKeyPath: "contentSize")
            isObserving = false
        }
    }

    override func layoutSubviews() {
        activityIndicatorView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let value = change?[.newKey] as? CGPoint {
                scrollViewDidScroll(contentOffset: value)
            }
        } else if keyPath == "contentSize" {
            layoutSubviews()
            if let scrollView = scrollView {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: bounds.width, height: WYInfiniteView.viewHeight)
            }
        }
    }

    private func scrollViewDidScroll(contentOffset: CGPoint) {
        if let scrollView = scrollView, state != .loading {
            let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height

            if !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging {
                state = .triggered
            } else if contentOffset.y < scrollOffsetThreshold && state != .stopped {
                state = .stopped
            }
        }
    }

    func resetScrollViewContentInset() {
        if var currentInsets = scrollView?.contentInset {
            currentInsets.bottom = originalBottomInset
            setScrollViewContentInset(contentInset: currentInsets)
        }
    }

    func setScrollViewContentInsetForInfiniteScrolling() {
        if var currentInsets = scrollView?.contentInset {
            currentInsets.bottom = originalBottomInset + WYInfiniteView.viewHeight
            setScrollViewContentInset(contentInset: currentInsets)
        }
    }

    private func setScrollViewContentInset(contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            if let scrollView = self.scrollView {
                scrollView.contentInset = contentInset
            }
        })
    }

    /// 自定义设置菊花 view
    public func setCustomView(view: UIView?, state: WYRefreshState) {
        if state == .all {
            viewForState.replaceSubrange(0...2, with: [view, view, view])
        } else {
            viewForState[state.rawValue] = view
        }
    }

    private func triggerRefresh() {
        state = .triggered
        state = .loading
    }

    func startAnimating() {
        state = .loading
    }

    func stopAnimating() {
        state = .stopped
    }
}
