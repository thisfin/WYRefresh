//
//  InfiniteRefreshViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2017/9/1.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class InfiniteRefreshViewController: BaseViewController {
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
        tableView.addRefreshWithActionHandler { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.beginUpdates()
                strongSelf.datas.insert(Date(), at: 0)
                strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                strongSelf.tableView.endUpdates()
                strongSelf.tableView.refreshView?.stopAnimating()
            })
        }
    }
}

