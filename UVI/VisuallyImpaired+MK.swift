//
//  VisuallyImpaired+MK.swift
//  UVI
//
//  Created by Shane Qi on 4/18/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import MapKit

class UVIMapAnnotation: NSObject, MKAnnotation {

	init(_ pickupTask: PickupTask) {
		self.task = pickupTask
		self.coordinate = pickupTask.coordinate
		self.title = pickupTask.visuallyImpaired?.name
		super.init()
	}

	var task: PickupTask?
	var visuallyImpaired: VisuallyImpaired?

	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?

}

extension VisuallyImpaired {

	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(
			latitude: latitude,
			longitude: longitude)
	}

}

extension PickupTask {

	var coordinate: CLLocationCoordinate2D {
		return visuallyImpaired?.coordinate ??
			CLLocationCoordinate2D(
				latitude: 0,
				longitude: 0)
	}

}
