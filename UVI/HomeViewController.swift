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

	let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
	private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
	private var recognitionTask: SFSpeechRecognitionTask?
	private let audioEngine = AVAudioEngine()

	var avAudioPlayer: AVAudioPlayer!

	private func askForName() {
		do {
			avAudioPlayer = try AVAudioPlayer.init(contentsOf: UVISounds.default.mayIHaveYourName)
			avAudioPlayer.prepareToPlay()
			avAudioPlayer.play()
			avAudioPlayer.delegate = self
		} catch {}
	}

	fileprivate func listenToName() {

		if recognitionTask != nil {
			recognitionTask?.cancel()
			recognitionTask = nil
		}

		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryRecord)
			try audioSession.setMode(AVAudioSessionModeMeasurement)
			try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
		} catch {
			print("audioSession properties weren't set because of an error.")
		}

		guard let inputNode = audioEngine.inputNode else {
			fatalError("Audio engine has no input node")
		}

		recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [unowned self] result, _ in

			var isFinal = result?.isFinal ?? true

			if let result = result {
				let transcription = result.bestTranscription
				let words = transcription.segments.flatMap({ $0.substring })
				isFinal = self.handleWords(words)
			}

			if isFinal {
				self.audioEngine.stop()
				inputNode.removeTap(onBus: 0)

				self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
				self.recognitionTask = nil

			}

		}

		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
			self.recognitionRequest.append(buffer)
		}

		audioEngine.prepare()

		do {
			try audioEngine.start()
		} catch {
			print("audioEngine couldn't start because of an error.")
		}

	}

	private func handleWords(_ words: [String]) -> Bool {
		guard words.count > 0 else {
			return false
		}
		let userName = words.prefix(2).joined(separator: " ")
		let vi = VisuallyImpaired()
		vi.uid = UUID().uuidString
		vi.name = userName
		try? UVIRealm.default.new(vi)
		myself = vi
		return true
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viViewController.view.frame = viView.frame
	}

	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

}

extension HomeViewController: AVAudioPlayerDelegate {

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		listenToName()
	}

}
