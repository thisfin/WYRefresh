//
//  TTopViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/30.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class TPullTopViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addPullToRefreshWithActionHandler { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.beginUpdates()
                strongSelf.datas.insert(Date(), at: 0)
                strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                strongSelf.tableView.endUpdates()
                strongSelf.tableView.pullView?.stopAnimating()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.triggerPullToRefresh()
    }
}
