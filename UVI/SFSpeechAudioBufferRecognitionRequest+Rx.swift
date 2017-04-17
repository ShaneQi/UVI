//
//  UVISpeech.swift
//  UVI
//
//  Created by Shane Qi on 4/16/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import Speech
import RxSwift

extension Reactive where Base: SFSpeechAudioBufferRecognitionRequest {

	func listen(on audioEngine: AVAudioEngine) throws -> Observable<[String]> {

		let audioSession = AVAudioSession.sharedInstance()
		try audioSession.setCategory(AVAudioSessionCategoryRecord)
		try audioSession.setMode(AVAudioSessionModeMeasurement)
		try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

		guard let inputNode = audioEngine.inputNode else {
			throw "Audio engine has no input node"
		}

		return Observable.create { observer in

			let recognitionTask = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
				.recognitionTask(with: self.base) { [unowned audioEngine] result, _ in

				if let result = result {
					let transcription = result.bestTranscription
					let words = transcription.segments.flatMap({ $0.substring })
					observer.onNext(words)
				}

				if result?.isFinal ?? true {
					audioEngine.stop()
					inputNode.removeTap(onBus: 0)
					observer.on(.completed)
				}

			}

			let recordingFormat = inputNode.outputFormat(forBus: 0)
			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
				self.base.append(buffer)
			}

			audioEngine.prepare()

			do {
				try audioEngine.start()
			} catch {
				observer.onError("audioEngine couldn't start because of an error.")
			}

			return Disposables.create {
				recognitionTask.cancel()
			}
		}
	}

}
