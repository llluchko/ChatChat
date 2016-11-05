//
//  ChannelListViewController.swift
//  ChatChat
//
//  Created by Latchezar Mladenov on 11/5/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import UIKit
import Firebase

enum Section: Int {
	case createNewChannelSection = 0
	case currentChannelSection
}

class ChannelListViewController: UITableViewController {
	
	var senderDisplayName: String?
	var newChannelTextField: UITextField?
	private var channels: [Channel] = []
	
	// channelRef is used to store a reference to the list of channels in the database
	private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
	
	// channelRefHandle holds a handle to the reference so it can be removed later on
	private var channelRefHandle: FIRDatabaseHandle?
	
	// MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "YES!"
		observeChannels()
	}
	
	// stop observing database changes when the view controller dies
	deinit {
		if let refHandle = channelRefHandle {
			channelRef.removeObserver(withHandle: refHandle)
		}
	}
	
	// MARK :Actions
	@IBAction func createChannel(_ sender: AnyObject) {
		if let name = newChannelTextField?.text {
			let newChannelRef = channelRef.childByAutoId()
			let channelItem = [
				"name": name
			]
			newChannelRef.setValue(channelItem)
		}
	}
	
	// MARK: Firebase related methods
	private func observeChannels() {
		// We can use the observe method to listen for new
		// channels being written to the Firebase DB
		channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
			let channelData = snapshot.value as! Dictionary<String, AnyObject>
			let id = snapshot.key
			if let name = channelData["name"] as! String!, name.characters.count > 0 {
				self.channels.append(Channel(id: id, name: name))
				self.tableView.reloadData()
			} else {
				print("Error! Could not decode channel data")
			}
		})
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
//		if let channel = sender as? Channel {
//			let chatVc = segue.destination as! ChatViewController
		
//			chatVc.senderDisplayName = senderDisplayName
//			chatVc.channel = channel
//			chatVc.channelRef = channelRef.child(channel.id)
//		}
	}
	
	// MARK: UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let currentSection: Section = Section(rawValue: section) {
			switch currentSection {
			case .createNewChannelSection:
				return 1
			case .currentChannelSection:
				return channels.count
			}
		} else {
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
			if let createNewChannelCell = cell as? CreateChannelCell {
				newChannelTextField = createNewChannelCell.newChannelNameField
			}
		} else if (indexPath as NSIndexPath).section == Section.currentChannelSection.rawValue {
			cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
		}
		
		return cell
	}
	
	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (indexPath as NSIndexPath).section == Section.currentChannelSection.rawValue {
			let channel = channels[(indexPath as NSIndexPath).row]
			self.performSegue(withIdentifier: "ShowChannel", sender: channel)
		}
	}
	
}
