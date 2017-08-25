//
//  WYRefreshView.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/16.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

typealias SimpleBlockNoneParameter = () -> Void
typealias SimpleBlock = (_ data: AnyObject) -> Void

enum WYRefreshState: Int {
    case stopped = 0, triggered, loading, all
}

enum WYRefreshPosition {
    case top, bottom
}

private var myContext = 0

class WYRefreshView: UIView {
    static let wyRefreshViewHeight: CGFloat = 60

    dynamic override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
        }
    }

    var pullToRefreshActionHandler: SimpleBlockNoneParameter?

    var state: WYRefreshState = .stopped
    var position: WYRefreshPosition = .top

    var titles: [String] = ["Pull to refresh...", "Release to refresh...", "Loading..."]
    var subtitles = [String](repeating: "", count: 4)
    var viewForState = Array<UIView>(repeating: WYEmptyView(), count:4)

    weak var scrollView: UIScrollView?
    var originalTopInset: CGFloat?
    var originalBottomInset: CGFloat?

    var wasTriggeredByUser = true
    var showsPullToRefresh = false
    var showsDateLabel = false
    var isObserving = false

    lazy var arrowView: WYRefreshArrowView = {
        let view = WYRefreshArrowView(frame: CGRect(x: 0, y: self.bounds.size.height - 54, width: 22, height: 48))
        view.backgroundColor = .clear
        self.addSubview(view)
        return view
    }()
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        view.addSubview(self.activityIndicatorView)
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        label.text = NSLocalizedString("Pull to refresh...", comment: "")
        label.font = UIFont .boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = .darkGray
        self.addSubview(label)
        return label
    }()
    lazy var subtitleLabel: UILabel = {
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

        initSubview()
    }

    private func initSubview() {
        autoresizingMask = .flexibleWidth
        activityIndicatorViewStyle = .gray
        textColor = .darkGray
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil && newSuperview != nil {
            let scrollView: UIScrollView = superview as! UIScrollView
            if scrollView.showsPullToRefresh && isObserving {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "contentSize")
                scrollView.removeObserver(self, forKeyPath: "frame")
                isObserving = false
            }
        }
    }

    override func layoutSubviews() {
        viewForState.forEach { (view) in
            if !(view is WYEmptyView) {
                view.removeFromSuperview()
            }
        }

        let customView = viewForState[state.rawValue]
        let hasCustomView = !(customView is WYEmptyView)
        titleLabel.isHidden = hasCustomView
        subtitleLabel.isHidden = hasCustomView
        arrowView.isHidden = hasCustomView

        if hasCustomView {
            addSubview(customView)
            let viewBounds = customView.bounds
            let origin = CGPoint(x: CGFloat(roundf(Float((bounds.size.width - viewBounds.size.width) / 2))),
                                 y: CGFloat(roundf(Float((bounds.size.height - viewBounds.size.height) / 2))))
            customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
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
            let leftViewWidth = max(arrowView.bounds.size.width, activityIndicatorView.bounds.size.width)
            let margin: CGFloat = 10
            let marginY: CGFloat = 2
            let labelMaxWidth = bounds.size.width - margin - leftViewWidth

            titleLabel.text = titles[state.rawValue]
            subtitleLabel.text = subtitles[state.rawValue]
            let titleSize: CGSize = (titleLabel.text)!.boundingRect(with: CGSize(width: labelMaxWidth, height: titleLabel.font.lineHeight), options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: titleLabel.font], context: nil).size
            let subtitleSize:CGSize = (subtitleLabel.text)!.boundingRect(with: CGSize(width:labelMaxWidth, height: subtitleLabel.font.lineHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: subtitleLabel.font], context: nil).size
            let maxLabelWidth = max(titleSize.width, subtitleSize.width)
            let totalMaxWidth = leftViewWidth + maxLabelWidth + maxLabelWidth > 0 ? margin : 0
            let labelX = (bounds.size.width / 2) - totalMaxWidth / 2 + leftViewWidth + margin
            if subtitleSize.height > 0 {
                let totalHeight = titleSize.height + subtitleSize.height + marginY
                let minY = bounds.size.height / 2 - totalHeight / 2
                let titleY = minY
                titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
                subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
            } else {
                let totalHeight = titleSize.height
                let minY = bounds.size.height / 2 - totalHeight / 2
                let titleY = minY
                titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
                subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
            }
            let arrowX = bounds.size.width / 2 - totalMaxWidth / 2 + (leftViewWidth - arrowView.bounds.size.width) / 2
            arrowView.frame = CGRect(x: arrowX,
                                     y: bounds.size.height / 2 - arrowView.bounds.size.height / 2,
                                     width: arrowView.bounds.size.width,
                                     height: arrowView.bounds.size.height)
            activityIndicatorView.center = arrowView.center
        }
    }

    func resetScrollViewContentInset() {
        var currentInsets = scrollView?.contentInset
        switch position {
        case .top:
            currentInsets?.top = originalTopInset!
        case .bottom:
            currentInsets?.bottom = originalBottomInset!
            currentInsets?.top = originalTopInset!
        }
        setScrollViewContentInset(currentInsets!)
    }

    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {() -> Void in
                        self.scrollView?.contentInset = contentInset},
                       completion: nil)
    }

    func setScrollViewContentInsetForLoading() {
        let offset = max((scrollView?.contentOffset.y)! * -1, 0)
        var currentInsets = scrollView?.contentInset
        switch position {
        case .top:
            currentInsets?.top = min(offset, originalTopInset! + bounds.size.height)
        case .bottom:
            currentInsets?.bottom = min(offset, originalBottomInset! + bounds.size.height)
        }
        setScrollViewContentInset(currentInsets!)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            //TODO: 两个属性貌似并不存在
            if keyPath == "contentOffset" {
                //            scrollViewDidScroll(contentOffset: change[NSKeyValueChangeKey.newKey])
            } else if keyPath == "contentSize" {

            } else if keyPath == "frame" {
                layoutSubviews()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    func scrollViewDidScroll(contentOffset: CGPoint) {
        if state != .loading {
            var scrollOffsetThreshold: CGFloat = 0
            switch position {
            case .top:
                scrollOffsetThreshold = frame.origin.y - originalTopInset!
            case .bottom:
                scrollOffsetThreshold = max((scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)!, 0) + bounds.size.height + originalBottomInset!
            }

            if !(scrollView?.isDragging)! && state == .triggered {
                state = .loading
            } else if contentOffset.y < scrollOffsetThreshold && (scrollView?.isDragging)! && state == .stopped && position == .top {
                state = .triggered
            } else if contentOffset.y >= scrollOffsetThreshold && state != .stopped && position == .top {
                state = .stopped
            } else if contentOffset.y > scrollOffsetThreshold && (scrollView?.isDragging)! && state == .stopped && position == .bottom {
                state = .triggered
            } else if contentOffset.y <= scrollOffsetThreshold && state != .stopped && position == .bottom {
                state = .stopped
            }
        } else {
            var offset: CGFloat
            var contentInset: UIEdgeInsets
            switch position {
            case .top:
                offset = max((scrollView?.contentOffset.y)!, 0)
                offset = min(offset, originalTopInset! + bounds.size.height)
                contentInset = (scrollView?.contentInset)!
                scrollView?.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
            case .bottom:
                if (scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)! >= CGFloat(0) {
                    offset = max((scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)! + bounds.size.height, 0)
                    offset = min(offset, originalBottomInset! + bounds.size.height)
                    contentInset = (scrollView?.contentInset)!
                    scrollView?.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: offset, right: contentInset.right)
                } else if wasTriggeredByUser {
                    offset = min(bounds.size.height, originalBottomInset! + bounds.size.height)
                    contentInset = (scrollView?.contentInset)!
                    scrollView?.contentInset = UIEdgeInsets(top: 0 - offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
                }
            }
        }
    }

    func setTitle(_ title: String?, forState state: WYRefreshState) {
        let str = title != nil ? title : ""

        if state == .all {
            // repeatElement(str, count: 3)
            titles.replaceSubrange(0..<3, with: [str!, str!, str!])
        } else {
            titles[state.rawValue] = str!
        }
        setNeedsLayout()
    }

    func setSubtitle(_ title: String?, forState state: WYRefreshState) {
        let str = title != nil ? title : ""
        if state == .all {
            subtitles.replaceSubrange(0..<3, with: [str!, str!, str!])
        } else {
            subtitles[state.rawValue] = str!
        }
        setNeedsLayout()
    }

    func setCustomView(_ view: UIView?, forState state: WYRefreshState) {
        let viewPlaceholder: UIView = view != nil ? view!  : WYEmptyView()

        if state == .all {
            viewForState.replaceSubrange(0..<3, with: [viewPlaceholder, viewPlaceholder, viewPlaceholder])
        } else {
            viewForState[state.rawValue] = viewPlaceholder
        }
        setNeedsLayout()
    }

    func triggerRefresh() {
        scrollView?.triggerPullToRefresh()
    }

    func startAnimating() {
        switch position {
        case .top:
            if fabsf(Float((scrollView?.contentOffset.y)!)) < Float.ulpOfOne {
                scrollView?.setContentOffset(CGPoint(x: (scrollView?.contentOffset.x)!, y: 0 - frame.size.height), animated: true)
                wasTriggeredByUser = false
            } else {
                wasTriggeredByUser = true
            }
        case .bottom:
            if (fabsf(Float((scrollView?.contentOffset.y)!)) < Float.ulpOfOne && (scrollView?.contentSize.height)! < (scrollView?.bounds.size.height)!) || fabsf(Float((scrollView?.contentOffset.y)! - (scrollView?.contentSize.height)! + (scrollView?.bounds.size.height)!)) < Float.ulpOfOne {
                scrollView?.setContentOffset(CGPoint(x: 0, y: max((scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)!, 0) + frame.size.height), animated: true)
                wasTriggeredByUser = false
            } else {
                wasTriggeredByUser = true
            }
        }
        state = .loading
    }

    func stopAnimating() {
        state = .stopped

        switch position {
        case .top:
            if !wasTriggeredByUser {
                scrollView?.setContentOffset(CGPoint(x: (scrollView?.contentOffset.x)!, y: 0 - originalTopInset!), animated: true)
            }
        case .bottom:
            if !wasTriggeredByUser {
                scrollView?.setContentOffset(CGPoint(x: (scrollView?.contentOffset.x)!, y: (scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)! + originalBottomInset!), animated: true)
            }
        }
    }

    func setState(newState: WYRefreshState) {
        if state == newState {
            return
        }

        let previousState = state
        state = newState

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
            if previousState == .triggered && pullToRefreshActionHandler != nil {
                pullToRefreshActionHandler!()
            }
        }
    }

    func rotateArrow(degrees: CGFloat, hide: Bool) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: { () -> Void in
                        self.arrowView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1)
                        self.arrowView.layer.opacity = hide ? 0 : 1},
                       completion: nil)
    }
}
