//
//  VolcanoesViewController.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit

class VolcanoesViewController: GeoNetViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Volcanoes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
