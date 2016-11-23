//
//  QuakesViewController.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit

class QuakesViewController: UITableViewController {

    weak var loadQuakesTask: URLSessionTask? {
        willSet {
            loadQuakesTask?.cancel()
        }
    }

    var quakes = [Quake]() {
        didSet {
            tableView?.reloadData()
        }
    }

    var titleTapGestureRecognizer: UITapGestureRecognizer?

    init() {
        super.init(style: .plain)
        title = "Quakes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadQuakes), for: .valueChanged)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsetsMake(0, QuakeInfoTableViewCell.intensityIndicatorWidth, 0, 0)
        tableView.register(QuakeInfoTableViewCell.self, forCellReuseIdentifier: "cell")

        loadQuakes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if titleTapGestureRecognizer == nil {
            titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showIntensitySelection))
            self.navigationController?.navigationBar.addGestureRecognizer(titleTapGestureRecognizer!)
        }
        titleTapGestureRecognizer?.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        titleTapGestureRecognizer?.isEnabled = false
    }

}

extension QuakesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuakeInfoTableViewCell
        cell.update(with: quakes[indexPath.row])
        return cell
    }

}

private extension QuakesViewController {

    @objc func showIntensitySelection() {
        let controller = IntensitiesViewController(intensity: UserDefaults.app.selectedIntensity ?? .weak)
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.sourceView = self.navigationController!.navigationBar
        controller.popoverPresentationController?.sourceRect = self.navigationController!.navigationBar.bounds.insetBy(dx: 0, dy: 8)
        present(controller, animated: true, completion: nil)

        controller.selectionChange = { [unowned self] intensity in
            self.dismiss(animated: true, completion: nil)
            UserDefaults.app.selectedIntensity = intensity
            self.quakes = []
            self.loadQuakes()
        }
    }

    @objc func loadQuakes() {
        let intensity = UserDefaults.app.selectedIntensity ?? .weak
        guard let mmi = QuakeMMI(rawValue: intensity.MMIRange.lowerBound) else {
            return
        }

        navigationItem.title = "Quake (\(intensity.description)+)"

        loadQuakesTask = APISession().quakes(with: mmi) { [weak self] result in
            guard let `self` = self else { return }
            self.refreshControl?.endRefreshing()
            switch result {
            case .success(let quakes): self.quakes = quakes
            case .failure(let error): break
            }
        }
    }

}

extension QuakesViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
