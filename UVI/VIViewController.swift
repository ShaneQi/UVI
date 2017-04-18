//
//  VIViewController.swift
//  UVI
//
//  Created by Shane Qi on 3/19/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import UIKit
import UVIComponents
import RxSwift
import Speech

final class VIViewController: UIViewController, StoryboardInstantiatable {

	enum Mode { case collapsed, expanded }
	var mode: Mode = .collapsed

	@IBOutlet var viIconImageView: UIImageView!
	@IBOutlet var conversationTableView: UITableView!
	let touchIndicator = InkLayer()

	var didTapWhenCollapsed: (() -> Void)?

	let bag = DisposeBag()
	var speechBag = DisposeBag()
	var audioEngine = AVAudioEngine()

	var input: [String] = []
	var conversation: [Message] = []

	enum Message {
		case incoming(String)
		case outgoing(String)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		switch mode {
		case .collapsed:
			viIconImageView.center = .init(x: view.frame.width / 2, y: view.frame.height / 2)
			viIconImageView.frame.size = .init(width: view.frame.height / 2, height: view.frame.height / 2)
		case .expanded:
			viIconImageView.frame = .init(
				origin: .init(x: 20, y: view.frame.height - 20 - 40),
				size: .init(width: 40, height: 40))
		}
	}

	@IBAction func didTapMainButton(_ sender: UIButton) {
		switch mode {
		case .collapsed:
			UIView.animate(withDuration: 0.5, animations: {
				self.mode = .expanded
				self.didTapWhenCollapsed?()
				self.view.layoutIfNeeded()
			})
		case .expanded:
			touchIndicator.removeFromSuperlayer()
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
				self?.speechBag = DisposeBag()
				self?.handleInput()
			})
		}
	}

	@IBAction func didTouchDownButton(_ sender: UIButton, event: UIEvent) {
		guard let touchPoint = event.touches(for: sender)?.first?.location(in: sender),
			mode == .expanded else { return }
		touchIndicator.move(to: touchPoint)
		sender.layer.addSublayer(touchIndicator)
		touchIndicator.startAnimating()
		try? SFSpeechAudioBufferRecognitionRequest().rx.listen(on: audioEngine)
			.subscribe(onNext: { [unowned self] words in
				self.input = words
			}).addDisposableTo(speechBag)
	}

	private func handleInput() {
		guard input.count > 0 else { return }
		dump(input)
		addMessage(.outgoing(input.joined(separator: " ")))
		addMessage(.incoming("Get it"))
		input = []
	}

	private func addMessage(_ message: Message) {
		conversation.append(message)
		conversationTableView.insertRows(
			at: [IndexPath(row: conversation.count - 1, section: 0)],
			with: .bottom)
		conversationTableView.scrollToRow(
			at: IndexPath(row: conversation.count - 1, section: 0),
			at: .bottom, animated: true)
	}

}

extension VIViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return conversation.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let message = conversation[indexPath.row]
		guard let cell = tableView
			.dequeueReusableCell(withIdentifier: VIConversationTableViewCell.identifier)
			as? VIConversationTableViewCell else {
			fatalError()
		}
		switch message {
		case .incoming(let text):
			cell.mainTextLabel.text = text
			cell.mainTextLabel.textAlignment = .left
		case .outgoing(let text):
			cell.mainTextLabel.text = text
			cell.mainTextLabel.textAlignment = .right
		}
		return cell
	}

}
