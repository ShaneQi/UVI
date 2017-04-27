//
//  StoryboardInstantiatable.swift
//  UVI
//
//  Created by Shane Qi on 3/19/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

protocol StoryboardInstantiatable {

	static var storyboardName: String { get }

	static func getInstance() -> Self

}

extension StoryboardInstantiatable {

	static var storyboardName: String {
		let className = String(describing: Self.self)
		let suffixBeginIndex = className.index(className.endIndex, offsetBy: -14)
		return className.substring(to: suffixBeginIndex)
	}

	static func getInstance() -> Self {
		guard let viewController =
			UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() as? Self
			else { fatalError("Failed to init the view controller from storyboard.") }
		return viewController
	}

}
