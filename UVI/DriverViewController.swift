//
//  DriverViewController.swift
//  UVI
//
//  Created by Shane Qi on 4/18/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RealmSwift

final class DriverViewController: UIViewController, StoryboardInstantiatable {

	@IBOutlet var mapView: MKMapView!
	@IBOutlet var operateButton: UIButton!

	var pickupTasks: [PickupTask] = []
	var notificationToken: NotificationToken!

	var mode = Variable(Mode.none)
	let bag = DisposeBag()

	enum Mode {
		case none
		case selected(PickupTask)
		case accepted(PickupTask)
		case pickedUp(PickupTask)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.setRegion(
			MKCoordinateRegion(
				center: CLLocationCoordinate2D(latitude: 32.986586, longitude: -96.750285),
				span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)),
			animated: false)
		mapView.showsUserLocation = true
		notificationToken = UVIRealm.default.realm
			.objects(PickupTask.self)
			.filter("state == %@", 0)
			.addNotificationBlock({ [unowned self] change in
				switch change {
				case .initial(let results):
					results.forEach({ task in
						self.pickupTasks.append(task)
					})
					self.annotateTasks()
				case .update(let results, deletions: _, insertions: _, modifications: _):
					self.pickupTasks.removeAll()
					results.forEach({ task in
						self.pickupTasks.append(task)
					})
					self.annotateTasks()
				default:
					break
				}
			})
		mode.asObservable().subscribe(onNext: { [unowned self] mode in
			switch mode {
			case .none:
				self.operateButton.isHidden = true
			case .selected:
				self.operateButton.isHidden = false
				self.operateButton.setTitle("Accept", for: .normal)
			case .accepted:
				self.operateButton.isHidden = false
				self.operateButton.setTitle("Pickup", for: .normal)
			case .pickedUp:
				self.operateButton.isHidden = false
				self.operateButton.setTitle("Dropoff", for: .normal)
			}
		}).addDisposableTo(bag)
	}

	@IBAction func didTapOperateButton() {
		switch mode.value {
		case .selected(let task):
			try? UVIRealm.default.realm.write {
				task.state = 1
				task.driver = myself as? Driver
			}
			mode.value = .accepted(task)
		case .accepted(let task):
			try? UVIRealm.default.realm.write {
				task.state = 2
			}
			mode.value = .pickedUp(task)
		case .pickedUp(let task):
			try? UVIRealm.default.realm.write {
				task.state = 3
			}
			mode.value = .none
		default: break
		}
		annotateTasks()
	}

	private func annotateTasks() {
		mapView.removeAnnotations(mapView.annotations)
		switch mode.value {
		case .none, .selected:
			mapView.addAnnotations(pickupTasks
				.filter({
					return ($0.visuallyImpaired != nil && $0.state != 3)
				})
				.map({ UVIMapAnnotation($0) })
			)
		case .accepted(let task), .pickedUp(let task):
			mapView.addAnnotation(UVIMapAnnotation(task))
		}
	}

}

extension DriverViewController: MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let task = (view.annotation as? UVIMapAnnotation)?.task {
			mode.value = .selected(task)
		}
	}

}
