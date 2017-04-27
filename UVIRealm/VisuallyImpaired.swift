//
//  VI.swift
//  UVI
//
//  Created by Shane Qi on 4/11/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import RealmSwift

class VisuallyImpaired: Object, Person {

	dynamic var uid: String = ""
	dynamic var name: String = ""
	dynamic var latitude: Double = 0
	dynamic var longitude: Double = 0

	override static func primaryKey() -> String? {
		return "uid"
	}

}

class Driver: Object, Person {

	dynamic var uid: String = ""
	dynamic var name: String = ""
	dynamic var latitude: Double = 0
	dynamic var longitude: Double = 0

	override static func primaryKey() -> String? {
		return "uid"
	}

}

class PickupTask: Object {

	enum State: Int {
		case submitted = 0
		case accepted
		case pickedUp
		case droppedOff
	}

	dynamic var visuallyImpaired: VisuallyImpaired?
	dynamic var driver: Driver?
	dynamic var state: Int = State.submitted.rawValue
	dynamic var destination: Destination?

}

class Destination: Object {

	dynamic var uid: String = ""
	dynamic var title: String = ""
	dynamic var subtitle: String = ""
	dynamic var latitude: Double = 0
	dynamic var longitude: Double = 0

}

protocol Person {

	var uid: String { get }
	var name: String { get }
	var latitude: Double { get set }
	var longitude: Double { get set }

}

class Reminder: Object {

	dynamic var owner: VisuallyImpaired?
	dynamic var uid: String = UUID().uuidString
	dynamic var title: String = ""
	dynamic var time = NSDate()
	dynamic var frequency: Int = 1

	override static func primaryKey() -> String? {
		return "uid"
	}

}
