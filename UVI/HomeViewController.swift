//
//  HomeViewController.swift
//  UVI
//
//  Created by Shane Qi on 3/18/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import RxSwift

final class HomeViewController: UIViewController, StoryboardInstantiatable {

	var viViewController = VIViewController.getInstance()
	@IBOutlet var viView: UIView!
	@IBOutlet var viViewCollapsingConstraint: NSLayoutConstraint!
	@IBOutlet var viViewHeightExpandingConstraint: NSLayoutConstraint!

	private var name: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		requestSpeechAuthorization()
		askForName()
	}

	private func setupUI() {
		// Add vi view controller as child view controller.
		viViewController.didTapWhenCollapsed = { [unowned self] in
			if myself is Driver {
				return
			} else if myself == nil {
				guard let name = self.name else {
					return
				}
				let vi = VisuallyImpaired()
				vi.uid = UUID().uuidString
				vi.name = name
				try? UVIRealm.default.realm.write {
					UVIRealm.default.realm.add(vi)
				}
				myself = vi
				UVIUserDefaults.default.userUid = vi.uid
			}
			self.viViewCollapsingConstraint.isActive = false
			self.viViewHeightExpandingConstraint.isActive = true
			self.view.layoutIfNeeded()
		}
		addChildViewController(viViewController)
		view.addSubview(viViewController.view)
		viViewController.didMove(toParentViewController: self)
	}

	private func gotoDriverViewController() {
		let driverViewController = DriverViewController.getInstance()
		show(driverViewController, sender: nil)
	}

	private func gotoRemindersViewController() {
		let remindersViewController = RemindersViewController.getInstance()
		present(UINavigationController(rootViewController: remindersViewController), animated: true, completion: nil)
	}

	private func requestSpeechAuthorization() {
		SFSpeechRecognizer.requestAuthorization { authStatus in
			switch authStatus {
			case .authorized: break
			default:
				fatalError()
			}
		}
	}

	fileprivate let audioEngine = AVAudioEngine()
	private var avAudioPlayer: AVAudioPlayer!
	fileprivate var speechBag = DisposeBag()

	private func askForName() {
		do {
			avAudioPlayer = try AVAudioPlayer.init(contentsOf: UVISounds.default.mayIHaveYourName)
			avAudioPlayer.prepareToPlay()
			avAudioPlayer.play()
			avAudioPlayer.delegate = self
		} catch {}
	}

	fileprivate func handleWords(_ words: [String]) {
		guard words.count > 0 else {
			return
		}

		name = words.prefix(2).joined(separator: " ").capitalized
		speechBag = DisposeBag()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viViewController.view.frame = viView.frame
	}

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

	@IBAction func didTapDriverButton() {
		if myself is VisuallyImpaired { return }
		if myself is Driver {
			gotoDriverViewController()
			return
		}
		guard let name = self.name else {
			askForName()
			return
		}
		let driver = Driver()
		driver.uid = UUID().uuidString
		driver.name = name
		try? UVIRealm.default.realm.write {
			UVIRealm.default.realm.add(driver)
		}
		myself = driver
		UVIUserDefaults.default.userUid = driver.uid
		gotoDriverViewController()
	}

	@IBAction func didTapAssistantButton() {
		if myself is Driver { return }
		if myself is VisuallyImpaired {
			gotoDriverViewController()
			return
		}
		guard let name = self.name else {
			return
		}
		let vi = VisuallyImpaired()
		vi.uid = UUID().uuidString
		vi.name = name
		try? UVIRealm.default.realm.write {
			UVIRealm.default.realm.add(vi)
		}
		myself = vi
		UVIUserDefaults.default.userUid = vi.uid
		gotoRemindersViewController()
	}

}

extension HomeViewController: AVAudioPlayerDelegate {

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		let defaultName = ["James", "Bond"]
		do {
			try SFSpeechAudioBufferRecognitionRequest().rx.listen(on: audioEngine)
				.catchErrorJustReturn(defaultName)
				.debounce(0.5, scheduler: MainScheduler.instance)
				.subscribe(onNext: { [weak self] words in
					guard let strongSelf = self else { return }
					strongSelf.handleWords(words)
				}).addDisposableTo(speechBag)
		} catch {
			handleWords(defaultName)
		}
	}

}
