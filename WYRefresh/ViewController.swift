//
//  ViewController.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/15.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    let data = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self;
        tableView.delegate = self;
        self.view.addSubview(tableView);

        (10..<30).forEach({ (i) in
            data.add(String(format: "%ld", Int(i)))
        })

        self.view.addSubview({
            let arrowView = WYPullArrowView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: WYPullArrowView.viewSize))
            arrowView.backgroundColor = UIColor.clear
            return arrowView
            }())
    }

    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count

    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        }
        cell?.textLabel?.text = data.object(at: indexPath.row) as? String
        return cell!;
    }
}
