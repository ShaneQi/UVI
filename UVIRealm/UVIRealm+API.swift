//
//  UVIRealm+API.swift
//  UVI
//
//  Created by Shane Qi on 4/16/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

extension UVIRealm {

	public func new(_ visuallyImpaired: VisuallyImpaired) throws {
		try realm.write {
			realm.add(visuallyImpaired)
		}
	}

	public func visuallyImpaired(fromUid uid: String) -> VisuallyImpaired? {
		return realm.object(ofType: VisuallyImpaired.self, forPrimaryKey: uid)
	}

}
