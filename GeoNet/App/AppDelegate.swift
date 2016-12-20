//
//  AppDelegate.swift
//  GeoNet
//
//  Created by Tony Li on 18/11/16.
//  Copyright © 2016 Tony Li. All rights reserved.
//

import UIKit

enum AppTab {

    case Quakes
    case Shaking
    case ReportShaking
    case Volcanoes
    case News

    var tabName: String {
        switch self {
        case .Quakes: return "Quakes"
        case .Shaking: return "Shaking"
        case .ReportShaking: return "Felt It?"
        case .Volcanoes: return "Volcanoes"
        case .News: return "News"
        }
    }

    var viewController: UIViewController.Type {
        switch self {
        case .Quakes: return QuakesViewController.self
        case .Shaking: return ShakingViewController.self
        case .ReportShaking: return ReportShakingViewController.self
        case .Volcanoes: return VolcanoesViewController.self
        case .News: return NewsViewController.self
        }
    }

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var selectedNavigationController: UINavigationController {
        // swiftlint:disable force_cast
        return (window?.rootViewController as! UITabBarController).selectedViewController as! UINavigationController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let tab = GeoNetTabBarController()
        tab.viewControllers = [AppTab.Quakes, .Shaking, .ReportShaking, .Volcanoes, .News]
            .map { tab in
                let controller = GeoNetNavigationController(rootViewController: tab.viewController.init())
                controller.tabBarItem = UITabBarItem(title: tab.tabName, image: nil, tag: 0)
                return controller
            }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = tab
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let quakeIdentifier = (url.host == "quake" && url.pathComponents.count == 2 ? url.pathComponents.last : nil) {
            // TODO show & hide HUD
            URLSession.API.quake(quakeIdentifier) {
                if case .success(let quake) = $0 {
                    self.selectedNavigationController.pushViewController(QuakeMapViewController(quake: quake), animated: true)
                }
            }

            return true
        }

        return false
    }

}
