//
//  InkLayer.swift
//  UVI
//
//  Created by Shane Qi on 3/23/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

class InkLayer: CAShapeLayer {

	let animation = CABasicAnimation()

	override init() {
		super.init()
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	private func setup() {
		fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4).cgColor
		path = CGPath(
			ellipseIn: .init(origin: .zero,
			                 size: .init(width: 150, height: 150)),
			transform: nil)
		frame.size = .init(width: 150, height: 150)
		animation.keyPath = "transform.scale"
		animation.fromValue = 0.05
		animation.toValue = 1
		animation.duration = 0.3
		animation.isRemovedOnCompletion = true
	}

	///  Implicitly animation disabled.
	func move(to point: CGPoint) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		frame.origin = .init(x: point.x - 75, y: point.y - 75)
		CATransaction.commit()
	}

	func startAnimating() {
		add(animation, forKey: nil)
	}

}
