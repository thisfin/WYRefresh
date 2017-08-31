//
//  ViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/15.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false

        self.view.backgroundColor = UIColor.white

        self.view.addSubview({
            let tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView.dataSource = self;
            tableView.delegate = self;
            return tableView
        }())
    }
}

extension ViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        var value: String?

        switch indexPath.row {
        case 0:
            value = "refresh top"
        case 1:
            value = "refresh bottom"
        case 2:
            value = "infinite"
        case 3:
            value = "top and bottom"
        default:
            ()
        }

        if let label = cell.textLabel, let value = value {
            label.text = value
        }
        return cell;
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let navigationController = navigationController {
                navigationController.pushViewController(RefreshTopViewController(), animated: true)
            }
        case 1:
            if let navigationController = navigationController {
                navigationController.pushViewController(RefreshBottomViewController(), animated: true)
            }
        case 2:
            if let navigationController = navigationController {
                navigationController.pushViewController(InfiniteViewController(), animated: true)
            }
        default:
            ()
        }
    }
}
