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
	private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
	private var newMessageRefHandle: FIRDatabaseHandle?
	private lazy var userIsTypingRef: FIRDatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId)
	private var localTyping = false
	var isTyping: Bool {
		get {
			return localTyping
		}
		set {
			localTyping = newValue
			userIsTypingRef.setValue(newValue)
		}
	}
	private lazy var usersTypingQuery: FIRDatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
	
    // MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.inputToolbar.contentView.leftBarButtonItem = nil
		self.senderId = FIRAuth.auth()?.currentUser?.uid
		collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
		collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
		observeMessages()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		observeTyping()
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
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
		let itemRef = messageRef.childByAutoId()
		let messageItem = [
			"senderId": senderId!,
			"senderName": senderDisplayName!,
			"text": text!,
		]
		
		itemRef.setValue(messageItem)
		JSQSystemSoundPlayer.jsq_playMessageSentSound()
		finishSendingMessage()
		isTyping = false
	}
	
	private func observeMessages() {
		messageRef = channelRef!.child("messages")
		
		let messageQuery = messageRef.queryLimited(toLast: 25)
		
		// We can use the observe method to listen for new
		// messages being written to the Firebase DB
		newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
			let messageData = snapshot.value as! Dictionary<String, String>
			
			if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
				self.addMessage(withId: id, name: name, text: text)
				self.finishReceivingMessage()
			} else {
				print("Error! Could not decode message data")
			}
		})
	}
	
	private func observeTyping() {
		let typingIndicatorRef = channelRef!.child("typingIndicator")
		userIsTypingRef = typingIndicatorRef.child(senderId)
		userIsTypingRef.onDisconnectRemoveValue()
		
		usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
			// You're the only one typing, don't show the indicator
			if data.childrenCount == 1 && self.isTyping {
				return
			}
			
			// Are there others typing?
			self.showTypingIndicator = data.childrenCount > 0
			self.scrollToBottom(animated: true)
		}
	}

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
	override func textViewDidChange(_ textView: UITextView) {
		super.textViewDidChange(textView)
		// If the text is not empty, the user is typing
		isTyping = textView.text != ""
	}
	
}
