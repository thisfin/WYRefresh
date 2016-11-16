//
//  WYRefreshView.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/16.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

enum WYRefreshState: Int {
    case stopped = 0, triggered, loading, all
}

enum WYRefreshPosition {
    case top, bottom
}

class WYRefreshView: UIView {
    static let wyRefreshViewHeight: CGFloat = 60

    var arrowColor: UIColor?
    var textColor = UIColor.darkGray
    var activityIndicatorViewColor: UIColor?
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    var activityIndicatorView: UIActivityIndicatorView?
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray
    var arrowView: WYRefreshArrowView!

    var state: WYRefreshState = .stopped
    var position: WYRefreshPosition = .top

    var titles = ["Pull to refresh...", "Release to refresh...", "Loading..."]
    var subtitles = ["", "", "", ""]
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
        subTitleLabel.isHidden = hasCustomView
        arrowView.isHidden = hasCustomView

        if hasCustomView {
            self.addSubview(customView)
            var viewBounds = customView.bounds
            var origin = CGPoint(x: roundf((self.bounds.size.width - viewBounds.size.width) / 2), y: roundf((self.bounds.size.height - viewBounds.size.height) / 2))
            customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
        } else {
            switch state {
            case .all:
                break
            case .stopped:
                arrowView.alpha = 1
                activityIndicatorView?.stopAnimating()
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
                activityIndicatorView?.startAnimating()
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
            let leftViewWidth = max(arrowView.bounds.size.width, (activityIndicatorView?.bounds.size.width)!)
            let margin: CGFloat = 10
            let marginY: CGFloat = 2
            let labelMaxWidth = self.bounds.size.width - margin - leftViewWidth

            titleLabel.text = titles[state.rawValue]
            subTitleLabel.text = subtitles[state.rawValue]
            let titleSize: CGSize = (titleLabel.text)!.boundingRect(with: CGSize(width: labelMaxWidth, height: titleLabel.font.lineHeight), options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: titleLabel.font], context: nil).size
            let subtitleSize:CGSize = (subTitleLabel.text)!.boundingRect(with: CGSize(width:labelMaxWidth, height: subTitleLabel.font.lineHeight), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: subTitleLabel.font], context: nil).size
            let maxLabelWidth = max(titleSize.width, subtitleSize.width)

            CGFloat maxLabelWidth = MAX(titleSize.width,subtitleSize.width);

            CGFloat totalMaxWidth;
            if (maxLabelWidth) {
                totalMaxWidth = leftViewWidth + margin + maxLabelWidth;
            } else {
                totalMaxWidth = leftViewWidth + maxLabelWidth;
            }

            CGFloat labelX = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + leftViewWidth + margin;

            if(subtitleSize.height > 0){
                CGFloat totalHeight = titleSize.height + subtitleSize.height + marginY;
                CGFloat minY = (self.bounds.size.height / 2)  - (totalHeight / 2);

                CGFloat titleY = minY;
                self.titleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY, titleSize.width, titleSize.height));
                self.subtitleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY + titleSize.height + marginY, subtitleSize.width, subtitleSize.height));
            }else{
                CGFloat totalHeight = titleSize.height;
                CGFloat minY = (self.bounds.size.height / 2)  - (totalHeight / 2);

                CGFloat titleY = minY;
                self.titleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY, titleSize.width, titleSize.height));
                self.subtitleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY + titleSize.height + marginY, subtitleSize.width, subtitleSize.height));
            }

            CGFloat arrowX = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + (leftViewWidth - self.arrow.bounds.size.width) / 2;
            self.arrow.frame = CGRectMake(arrowX,
                                          (self.bounds.size.height / 2) - (self.arrow.bounds.size.height / 2),
                                          self.arrow.bounds.size.width,
                                          self.arrow.bounds.size.height);
            self.activityIndicatorView.center = self.arrow.center;
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
