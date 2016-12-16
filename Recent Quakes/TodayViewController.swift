//
//  TodayViewController.swift
//  Recent Quakes
//
//  Created by Tony Li on 10/12/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import NotificationCenter
import GeoNetAPI
import FormatterKit

@objc(TodayViewController)
class TodayViewController: UITableViewController, NCWidgetProviding {

    fileprivate var quakes = [Quake]() {
        didSet {
            tableView?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.rowHeight = 50
        refresh(completionHandler: nil)
    }

    func refresh(completionHandler: ((NCUpdateResult) -> Void)?) {
        URLSession.API.quakes(with: .moderate) { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .failure:
                completionHandler?(.failed)
            case .success(let quakes):
                let newData = self.quakes != quakes
                self.quakes = quakes.count > 2 ? Array(quakes[0...1]) : quakes
                completionHandler?(newData ? .newData : .noData)
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        refresh(completionHandler: completionHandler)
    }
    
}

extension TodayViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let quake = quakes[indexPath.row]
        cell.textLabel?.text = quake.locality
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = TTTTimeIntervalFormatter().stringForTimeInterval(from: Date(), to: quake.time)
        cell.detailTextLabel?.textColor = .darkGray

        if cell.accessoryView == nil {
            let magnitudeLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 28)))
            magnitudeLabel.font = .systemFont(ofSize: 15)
            magnitudeLabel.textColor = .white
            magnitudeLabel.textAlignment = .center
            magnitudeLabel.layer.masksToBounds = true
            magnitudeLabel.layer.cornerRadius = 4
            cell.accessoryView = magnitudeLabel
        }
        if let magnitudeLabel = (cell.accessoryView as? UILabel) {
            magnitudeLabel.text = String(format: "%.1f", quake.magnitude)
            magnitudeLabel.backgroundColor = quake.mmi.intensity.color
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO TBD
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
