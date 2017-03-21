//
//  HomeViewController.swift
//  UVI
//
//  Created by Shane Qi on 3/18/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController, StoryboardInstantiatable {

	var viViewController = VIViewController.getInstance()
	@IBOutlet var viView: UIView!
	@IBOutlet var viViewCollapsingConstraint: NSLayoutConstraint!
	@IBOutlet var viViewHeightExpandingConstraint: NSLayoutConstraint!

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()

	}

	private func setupUI() {
		viViewController.didTapWhenCollapsed = { [unowned self] in
			self.viViewCollapsingConstraint.isActive = false
			self.viViewHeightExpandingConstraint.isActive = true
			self.view.layoutIfNeeded()
		}
		addChildViewController(viViewController)
		view.addSubview(viViewController.view)
		viViewController.didMove(toParentViewController: self)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viViewController.view.frame = viView.frame
	}

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

}
