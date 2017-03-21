//
//  AppDelegate.swift
//  UVI
//
//  Created by Shane Qi on 3/9/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication,
	                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow.init(frame: UIScreen.main.bounds)
		window?.rootViewController = HomeViewController.getInstance()
		window?.makeKeyAndVisible()
		return true
	}

}
