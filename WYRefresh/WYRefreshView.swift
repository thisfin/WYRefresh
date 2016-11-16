//
//  WYRefreshView.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/16.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

enum WYRefreshState {
    case stopped, triggered, loading, all
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

    var state: WYRefreshState = .stopped
    var position: WYRefreshPosition = .top

    var titles = ["Pull to refresh...", "Release to refresh...", "Loading..."]
    var subtitles = ["", "", "", ""]
    var viewForState: Array<AnyObject> = ["", "", "", ""]

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
        viewForState.forEach { (obj) in
            if obj.isKind(of: UIView.class) {
                obj.removeFromSuperview()
            }
        }

        

        for(id otherView in self.viewForState) {
            if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
        }

        id customView = [self.viewForState objectAtIndex:self.state];
        BOOL hasCustomView = [customView isKindOfClass:[UIView class]];

        self.titleLabel.hidden = hasCustomView;
        self.subtitleLabel.hidden = hasCustomView;
        self.arrow.hidden = hasCustomView;

        if(hasCustomView) {
            [self addSubview:customView];
            CGRect viewBounds = [customView bounds];
            CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
            [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        }
        else {
            switch (self.state) {
            case SVPullToRefreshStateAll:
            case SVPullToRefreshStateStopped:
                self.arrow.alpha = 1;
                [self.activityIndicatorView stopAnimating];
                switch (self.position) {
                case SVPullToRefreshPositionTop:
                    [self rotateArrow:0 hide:NO];
                    break;
                case SVPullToRefreshPositionBottom:
                    [self rotateArrow:(float)M_PI hide:NO];
                    break;
                }
                break;

            case SVPullToRefreshStateTriggered:
                switch (self.position) {
                case SVPullToRefreshPositionTop:
                    [self rotateArrow:(float)M_PI hide:NO];
                    break;
                case SVPullToRefreshPositionBottom:
                    [self rotateArrow:0 hide:NO];
                    break;
                }
                break;

            case SVPullToRefreshStateLoading:
                [self.activityIndicatorView startAnimating];
                switch (self.position) {
                case SVPullToRefreshPositionTop:
                    [self rotateArrow:0 hide:YES];
                    break;
                case SVPullToRefreshPositionBottom:
                    [self rotateArrow:(float)M_PI hide:YES];
                    break;
                }
                break;
            }

            CGFloat leftViewWidth = MAX(self.arrow.bounds.size.width,self.activityIndicatorView.bounds.size.width);

            CGFloat margin = 10;
            CGFloat marginY = 2;
            CGFloat labelMaxWidth = self.bounds.size.width - margin - leftViewWidth;

            self.titleLabel.text = [self.titles objectAtIndex:self.state];

            NSString *subtitle = [self.subtitles objectAtIndex:self.state];
            self.subtitleLabel.text = subtitle.length > 0 ? subtitle : nil;


            CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                constrainedToSize:CGSizeMake(labelMaxWidth,self.titleLabel.font.lineHeight)
                lineBreakMode:self.titleLabel.lineBreakMode];


            CGSize subtitleSize = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font
                constrainedToSize:CGSizeMake(labelMaxWidth,self.subtitleLabel.font.lineHeight)
                lineBreakMode:self.subtitleLabel.lineBreakMode];

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
}
