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
		navigationController?.navigationBar.tintColor = .white
		let textAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		token = UVIRealm.default.realm.objects(Reminder.self)
			.filter("owner == %@", myself)
			.addNotificationBlock({ result in
				switch result {
				case .initial(let reminders),
				     .update(let reminders, deletions: _, insertions: _, modifications: _):
					self.handle(reminderResult: reminders)
				default:
					break
				}
				self.tableView.reloadData()
			})
	}

	private func handle(reminderResult: Results<Reminder>) {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		self.reminders.removeAll()
		reminderResult.forEach({
			guard ($0.time as Date).timeIntervalSince(Date()) > 0 else { return }
			self.reminders.append($0)
			self.addNotification(from: $0)
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

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM. dd, yyyy HH:mm"
		cell.timeLabel.text = dateFormatter.string(from: reminder.time as Date)
		cell.frequencyLabel.text = "every \(reminder.frequency) days"
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
