//
//  InfiniteViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/30.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class InfiniteViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addInfiniteWithActionHandler { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.beginUpdates()
                strongSelf.datas.append(Date())
                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.datas.count - 1, section: 0)], with: .top)
                strongSelf.tableView.endUpdates()
                strongSelf.tableView.infiniteView?.stopAnimating()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.triggerInfiniteScrolling()
    }
}
