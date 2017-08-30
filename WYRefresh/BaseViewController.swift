//
//  BaseViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2017/8/30.
//  Copyright © 2017年 wyrefresh. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UITableViewDelegate {
    var tableView: UITableView!
    var datas = [Date]()

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.automaticallyAdjustsScrollViewInsets = false
//        self.navigationController?.navigationBar.isTranslucent = false

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self;
        tableView.delegate = self;
        self.view.addSubview(tableView);

        (10 ..< 30).forEach({ (i) in
            datas.append(Date(timeIntervalSinceNow: TimeInterval(0 - i * 90)))
        })
    }
}

extension BaseViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        }

        if let label = cell?.textLabel {
            label.text = DateFormatter.localizedString(from: datas[indexPath.row], dateStyle: .none, timeStyle: .medium)
        }
        return cell!;
    }
}
