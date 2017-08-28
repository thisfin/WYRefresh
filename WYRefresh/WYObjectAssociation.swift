//
//  WYObjectAssociation.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/28.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import Foundation

// 这种写法垃圾回收真的没问题?
// http://blog.leichunfeng.com/blog/2015/06/26/objective-c-associated-objects-implementation-principle/
final class WYObjectAssociation<T: Any> {
    private let policy: objc_AssociationPolicy

    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    public subscript(index: Any) -> T? {
        get {
            return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
        }
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
        }
    }
}
