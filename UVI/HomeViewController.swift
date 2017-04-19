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
		if let userUid = UVIUserDefaults.default.userUid,
			let user = UVIRealm.default.realm.object(ofType: VisuallyImpaired.self, forPrimaryKey: userUid) {
			myself = user
			viViewController.didTapMainButton()
			print("vi logged in")
		} else if let userUid = UVIUserDefaults.default.userUid,
			let user = UVIRealm.default.realm.object(ofType: Driver.self, forPrimaryKey: userUid) {
			myself = user
			gotoDriverViewController()
			print("driver logged in")
		} else {
			askForName()
			print("asking name")
		}
	}

	private func setupUI() {
		// Add vi view controller as child view controller.
		viViewController.didTapWhenCollapsed = { [unowned self] in
			DispatchQueue.main.async(execute: {
				self.viViewCollapsingConstraint.isActive = false
				self.viViewHeightExpandingConstraint.isActive = true
				self.view.layoutIfNeeded()
			})
			if myself == nil {
				guard let name = self.name else {
					self.askForName()
					return
				}
				let vi = Driver()
				vi.uid = UUID().uuidString
				vi.name = name
				try? UVIRealm.default.realm.write {
					UVIRealm.default.realm.add(vi)
				}
				UVIUserDefaults.default.userUid = vi.uid
			} else {
				return
			}
		}
		addChildViewController(viViewController)
		view.addSubview(viViewController.view)
		viViewController.didMove(toParentViewController: self)
	}

	private func gotoDriverViewController() {
		let driverViewController = DriverViewController.getInstance()
		show(driverViewController, sender: nil)
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
		UVIUserDefaults.default.userUid = driver.uid
		gotoDriverViewController()
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
