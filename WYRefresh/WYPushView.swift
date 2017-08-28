//
//  WYPushView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

enum WYPushState: Int {
    case stopped = 0, triggered, loading, all = 10
}

class WYPushView: UIView {
    static let pushViewHeight: CGFloat = 60

    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return activityIndicatorView.activityIndicatorViewStyle
        }
        set {
            activityIndicatorView.activityIndicatorViewStyle = newValue
        }
    }
    var state: WYPushState = .stopped {
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
                let origin = CGPoint.init(x: ((bounds.width - customView.bounds.width) / 2).rounded(), y: ((bounds.height - customView.bounds.height) / 2).rounded())
                customView.frame.origin = origin
            } else {
                let origin = CGPoint.init(x: ((bounds.width - activityIndicatorView.bounds.width) / 2).rounded(), y: ((bounds.height - activityIndicatorView.bounds.height) / 2).rounded())
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

            if let handler = pushHandler, oldValue == .triggered, state == .loading, enabled {
                handler()
            }
        }
    }
    weak var scrollView: UIScrollView?
    var enabled: Bool = true
    var originalBottomInset: CGFloat?
    var pushHandler: (() -> Void)?
    var isObserving: Bool = false

    private var viewForState: [UIView?] = [nil, nil, nil, nil]
    // 如果这里用非 lazy 的时候, self. 会报错, 初始化时机的问题
    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
        return activityIndicatorView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = .flexibleWidth
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView, let showsPush = scrollView.showsPush, showsPush, newSuperview == nil, isObserving {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
            scrollView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    override func layoutSubviews() {
        activityIndicatorView.center = CGPoint.init(x: bounds.width / 2, y: bounds.height / 2)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == "contentOffset" {
                if let value = change[.newKey].CGP

                scrollViewDidScroll(contentOffset: change[.newKey])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
        } else if [keyPath isEqualToString:@"contentSize"] {
            [self layoutSubviews];
            self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, SVInfiniteScrollingViewHeight);
        }
        }
    }

    private func scrollViewDidScroll(contentOffset: CGPoint) {
        if let scrollView = scrollView, state != .loading, enabled {
            let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height

            if !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging {
                state = .triggered
            } else if contentOffset.y < scrollOffsetThreshold  && state != .stopped {
                state = .stopped
            }
        }
    }

    func resetScrollViewContentInset() {
        if var currentInsets = scrollView?.contentInset, let originalBottomInset = originalBottomInset {
            currentInsets.bottom = originalBottomInset
            setScrollViewContentInset(contentInset: currentInsets)
        }
    }

    func setScrollViewContentInsetForInfiniteScrolling() {
        if var currentInsets = scrollView?.contentInset, let originalBottomInset = originalBottomInset {
            currentInsets.bottom = originalBottomInset + WYPushView.pushViewHeight
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

    func setCustomView(view: UIView?, state: WYPushState) {
        if state == .all {
            viewForState.replaceSubrange(0...2, with: [view, view, view])
        } else {
            viewForState.replaceSubrange((state.rawValue)...(state.rawValue + 1), with: [view])
            // viewForState.replaceSubrange(Range<Int>.init(NSRange.init(location: state.rawValue, length: 1))!, with: [view])
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
