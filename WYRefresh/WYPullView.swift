//
//  WYPullView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

private var myContext = 0

class WYPullView: UIView {
    static let viewHeight: CGFloat = 60

    weak var scrollView: UIScrollView?
    var pullToRefreshActionHandler: (() -> Void)?
    var position: WYRefreshPosition = .top
    var originalTopInset: CGFloat = 0
    var originalBottomInset: CGFloat = 0
    var wasTriggeredByUser = true
    var showsPull = false
    var showsDateLabel = false
    var isObserving = false

    private var titles: [String?] = ["Pull to refresh...", "Release to refresh...", "Loading..."]
    private var subtitles = [String?](repeating: nil, count: 4)
    private var viewForState = [UIView?](repeating: nil, count:4)

    var state: WYRefreshState = .stopped {
        didSet {
            if state == oldValue {
                return
            }

            setNeedsLayout()
            layoutIfNeeded()

            switch state {
            case .all:
                resetScrollViewContentInset()
            case .stopped:
                resetScrollViewContentInset()
            case .triggered: break
            case .loading:
                setScrollViewContentInsetForLoading()
                if oldValue == .triggered && pullToRefreshActionHandler != nil {
                    pullToRefreshActionHandler!()
                }
            }
        }
    }

    lazy private var arrowView: WYPullArrowView = {
        let view = WYPullArrowView(frame: CGRect(x: 0, y: self.bounds.size.height - 54, width: 22, height: 48))
        view.backgroundColor = .clear
        self.addSubview(view)
        return view
    }()
    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.addSubview(self.activityIndicatorView)
        return view
    }()
    lazy private var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        label.text = NSLocalizedString("Pull to refresh...", comment: "")
        label.font = UIFont .boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = .darkGray
        self.addSubview(label)
        return label
    }()
    lazy private var subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = .darkGray
        self.addSubview(label)
        return label
    }()

    var arrowColor: UIColor {
        get {
            return arrowView.arrowColor;
        }
        set {
            arrowView.arrowColor = newValue
            arrowView.setNeedsLayout()
        }
    }
    var textColor: UIColor {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
            subtitleLabel.textColor = newValue
        }
    }
    var activityIndicatorViewColor: UIColor {
        get {
            return activityIndicatorView.color!
        }
        set {
            activityIndicatorView.color = newValue
        }
    }
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
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
        if let scrollView = superview as? UIScrollView, let showsPull = scrollView.showsPull, showsPull, newSuperview == nil, isObserving {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
            scrollView.removeObserver(self, forKeyPath: "contentSize")
            scrollView.removeObserver(self, forKeyPath: "frame")
            isObserving = false
        }
    }

    override func layoutSubviews() {
        viewForState.forEach { (view) in
            if let view = view {
                view.removeFromSuperview()
            }
        }

        let hasCustomView = viewForState[state.rawValue] != nil
        titleLabel.isHidden = hasCustomView
        subtitleLabel.isHidden = hasCustomView
        arrowView.isHidden = hasCustomView

        if let customView = viewForState[state.rawValue] {
            addSubview(customView)
            let viewBounds = customView.bounds
            let origin = CGPoint(x: ((bounds.width - viewBounds.width) / 2).rounded(), y: ((bounds.height - viewBounds.height) / 2).rounded())
            customView.frame = CGRect(origin: origin, size: viewBounds.size)
//            let origin = CGPoint(x: CGFloat(roundf(Float((bounds.size.width - viewBounds.size.width) / 2))),
//                                 y: CGFloat(roundf(Float((bounds.size.height - viewBounds.size.height) / 2))))
//            customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
        } else {
            switch state {
            case .all: // 同stop
                arrowView.alpha = 1
                activityIndicatorView.stopAnimating()
                switch position {
                case .top:
                    rotateArrow(degrees: 0, hide: false)
                case .bottom:
                    rotateArrow(degrees: .pi, hide: false)
                }
            case .stopped:
                arrowView.alpha = 1
                activityIndicatorView.stopAnimating()
                switch position {
                case .top:
                    rotateArrow(degrees: 0, hide: false)
                case .bottom:
                    rotateArrow(degrees: .pi, hide: false)
                }
            case .triggered:
                switch position {
                case .top:
                    rotateArrow(degrees: .pi, hide: false)
                case .bottom:
                    rotateArrow(degrees: 0, hide: false)
                }
            case .loading:
                activityIndicatorView.startAnimating()
                switch position {
                case .top:
                    rotateArrow(degrees: 0, hide: true)
                case .bottom:
                    rotateArrow(degrees: .pi, hide: true)
                }
            }
            let leftViewWidth = max(arrowView.bounds.width, activityIndicatorView.bounds.width) // icon width
            let marginX: CGFloat = 10
            let marginY: CGFloat = 2
            let labelMaxWidth = bounds.width - marginX - leftViewWidth

            titleLabel.text = titles[state.rawValue]
            subtitleLabel.text = subtitles[state.rawValue]
            var titleSize: CGSize = .zero // title size
            if let text = titleLabel.text as NSString? {
                titleSize = text.boundingRect(with: CGSize(width: labelMaxWidth, height: titleLabel.font.lineHeight), options: [.usesLineFragmentOrigin], attributes: [.font: titleLabel.font], context: nil).size
            }
            var subtitleSize: CGSize = .zero // subtitle size
            if let text = subtitleLabel.text as NSString? {
                subtitleSize = text.boundingRect(with: CGSize(width:labelMaxWidth, height: subtitleLabel.font.lineHeight), options: .usesLineFragmentOrigin, attributes: [.font: subtitleLabel.font], context: nil).size
            }
            let maxLabelWidth = max(titleSize.width, subtitleSize.width) // 文字宽度
            let totalMaxWidth = leftViewWidth + maxLabelWidth + maxLabelWidth > 0 ? marginX : 0 // 总宽度
            let labelX = (bounds.width / 2) - totalMaxWidth / 2 + leftViewWidth + marginX // label left

            let totalHeight = titleSize.height + subtitleSize.height + (subtitleSize.height == 0 ? 0 : marginY) // 总高度
            let minY = bounds.height / 2 - totalHeight / 2
            let titleY = minY
            titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
            subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral

            let arrowX = bounds.width / 2 - totalMaxWidth / 2 + (leftViewWidth - arrowView.bounds.width) / 2 // arrow point
            arrowView.frame = CGRect(origin: CGPoint(x: arrowX, y: bounds.height / 2 - arrowView.bounds.height / 2), size: arrowView.bounds.size)
            activityIndicatorView.center = arrowView.center
        }
    }

    func resetScrollViewContentInset() {
        if var currentInsets = scrollView?.contentInset {
            switch position {
            case .top:
                currentInsets.top = originalTopInset
            case .bottom:
                currentInsets.top = originalTopInset
                currentInsets.bottom = originalBottomInset
            }
            setScrollViewContentInset(currentInsets)
        }
    }

    func setScrollViewContentInsetForLoading() {
        if let scrollView = scrollView {
            let offset = max(scrollView.contentOffset.y * -1, 0)
            var currentInsets = scrollView.contentInset
            switch position {
            case .top:
                currentInsets.top = min(offset, originalTopInset + bounds.height)
            case .bottom:
                currentInsets.bottom = min(offset, originalBottomInset + bounds.height)
            }
            setScrollViewContentInset(currentInsets)
        }
    }

    private func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            if let scrollView = self.scrollView {
                scrollView.contentInset = contentInset
            }
        })
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let value = change?[.newKey] as? CGPoint {
                scrollViewDidScroll(contentOffset: value)
            }
        } else if keyPath == "contentSize" {
            layoutSubviews()
            var originY: CGFloat = 0
            switch position {
            case .top:
                originY = 0 - WYPullView.viewHeight
            case .bottom:
                if let scrollView = scrollView {
                    originY = max(scrollView.contentSize.height - scrollView.bounds.height, 0) + bounds.height + originalBottomInset
                }
            }
            frame = CGRect(x: 0, y: originY, width: bounds.width, height: WYPushView.viewHeight)
        } else if keyPath == "frame" {
            layoutSubviews()
        }
    }

    func scrollViewDidScroll(contentOffset: CGPoint) {
        guard let scrollView = scrollView else {
            return
        }

        if state != .loading {
            var scrollOffsetThreshold: CGFloat = 0
            switch position {
            case .top:
                scrollOffsetThreshold = frame.origin.y - originalTopInset
            case .bottom:
                scrollOffsetThreshold = max(scrollView.contentSize.height - scrollView.bounds.height, 0) + bounds.height + originalBottomInset
            }

            if !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset.y < scrollOffsetThreshold && scrollView.isDragging && state == .stopped && position == .top {
                state = .triggered
            } else if contentOffset.y >= scrollOffsetThreshold && state != .stopped && position == .top {
                state = .stopped
            } else if contentOffset.y > scrollOffsetThreshold && scrollView.isDragging && state == .stopped && position == .bottom {
                state = .triggered
            } else if contentOffset.y <= scrollOffsetThreshold && state != .stopped && position == .bottom {
                state = .stopped
            }
        } else {
            switch position {
            case .top:
                var offset = max(scrollView.contentOffset.y * -1, 0)
                offset = min(offset, originalTopInset + bounds.height)
                let contentInset = scrollView.contentInset
                scrollView.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
            case .bottom:
                if scrollView.contentSize.height >= scrollView.bounds.height {
                    var offset = max(scrollView.contentSize.height - scrollView.bounds.height + bounds.height, 0)
                    offset = min(offset, originalBottomInset + bounds.height)
                    let contentInset = scrollView.contentInset
                    scrollView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: offset, right: contentInset.right)
                } else if wasTriggeredByUser {
                    let offset = min(bounds.height, originalBottomInset + bounds.height)
                    let contentInset = scrollView.contentInset
                    scrollView.contentInset = UIEdgeInsets(top: 0 - offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
                }
            }
        }
    }

    func setTitle(_ title: String?, forState state: WYRefreshState) {
        if state == .all {
            titles.replaceSubrange(0..<3, with: [title, title, title])
        } else {
            titles[state.rawValue] = title
        }
        setNeedsLayout()
    }

    func setSubtitle(_ title: String?, forState state: WYRefreshState) {
        if state == .all {
            subtitles.replaceSubrange(0..<3, with: [title, title, title])
        } else {
            subtitles[state.rawValue] = title
        }
        setNeedsLayout()
    }

    func setCustomView(_ view: UIView?, forState state: WYRefreshState) {
        if state == .all {
            viewForState.replaceSubrange(0...2, with: [view, view, view])
        } else {
            viewForState[state.rawValue] = view
        }
        setNeedsLayout()
    }

    func triggerRefresh() {
        if let scrollView = scrollView {
            scrollView.triggerPullToRefresh()
        }
    }

    func startAnimating() {
        if let scrollView = scrollView {
            switch position {
            case .top:
                if fabsf(Float(scrollView.contentOffset.y)) < Float.ulpOfOne {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0 - frame.height), animated: true)
                    wasTriggeredByUser = false
                } else {
                    wasTriggeredByUser = true
                }
            case .bottom:
                if (fabsf(Float(scrollView.contentOffset.y)) < Float.ulpOfOne && scrollView.contentSize.height < scrollView.bounds.height) || fabsf(Float(scrollView.contentOffset.y - scrollView.contentSize.height + scrollView.bounds.height)) < Float.ulpOfOne {
                    scrollView.setContentOffset(CGPoint(x: 0, y: max(scrollView.contentSize.height - scrollView.bounds.height, 0) + frame.height), animated: true)
                    wasTriggeredByUser = false
                } else {
                    wasTriggeredByUser = true
                }
            }
            state = .loading
        }
    }

    func stopAnimating() {
        state = .stopped
        if let scrollView = scrollView, !wasTriggeredByUser {
            switch position {
            case .top:
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0 - originalTopInset), animated: true)
            case .bottom:
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.bounds.height + originalBottomInset), animated: true)
            }
        }
    }

    func rotateArrow(degrees: CGFloat, hide: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            self.arrowView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1)
            self.arrowView.layer.opacity = hide ? 0 : 1
        })
    }
}
