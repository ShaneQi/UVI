//
//  RemindersViewController.swift
//  UVI
//
//  Created by Shane Qi on 4/23/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

final class RemindersViewController: UIViewController, StoryboardInstantiatable {

	@IBOutlet var tableView: UITableView!

	var token: NotificationToken?
	var reminders: [Reminder] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4117647059, green: 0.7450980392, blue: 0.1568627451, alpha: 1)
		let textAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		token = UVIRealm.default.realm.objects(Reminder.self)
		.filter("owner == %@", myself)
			.addNotificationBlock({ result in
				switch result {
				case .initial(let reminders):
					UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
					self.reminders.removeAll()
					reminders.forEach({
						self.reminders.append($0)
						self.addNotification(from: $0)
					})
				case .update(let reminders, deletions: _, insertions: _, modifications: _):
					UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
					self.reminders.removeAll()
					reminders.forEach({
						self.reminders.append($0)
						self.addNotification(from: $0)
					})
				default:
					break
				}
				self.tableView.reloadData()
			})
	}

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

	private func addNotification(from reminder: Reminder) {
		let content = UNMutableNotificationContent()
		content.body = reminder.title

		let interval = (reminder.time as Date).timeIntervalSince(Date())
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)

		// Schedule the notification.
		let request = UNNotificationRequest(
			identifier: reminder.uid,
			content: content,
			trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}

	@IBAction func didTapBackButton() {
		self.dismiss(animated: true, completion: nil)
	}

}

extension RemindersViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reminders.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = (tableView
			.dequeueReusableCell(withIdentifier: RemindersTableViewCell.identifier)
			as? RemindersTableViewCell)!
		let reminder = reminders[indexPath.row]
		cell.titleLabel.text = reminder.title
		cell.timeLabel.text = "\(reminder.time)"
		cell.frequencyLabel.text = "\(reminder.frequency)"
		return cell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}

}

extension RemindersViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = #colorLiteral(red: 0.4117647059, green: 0.7450980392, blue: 0.1568627451, alpha: 1)
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = .white
	}

}
