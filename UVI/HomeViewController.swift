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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		requestSpeechAuthorization()
		if let userUid = UVIUserDefaults.default.userUid,
			let user = UVIRealm.default.realm.object(ofType: VisuallyImpaired.self, forPrimaryKey: userUid) {
			myself = user
			print("logged in")
		} else {
			askForName()
			print("asking name")
		}
	}

	private func setupUI() {
		// Add vi view controller as child view controller.
		viViewController.didTapWhenCollapsed = { [unowned self] in
			self.viViewCollapsingConstraint.isActive = false
			self.viViewHeightExpandingConstraint.isActive = true
			self.view.layoutIfNeeded()
		}
		addChildViewController(viViewController)
		view.addSubview(viViewController.view)
		viViewController.didMove(toParentViewController: self)
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
		let uid = UUID().uuidString
		let userName = words.prefix(2).joined(separator: " ").capitalized
		let vi = VisuallyImpaired()
		vi.uid = uid
		vi.name = userName

		try? UVIRealm.default.realm.write {
			UVIRealm.default.realm.add(vi)
		}

		myself = vi
		UVIUserDefaults.default.userUid = uid
		speechBag = DisposeBag()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viViewController.view.frame = viView.frame
	}

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

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
