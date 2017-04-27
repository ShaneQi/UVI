//
//  NewReminderViewController.swift
//  UVI
//
//  Created by Shane Qi on 4/23/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit

class NewReminderViewController: UIViewController {

	@IBOutlet var titleTextField: UITextField!
	@IBOutlet var frequencyTextField: UITextField!
	@IBOutlet var datePicker: UIDatePicker!

	@IBAction func didTapSaveButton() {
		let reminder = Reminder()
		reminder.title = titleTextField.text ?? "Reminder"
		reminder.time = datePicker.date as NSDate
		reminder.frequency = Int(frequencyTextField.text ?? "1") ?? 1
		reminder.owner = myself as? VisuallyImpaired
		try? UVIRealm.default.realm.write {
			UVIRealm.default.realm.add(reminder)
			self.navigationController?.popToRootViewController(animated: true)
		}
	}

	@IBAction func dismissKeyboard() {
		view.endEditing(true)
	}

}
