# ChatChat

An iOS messenger app which use Firebase to synchronize real time data without writing a line of server code and JSQMessagesViewController which gives you a messaging UI that’s on par with the native Messages app. Just login anonymously, create a channel and start chatting! Written in Swift with ❤

## Installation

- pod install
- Signup in Firebase and follow the instructions to add Firebase to an iOS app
- Copy the GoogleService-Info.plist config file to your project
- Set up anonymous authentication: open the Firebase App Dashboard, select the Auth option on the left, click Sign-In   Method, then select the Anonymous option, switch Enable so that it’s on, then click Save
- Enjoy

## Usage

```swift
private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
private var channelRefHandle: FIRDatabaseHandle?
```
```swift
private func observeChannels() {
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
```
- Use the observe method to listen for new channels being written to the Firebase DB
- You call observe:with: on your channel reference, storing a handle to the reference. This calls the completion block every time a new channel is added to your database
- The completion receives a FIRDataSnapshot (stored in snapshot), which contains the data and other helpful methods
- You pull the data out of the snapshot and, if successful, create a Channel model and add it to your channels array.

![alt tag](https://github.com/llluchko/ChatChat/blob/master/ChatChat/Assets.xcassets/1.png)

![alt tag](https://github.com/llluchko/ChatChat/blob/master/ChatChat/Assets.xcassets/2.png)

  Use both simulator and real device for better testing

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

  Copyright (c) 2015 Razeware LLC

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
