//
//  AppDelegate.swift
//  UVI
//
//  Created by Shane Qi on 3/9/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

var myself: Person!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication,
	                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow.init(frame: UIScreen.main.bounds)

		UVIRealm.default.launch { [weak self] result in
			switch result {
			case .success:
				var viewController: UIViewController
				if let userUid = UVIUserDefaults.default.userUid,
					let user = UVIRealm.default.realm.object(ofType: VisuallyImpaired.self, forPrimaryKey: userUid) {
					myself = user
					let viViewController = VIViewController.getInstance()
					viViewController.mode = .expanded
					viewController = viViewController
					print("vi logged in")
				} else if let userUid = UVIUserDefaults.default.userUid,
					let user = UVIRealm.default.realm.object(ofType: Driver.self, forPrimaryKey: userUid) {
					myself = user
					let driverViewController = DriverViewController.getInstance()
					viewController = driverViewController
					print("driver logged in")
				} else {
					viewController = HomeViewController.getInstance()
					print("asking name")
				}
				self?.window?.rootViewController = viewController
				self?.window?.makeKeyAndVisible()
			case .failure(let error):
				dump(error)
			}
		}

		return true
	}

}
