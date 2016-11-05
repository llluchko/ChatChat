//
//  ChatViewController.swift
//  ChatChat
//
//  Created by Latchezar Mladenov on 11/5/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {
  
    // MARK: Properties
	var channelRef: FIRDatabaseReference?
	var channel: Channel? {
		didSet {
			title = channel?.name
		}
	}
	var messages = [JSQMessage]()
	lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
	lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
	
    // MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.senderId = FIRAuth.auth()?.currentUser?.uid
		collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
		collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// messages from someone else
		addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
		// messages sent from local sender
		addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
		addMessage(withId: senderId, name: "Me", text: "I like to run!")
		// animates the receiving of a new message on the view
		finishReceivingMessage()
	}
	
    // MARK: Collection view data source (and related) methods
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return messages[indexPath.item]
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message = messages[indexPath.item]
		if message.senderId == senderId {
			return outgoingBubbleImageView
		} else {
			return incomingBubbleImageView
		}
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		let message = messages[indexPath.item]
		
		if message.senderId == senderId {
			cell.textView?.textColor = UIColor.white
		} else {
			cell.textView?.textColor = UIColor.black
		}
		return cell
	}
  
  
	// MARK: Firebase related methods


	// MARK: UI and User Interaction
	private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
		let bubbleImageFactory = JSQMessagesBubbleImageFactory()
		return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
	}
	
	private func setupIncomingBubble() -> JSQMessagesBubbleImage {
		let bubbleImageFactory = JSQMessagesBubbleImageFactory()
		return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
		
	}

	private func addMessage(withId id: String, name: String, text: String) {
		if let message = JSQMessage(senderId: id, displayName: name, text: text) {
			messages.append(message)
		}
	}


	// MARK: UITextViewDelegate methods
	
}
