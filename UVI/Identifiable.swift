//
//  Identifiable.swift
//  UVI
//
//  Created by Shane Qi on 4/17/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

protocol Identifiable: class {

	static var identifier: String { get }

}

extension Identifiable {

	static var identifier: String { return String(describing: Self.self) }

}
