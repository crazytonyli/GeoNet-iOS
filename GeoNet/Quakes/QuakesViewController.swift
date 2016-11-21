//
//  QuakesViewController.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit

class QuakesViewController: GeoNetViewController {

    var tableView: UITableView?

    var quakes = [Quake]() {
        didSet {
            tableView?.reloadData()
        }
    }

    var titleTapGestureRecognizer: UITapGestureRecognizer?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Quakes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsetsMake(0, QuakeInfoTableViewCell.intensityIndicatorWidth, 0, 0)
        tableView.register(QuakeInfoTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        self.tableView = tableView

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])

        loadQuakes(with: UserDefaults.app.selectedIntensity ?? .weak)
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

extension QuakesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            self.loadQuakes(with: intensity)
        }
    }

    func updateTitle(with intensity: QuakeIntensity) {

    }

    func loadQuakes(with intensity: QuakeIntensity) {
        guard let mmi = QuakeMMI(rawValue: intensity.MMIRange.lowerBound) else {
            return
        }

        navigationItem.title = "Quake (\(intensity.description)+)"

        APISession().quakes(with: mmi) { [weak self] result in
            guard let `self` = self else { return }
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
