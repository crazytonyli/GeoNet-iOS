//
//  NewsViewController.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit
import SafariServices
import MWFeedParser
import FormatterKit

private let RSSFeedURL = "https://info.geonet.org.nz/createrssfeed.action?types=blogpost&spaces=conf_all&title=GeoNet+News+RSS+Feed&labelString%3D&excludedSpaceKeys%3D&sort=created&maxResults=50&timeSpan=500&showContent=false&publicFeed=true&confirm=Create+RSS+Feed"

private class FeedCell: UITableViewCell {

    private static let intervalFormatter = TTTTimeIntervalFormatter()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 15)
        textLabel?.numberOfLines = 0
        detailTextLabel?.font = .italicSystemFont(ofSize: 11)
        detailTextLabel?.textColor = .lightGray
        accessoryType = .disclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with item: MWFeedItem) {
        textLabel?.text = item.title

        var detail = ""

        if let author = item.author {
            detail.append(author)
        }

        if let updated = item.updated,
            let interval = FeedCell.intervalFormatter.stringForTimeInterval(from: Date(), to: updated) {
            detail.append(" updated \(interval).")
        }

        detailTextLabel?.text = detail
    }

}

class NewsViewController: UITableViewController {

    fileprivate let parser: MWFeedParser = MWFeedParser(feedURL: URL(string: RSSFeedURL)!)
    fileprivate var parsingFeedItems: [MWFeedItem]?
    fileprivate var feedItems = [MWFeedItem]()

    init() {
        super.init(style: .plain)
        title = "News"
        parser.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(parse), for: .valueChanged)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(FeedCell.self, forCellReuseIdentifier: "cell")

        parse()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
        cell.update(with: feedItems[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: feedItems[indexPath.row].link) else { return }

        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }

}

private extension NewsViewController {

    @objc func parse() {
        guard !parser.isParsing else { return }

        DispatchQueue.global().async {
            self.parsingFeedItems = []
            if self.parser.parse() {
                self.feedItems = self.parsingFeedItems ?? []
            }

            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView?.reloadData()
            }
        }
    }

}

extension NewsViewController: MWFeedParserDelegate {

    func feedParser(_ parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        parsingFeedItems?.append(item)
    }

    func feedParserDidFinish(_ parser: MWFeedParser!) {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    func feedParser(_ parser: MWFeedParser!, didFailWithError error: Error!) {
        refreshControl?.endRefreshing()
    }

}
