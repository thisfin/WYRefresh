//
//  WYPullView.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class WYPullView: UIView {
    static let constSize = CGSize(width: 22, height: 48)
    var arrowColor = UIColor.gray

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            stride(from: 0, through: 30, by: 6).forEach { (i) in
                context.addRect(CGRect(x: 5, y: i, width: 12, height: 4))
            }
            context.move(to: CGPoint(x: 0, y: 34))
            context.addLine(to: CGPoint(x: 11, y: 48))
            context.addLine(to: CGPoint(x: 22, y: 34))
            context.addLine(to: CGPoint(x: 0, y: 34))
            context.closePath()
            context.saveGState()
            context.clip()

            let alphaGradientColors = [arrowColor.withAlphaComponent(0).cgColor, arrowColor.withAlphaComponent(1).cgColor];
            let alphaGradientLocations: [CGFloat] = [0, 0.9] // 区段
            let alphaGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: alphaGradientColors as CFArray, locations: alphaGradientLocations)!;
            context.drawLinearGradient(alphaGradient, start: CGPoint.zero, end: CGPoint(x: 0, y: rect.size.height), options: .drawsBeforeStartLocation);
            context.restoreGState();
        }
    }
}
