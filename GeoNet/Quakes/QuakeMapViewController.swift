//
//  QuakeMapViewController.swift
//  GeoNet
//
//  Created by Tony Li on 4/12/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import Foundation
import MapKit
import GeoNetAPI

class QuakeMapViewController: UIViewController {

    private let quake: Quake
    private var mapView: MKMapView?

    init(quake: Quake) {
        self.quake = quake
        super.init(nibName: nil, bundle: nil)
        title = "Quake Detail"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView(frame: view.bounds)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.setRegion(MKCoordinateRegion(center: quake.epicenter,
                                              span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)),
                           animated: true)
        view.addSubview(mapView!)

        let infoView = QuakeInfoView(frame: .zero)
        infoView.update(with: quake)
        view.addSubview(infoView)

        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        infoView.insertSubview(effectView, at: 0)

        infoView.translatesAutoresizingMaskIntoConstraints = false
        effectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            infoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            infoView.rightAnchor.constraint(equalTo: view.rightAnchor),

            effectView.topAnchor.constraint(equalTo: infoView.topAnchor),
            effectView.leftAnchor.constraint(equalTo: infoView.leftAnchor),
            effectView.rightAnchor.constraint(equalTo: infoView.rightAnchor),
            effectView.bottomAnchor.constraint(equalTo: infoView.bottomAnchor),
            ])

        let epicenter = MKPointAnnotation()
        epicenter.coordinate = quake.epicenter
        epicenter.title = quake.locality
        mapView?.addAnnotation(epicenter)
        mapView?.selectAnnotation(epicenter, animated: false)
    }

}

extension QuakeMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: "epicenter") as? MKPinAnnotationView
            ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "epicenter")
        pin.annotation = annotation
        pin.pinTintColor = MKPinAnnotationView.redPinColor()
        return pin
    }

}
