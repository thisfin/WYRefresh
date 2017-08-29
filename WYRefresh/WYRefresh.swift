//
//  WYRefresh.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/29.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import Foundation

enum WYRefreshState: Int {
    case stopped = 0, triggered, loading, all
}

enum WYRefreshPosition {
    case top, bottom
}
