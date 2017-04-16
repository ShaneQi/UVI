//
//  AppDelegate.swift
//  UVI
//
//  Created by Shane Qi on 3/9/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit
import UVIRealm

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
				self?.window?.rootViewController = HomeViewController.getInstance()
				self?.window?.makeKeyAndVisible()
			case .failure(let error):
				dump(error)
			}
		}

		return true
	}

}
