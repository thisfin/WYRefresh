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

class WYRefreshView: UIView {
    static let wyRefreshViewHeight: CGFloat = 60

    var pullToRefreshActionHandler:SimpleBlockNoneParameter?

    var arrowColor: UIColor {
        get {
            return self.arrowView.arrowColor;
        }
        set {
            self.arrowView.arrowColor = newValue
            self.arrowView.setNeedsLayout()
        }
    }
    var arrowView: WYRefreshArrowView! {
        if self.arrowView == nil {
            let view = WYRefreshArrowView(frame: CGRect(x: 0, y: self.bounds.size.height - 54, width: 22, height: 48))
            view.backgroundColor = .clear
            self.addSubview(view)
            return view
        }
        return self.arrowView
    }
    var textColor: UIColor {
        get {
            return self.titleLabel.textColor
        }
        set {
            self.titleLabel.textColor = newValue
            self.subtitleLabel.textColor = newValue
        }
    }
    var titleLabel: UILabel! {
        if self.titleLabel == nil {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
            label.text = NSLocalizedString("Pull to refresh...", comment: "")
            label.font = UIFont .boldSystemFont(ofSize: 14)
            label.backgroundColor = UIColor.clear
            label.textColor = .darkGray
            self.addSubview(label)
            return label
        }
        return self.titleLabel
    }
    var subtitleLabel: UILabel! {
        if self.subtitleLabel == nil {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
            label.font = UIFont.systemFont(ofSize: 12)
            label.backgroundColor = UIColor.clear
            label.textColor = .darkGray
            self.addSubview(label)
            return label
        }
        return self.subtitleLabel
    }
    var activityIndicatorView: UIActivityIndicatorView! {
        if self.activityIndicatorView == nil {
            let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            view.hidesWhenStopped = true
            view.addSubview(self.activityIndicatorView)
            return view
        }
        return self.activityIndicatorView
    }
    var activityIndicatorViewColor: UIColor {
        get {
            return self.activityIndicatorView.color!
        }
        set(color) {
            self.activityIndicatorView.color = color
        }
    }
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return self.activityIndicatorView.activityIndicatorViewStyle
        }
        set(style) {
            self.activityIndicatorView.activityIndicatorViewStyle = style
        }
    }

    var state: WYRefreshState = .stopped
    var position: WYRefreshPosition = .top

    var titles = ["Pull to refresh...", "Release to refresh...", "Loading..."]
    var subtitles: Array<String> = ["", "", "", ""]
    var viewForState = Array<UIView>(repeating: UIView(), count: 4)

    weak var scrollView: UIScrollView?
    var originalTopInset: CGFloat?
    var originalBottomInset: CGFloat?

    var wasTriggeredByUser = true
    var showsPullToRefresh = false
    var showsDateLabel = false
    var isObserving = false

    func setTitle(_ title: String, forState state: WYRefreshState) {

    }

    func setSubTitle(_ title: String, forState state: WYRefreshState) {

    }

    func setCustomView(_ view: UIView, forState state: WYRefreshState) {

    }

    func startAnimating() {

    }

    func stopAnimating() {

    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initSubview()
    }

    private func initSubview() {
        self.autoresizingMask = .flexibleWidth
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if self.superview != nil && newSuperview != nil {
            let scrollView: UIScrollView = self.superview as! UIScrollView
            if scrollView.showsPullToRefresh && self.isObserving {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "contentSize")
                scrollView.removeObserver(self, forKeyPath: "frame")
                self.isObserving = false
            }
        }
    }

    override func layoutSubviews() {
        viewForState.forEach { (view) in
            view.removeFromSuperview()
        }

        let customView = viewForState[state.rawValue]
        let hasCustomView = true
        titleLabel.isHidden = hasCustomView
        subtitleLabel.isHidden = hasCustomView
        arrowView.isHidden = hasCustomView

        if hasCustomView {
            self.addSubview(customView)
            let viewBounds = customView.bounds
            let origin = CGPoint(x: CGFloat(roundf(Float((self.bounds.size.width - viewBounds.size.width) / 2))),
                                 y: CGFloat(roundf(Float((self.bounds.size.height - viewBounds.size.height) / 2))))
            customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
        } else {
            switch state {
            case .all:
                break
            case .stopped:
                arrowView.alpha = 1
                activityIndicatorView.stopAnimating()
                switch position {
                case .top:
                    rotateArrow(degrees: 0, hide: false)
                    break
                case .bottom:
                    rotateArrow(degrees: CGFloat(M_PI), hide: false)
                    break
                }
                break
            case .triggered:
                switch position {
                case .top:
                    rotateArrow(degrees: CGFloat(M_PI), hide: false)
                    break
                case .bottom:
                    rotateArrow(degrees: 0, hide: false)
                    break
                }
                break
            case .loading:
                activityIndicatorView.startAnimating()
                switch position {
                case .top:
                    rotateArrow(degrees: CGFloat(M_PI), hide: false)
                    break
                case .bottom:
                    rotateArrow(degrees: 0, hide: false)
                    break
                }
                break

            }
            let leftViewWidth = max(arrowView.bounds.size.width, activityIndicatorView.bounds.size.width)
            let margin: CGFloat = 10
            let marginY: CGFloat = 2
            let labelMaxWidth = self.bounds.size.width - margin - leftViewWidth

            titleLabel.text = titles[state.rawValue]
            subtitleLabel.text = subtitles[state.rawValue]
            let titleSize: CGSize = (titleLabel.text)!.boundingRect(with: CGSize(width: labelMaxWidth, height: titleLabel.font.lineHeight), options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: titleLabel.font], context: nil).size
            let subtitleSize:CGSize = (subTitleLabel.text)!.boundingRect(with: CGSize(width:labelMaxWidth, height: subTitleLabel.font.lineHeight), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: subTitleLabel.font], context: nil).size
            let maxLabelWidth = max(titleSize.width, subtitleSize.width)
            let totalMaxWidth = leftViewWidth + maxLabelWidth + maxLabelWidth > 0 ? margin : 0
            let labelX = (self.bounds.size.width / 2) - totalMaxWidth / 2 + leftViewWidth + margin
            if subtitleSize.height > 0 {
                let totalHeight = titleSize.height + subtitleSize.height + marginY
                let minY = self.bounds.size.height / 2 - totalHeight / 2
                let titleY = minY
                titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
                subTitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
            } else {
                let totalHeight = titleSize.height
                let minY = self.bounds.size.height / 2 - totalHeight / 2
                let titleY = minY
                titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
                subTitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
            }
            let arrowX = self.bounds.size.width / 2 - totalMaxWidth / 2 + (leftViewWidth - arrowView.bounds.size.width) / 2
            arrowView.frame = CGRect(x: arrowX,
                                     y: self.bounds.size.height / 2 - arrowView.bounds.size.height / 2,
                                     width: arrowView.bounds.size.width,
                                     height: arrowView.bounds.size.height)
            activityIndicatorView.center = arrowView.center
        }
    }

    func resetScrollViewContentInset() {
        var currentInsets = self.scrollView?.contentInset
        switch position {
        case .top:
            currentInsets?.top = originalTopInset!
            break
        case .bottom:
            currentInsets?.bottom = originalBottomInset!
            currentInsets?.top = originalTopInset!
            break
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
        let offset = max((self.scrollView?.contentOffset.y)! * -1, 0)
        var currentInsets = self.scrollView?.contentInset
        switch position {
        case .top:
            currentInsets?.top = min(offset, self.originalTopInset! + self.bounds.size.height)
            break
        case .bottom:
            currentInsets?.bottom = min(offset, self.originalBottomInset! + self.bounds.size.height)
            break
        }
        setScrollViewContentInset(currentInsets!)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "contentOffset" {
//            self.scrollViewDidScroll(
//        }
    }

//    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if([keyPath isEqualToString:@"contentOffset"])
//    [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
//    else if([keyPath isEqualToString:@"contentSize"]) {
//    [self layoutSubviews];
//
//    CGFloat yOrigin;
//    switch (self.position) {
//    case SVPullToRefreshPositionTop:
//    yOrigin = -SVPullToRefreshViewHeight;
//    break;
//    case SVPullToRefreshPositionBottom:
//    yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
//    break;
//    }
//    self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
//    }
//    else if([keyPath isEqualToString:@"frame"])
//    [self layoutSubviews];
//
//    }

//    func scrollViewDidScroll(contentOffset: CGPoint) {
//        if self.state != .loading {
//            var scrollOffsetThreshold: CGFloat = 0
//            switch position {
//            case .top:
//                scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset!
//                break
//            case .bottom:
//                scrollOffsetThreshold = max((self.scrollView?.contentSize.height)! - (self.scrollView?.bounds.size.height)!, 0) + self.bounds.size.height + self.originalBottomInset!
//                break
//            }
//
//            if !(self.scrollView?.isDragging)! && self.state == .triggered {
//                self.state = .loading
//            } else if contentOffset.y < scrollOffsetThreshold && (self.scrollView?.isDragging)! && self.state == .stopped && position == .top {
//                self.state = .triggered
//            } else if contentOffset.y >= scrollOffsetThreshold && self.state != .stopped && position == .top {
//                self.state = .stopped
//            } else if contentOffset.y > scrollOffsetThreshold && (self.scrollView?.isDragging)! && self.state == .stopped && position == .bottom {
//                self.state = .triggered
//            } else if contentOffset.y <= scrollOffsetThreshold && self.state != .stopped && position == .bottom {
//                self.state = .stopped
//            }
//        } else {
//            var offset: CGFloat
//            var contentInset: UIEdgeInsets
//            switch self.position {
//            case .top:
//                offset = max((self.scrollView?.contentOffset.y)!, 0)
//                offset = min(offset, self.originalTopInset! + self.bounds.size.height)
//                contentInset = (self.scrollView?.contentInset)!
//                self.scrollView?.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
//                break
//            case .bottom:
//                if self.scrollView?.contentSize.height >= self.scrollView?.bounds.size.height {
//                    offset = max((self.scrollView?.contentSize.height)! - (self.scrollView?.bounds.size.height)! + self.bounds.size.height, 0)
//                    offset = min(offset, self.originalBottomInset + self.bounds.size.height)
//                    contentInset = (self.scrollView?.contentInset)!
//                    self.scrollView?.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: offset, right: contentInset.right)
//                } else if self.wasTriggeredByUser {
//                    offset = min(self.bounds.size.height, self.originalBottomInset + self.bounds.size.height)
//                    contentInset = self.scrollView?.contentInset
//                    self.scrollView?.contentMode = UIEdgeInsets(top: 0 - offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
//                }
//                break
//            }
//        }
//    }
//
//
//
//
//    - (void)setTitle:(NSString *)title forState:(SVPullToRefreshState)state {
//    if(!title)
//    title = @"";
//
//    if(state == SVPullToRefreshStateAll)
//    [self.titles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[title, title, title]];
//    else
//    [self.titles replaceObjectAtIndex:state withObject:title];
//
//    [self setNeedsLayout];
//    }

//    - (void)setSubtitle:(NSString *)subtitle forState:(SVPullToRefreshState)state {
//    if(!subtitle)
//    subtitle = @"";
//
//    if(state == SVPullToRefreshStateAll)
//    [self.subtitles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[subtitle, subtitle, subtitle]];
//    else
//    [self.subtitles replaceObjectAtIndex:state withObject:subtitle];
//
//    [self setNeedsLayout];
//    }

//    - (void)setCustomView:(UIView *)view forState:(SVPullToRefreshState)state {
//    id viewPlaceholder = view;
//
//    if(!viewPlaceholder)
//    viewPlaceholder = @"";
//
//    if(state == SVPullToRefreshStateAll)
//    [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
//    else
//    [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
//
//    [self setNeedsLayout];
//    }

    func setSubtitle(title: String?, forState state: WYRefreshState) {
        let str = title != nil ? title : ""
//        if self.state == .all {
//            repeatElement(str, count: 5)
//            self.subtitles.replaceSubrange(0..<3, with: [str, str, str])
//        } else {
//            self.subtitles[self.state.rawValue] = str!
//        }
        self.setNeedsLayout()
    }

    func setCustomView(view: UIView, forState state: WYRefreshState) {
        if state == .all {
            // todo
        }
    }

    func setActivityIndicatorViewColor(color: UIColor) {
        self.activityIndicatorView?.color = color
    }

    func setActivityIndicatorViewStyle(viewStyle: UIActivityIndicatorViewStyle) {
        self.activityIndicatorView?.activityIndicatorViewStyle = viewStyle
    }

    func triggerRefresh() {
        self.scrollView?.triggerPullToRefresh()
    }

    func startAnimating() {
        switch self.position {
        case .top:
            if fabsf(Float((self.scrollView?.contentOffset.y)!)) < FLT_EPSILON {
                self.scrollView?.setContentOffset(CGPoint(x: (self.scrollView?.contentOffset.x)!, y: 0 - self.frame.size.height), animated: true)
                self.wasTriggeredByUser = false
            } else {
                self.wasTriggeredByUser = true
            }
            break
        case .bottom:
            if (fabsf(Float((self.scrollView?.contentOffset.y)!)) < FLT_EPSILON && self.scrollView?.contentSize.height < self.scrollView?.bounds.size.height) || fabsf(Float((self.scrollView?.contentOffset.y)! - (self.scrollView?.contentSize.height)! + (self.scrollView?.bounds.size.height)!)) < FLT_EPSILON {
                self.scrollView?.setContentOffset(CGPoint(x: 0, y: max((self.scrollView?.contentSize.height)! - (self.scrollView?.bounds.size.height)!, 0) + self.frame.size.height), animated: true)
                self.wasTriggeredByUser = false
            } else {
                self.wasTriggeredByUser = true
            }
            break;
        }
        self.state = .loading
    }

    func stopAnimating() {
        self.state = .stopped

        switch self.position {
        case .top:
            if !self.wasTriggeredByUser {
                self.scrollView?.setContentOffset(CGPoint(x: (self.scrollView?.contentOffset.x)!, y: 0 - self.originalTopInset!), animated: true)
            }
            break
        case .bottom:
            if !self.wasTriggeredByUser {
                self.scrollView?.setContentOffset(CGPoint(x: (self.scrollView?.contentOffset.x)!, y: (self.scrollView?.contentSize.height)! - (self.scrollView?.bounds.size.height)! + self.originalBottomInset!), animated: true)
            }
            break
        }
    }

    func setState(newState: WYRefreshState) {
        if self.state == newState {
            return
        }

        let previousState = self.state
        self.state = newState

        self.setNeedsLayout()
        self.layoutIfNeeded()

        switch self.state {
        case .all:
            break
        case .stopped:
            self.resetScrollViewContentInset()
            break
        case .triggered:
            break
        case .loading:
            self.setScrollViewContentInsetForLoading()
            if previousState == .triggered && (self.pullToRefreshActionHandler != nil) {
                self.pullToRefreshActionHandler!()
            }
            break
        }
    }

    func rotateArrow(degrees: CGFloat, hide: Bool) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: { () -> Void in
                        self.arrowView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1)
                        self.arrowView.layer.opacity = hide ? 0 : 1
            },
                       completion: nil)
    }
}
