//
//  UVISounds.swift
//  UVI
//
//  Created by Shane Qi on 4/16/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import Foundation

class UVISounds {

	private init() {}

	static let `default` = UVISounds()

	var mayIHaveYourName: URL {
		return URL(fileURLWithPath: filePath(ofName: "may_I_have_your_name", ofType: "mp3"))
	}

	private func filePath(ofName name: String, ofType type: String) -> String {
		guard let filePath = Bundle.main.path(forResource: name, ofType: type) else {
			fatalError("Couldn't find resource of name `\(name)` in type `\(type)`")
		}
		return filePath
	}

}
