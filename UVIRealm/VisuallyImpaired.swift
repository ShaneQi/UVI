//
//  VI.swift
//  UVI
//
//  Created by Shane Qi on 4/11/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import RealmSwift

public class VisuallyImpaired: Object, Person {

	public dynamic var uid: String = ""
	public dynamic var name: String = ""
	public dynamic var latitude: Double = 0
	public dynamic var longitude: Double = 0

	override public static func primaryKey() -> String? {
		return "uid"
	}

}

//class Driver: Object, Person {
//
//	dynamic var uid: String = ""
//	dynamic var name: String = ""
//	dynamic var latitude: Double = 0
//	dynamic var longitude: Double = 0
//
//}
//
//class PickupTask: Object {
//
//	enum State: Int {
//		case submitted = 0
//	}
//
//	dynamic var visuallyImpaired: VisuallyImpaired?
//	dynamic var driver: Driver?
//	dynamic var state: Int = State.submitted.rawValue
//	dynamic var destination = Destination()
//
//}
//
//class Destination: Object {
//
//	dynamic var uid: String = ""
//	dynamic var title: String = ""
//	dynamic var subtitle: String = ""
//	dynamic var latitude: Double = 0
//	dynamic var longitude: Double = 0
//
//}

public protocol Person {

	var uid: String { get }
	var name: String { get }
	var latitude: Double { get set }
	var longitude: Double { get set }

}
