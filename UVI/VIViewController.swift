//
//  VIViewController.swift
//  UVI
//
//  Created by Shane Qi on 3/19/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

final class VIViewController: UIViewController, StoryboardInstantiatable {

	enum Mode { case collapsed, expanded }
	var mode: Mode = .collapsed

	@IBOutlet var viIconImageView: UIImageView!
	let touchIndicator = CAShapeLayer()
	let touchIndicatorAnimation = CABasicAnimation()

	var didTapWhenCollapsed: (() -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		touchIndicator.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4).cgColor
		touchIndicator.path = CGPath(
			ellipseIn: .init(origin: .zero,
			                 size: .init(width: 150, height: 150)),
			transform: nil)
		touchIndicator.frame.size = .init(width: 150, height: 150)
		touchIndicatorAnimation.keyPath = "transform.scale"
		touchIndicatorAnimation.fromValue = 0.05
		touchIndicatorAnimation.toValue = 1
		touchIndicatorAnimation.duration = 0.3
		touchIndicatorAnimation.isRemovedOnCompletion = true

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		switch mode {
		case .collapsed:
			viIconImageView.center = .init(x: view.frame.width / 2, y: view.frame.height / 2)
			viIconImageView.frame.size = .init(width: view.frame.height / 2, height: view.frame.height / 2)
		case .expanded:
			viIconImageView.frame = .init(
				origin: .init(x: 20, y: view.frame.height - 20 - 40),
				size: .init(width: 40, height: 40))
		}
	}

	@IBAction func didTapMainButton(_ sender: UIButton) {
		switch mode {
		case .collapsed:
			UIView.animate(withDuration: 0.5, animations: {
				self.mode = .expanded
				self.didTapWhenCollapsed?()
				self.view.layoutIfNeeded()
			})
		case .expanded:
			touchIndicator.removeFromSuperlayer()
			break
		}
	}

	@IBAction func didTouchDownButton(_ sender: UIButton, event: UIEvent) {
		guard let touchPoint = event.touches(for: sender)?.first?.location(in: sender),
			mode == .expanded else { return }
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		touchIndicator.frame.origin = .init(x: touchPoint.x - 75, y: touchPoint.y - 75)

		CATransaction.commit()

		touchIndicator.add(touchIndicatorAnimation, forKey: nil)
		sender.layer.addSublayer(touchIndicator)
	}

}
