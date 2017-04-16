//
//  UVIUserDefaults.swift
//  UVI
//
//  Created by Shane Qi on 4/13/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

class UVIUserDefaults {

	private init() {}

	static let `default` = UVIUserDefaults()

	var userUid: String? {
		get { return value(forKey: #function) as? String }
		set { setValue(newValue, forKey: #function) }
	}

	private func value(forKey key: String) -> Any? {
		return UserDefaults.standard.value(forKey: #function)
	}

	private func setValue(_ value: Any?, forKey key: String) {
		UserDefaults.standard.setValue(value, forKey: key)
		UserDefaults.standard.synchronize()
	}

}
