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
import UVIRealm
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
			let user = UVIRealm.default.visuallyImpaired(fromUid: userUid) {
			myself = user
		} else {
			askForName()
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
		try? UVIRealm.default.new(vi)
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
				.buffer(timeSpan: 3, count: 100, scheduler: MainScheduler.instance)
				.subscribe(onNext: { [weak self] wordsArray in
					guard let strongSelf = self else { return }
					if let words = wordsArray.last {
						strongSelf.handleWords(words)
					}
				}).addDisposableTo(speechBag)
		} catch {
			handleWords(defaultName)
		}
	}

}
