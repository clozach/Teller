import UIKit

public func firstAndRest<T>(array: [T]) -> (T?,[T]?) {
   let numElements = 1 // Allow for future expansion from first to first-N elements
   if (array.count > numElements) {
      var result : [T] = []
      for index in numElements..<array.count {
         result.append(array[index])
      }
      return (array[0], result)
   } else if array.count == 1 {
      return (array[0], nil)
   } else {
      return (nil, nil)
   }
}

func between(firstNum: Double, and secondNum: Double) -> Double{
   return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

enum ChatSender {
   case Automaton
   case Customer
}

struct Chat {
   let text: String
   let senderType: ChatSender
   let action: (()->())?
}

protocol ChatConsumer {
   func addChat(chat: Chat)
   func addChatChoices(choices: [Chat])
}

struct ChatViewModel {
   var chatConsumer: ChatConsumer
   
   func poke() {
      presentChatSequence(
         [
            Chat(text: "We have two ways for you to send us your hours.", senderType: .Automaton, action: nil),
            Chat(text: "Which would you like to set up now?", senderType: .Automaton, action: nil),
         ],
         choices: [
            Chat(text: "Timesheet system (automatic)", senderType: .Customer, action: {
               self.presentChatSequence(
                  [
                     Chat(text: "Timesheet system (automatic)", senderType: .Customer, action: nil),
                     
                     Chat(text: "Let's give that a shot.", senderType: .Automaton, action: nil),
                     Chat(text: "Which system do you use?", senderType: .Automaton, action: nil),
                  ],
                  choices: [
                     Chat(text: "When I Work™", senderType: .Customer, action: {
                        self.presentChatSequence([
                           Chat(text: "When I Work™", senderType: .Customer, action: nil)
                           ], choices: [
                           ]
                        )
                     }),
                     Chat(text: "Brink™", senderType: .Customer, action: {
                        self.presentChatSequence([
                           Chat(text: "Brink™", senderType: .Customer, action: nil)
                           ], choices: [
                           ]
                        )
                     }),
                     Chat(text: "Other...", senderType: .Customer, action: {
                        self.getTimesheetSystemName()
                     })
                  ]
               )
            }),
            Chat(text: "Photo uploads (manual)", senderType: .Customer, action: {
               self.presentChatSequence(
                  [
                     Chat(text: "OK. Done!", senderType: .Customer, action: nil),
                     Chat(text: "Well, that is, we've added a camera button down below.", senderType: .Automaton, action: nil),
                     Chat(text: "Just tap that whenever you're at work and have entered hours into your electronic timesheet", senderType: .Automaton, action: nil),
                  ],
                  choices: [
                     Chat(text: "Got it", senderType: .Customer, action: {
                        self.presentChatSequence([
                           Chat(text: "Got it", senderType: .Customer, action: nil)
                           ], choices: [
                           ]
                        )
                     }),
                     Chat(text: "I use a paper timesheet.", senderType: .Customer, action: {
                        self.presentChatSequence([
                           Chat(text: "I use a paper timesheet.", senderType: .Customer, action: nil),
                           Chat(text: "OK...", senderType: .Automaton, action: nil),
                           Chat(text: "...we'll just get that camera button out of your way then.", senderType: .Automaton, action: nil),
                           Chat(text: "And you're out of luck. Bye bye.", senderType: .Automaton, action: nil),
                           ], choices: [
                              Chat(text: "Aw, dangit!", senderType: .Customer, action: {
                                 self.presentChatSequence([
                                    Chat(text: "Aw, dangit!", senderType: .Customer, action: nil)
                                    ], choices: [
                                    ]
                                 )
                              }),
                           ]
                        )
                     }),
                  ]
               )
            })
         ]
      )
   }
   
   func getTimesheetSystemName() {
      UIAlertView.showWithTitle("Which one?", message: "Which electronic timesheet system do you use?", style: .PlainTextInput, cancelButtonTitle: "Done", otherButtonTitles: nil, tapBlock: { (alertView: UIAlertView?, buttonIndex: Int) -> Void in
         if let userInput = alertView?.textFieldAtIndex(0)?.text {
            self.presentChatSequence([
               Chat(text: userInput, senderType: .Customer, action: nil),
               Chat(text: "We don't currently support \(userInput). :(", senderType: .Automaton, action: nil),
               Chat(text: "You lose.", senderType: .Automaton, action: nil),
               Chat(text: "Don't worry, though...it's just a demo...", senderType: .Automaton, action: nil),
               Chat(text: "EVERYBODY loses!", senderType: .Automaton, action: nil),
               Chat(text: "Bye bye.", senderType: .Automaton, action: nil)
            ], choices: [
               Chat(text: "Tell me when you support \(userInput)", senderType: .Customer, action: {
                  self.presentChatSequence([
                     Chat(text: "Let me know when you support \(userInput)", senderType: .Customer, action: nil),
                     Chat(text: "Sure thing!", senderType: .Automaton, action: nil)], choices: [])
               }),
               Chat(text: "At least leave me with some entertainment!", senderType: .Customer, action: { _ in
                  self.presentChatSequence([
                     Chat(text: "At least leave me with some entertainment!", senderType: .Customer, action: nil),
                     Chat(text: "Of course! Take your pick.", senderType: .Automaton, action: nil)
                     ], choices: [
                        Chat(text: "Kittens!", senderType: .Automaton, action: { () -> () in
                           self.launch("https://www.youtube.com/watch?v=loab4A_SqoQ")
                        }),
                        Chat(text: "Geekery!", senderType: .Automaton, action: { () -> () in
                           self.launch("http://arstechnica.com/information-technology/2015/03/for-a-brighter-robotics-future-its-time-to-offload-their-brains/")
                        }),
                        Chat(text: "Adult spy humor?", senderType: .Automaton, action: { () -> () in
                           self.launch("http://dvd.netflix.com/Movie/Archer/70171942")
                        }),
                     ])
               })
            ])
         }
      })
   }
   
   func presentChatSequence(chats: [Chat], choices: [Chat]) {
      let (chat, rest) = firstAndRest(chats)
      if let chat = chat {
         between(0.5, and: 2.0).secondsFromNowDo({ _ in
            self.chatConsumer.addChat(chat)
            if let rest = rest {
               self.presentChatSequence(rest, choices: choices)
            } else {
               1.secondsFromNowDo({ _ in
                  self.chatConsumer.addChatChoices(choices
                  )
               })
            }
         })
      }
   }
   
   func launch(url: String) {
      if let URL = NSURL(string: url) {
         UIApplication.sharedApplication().openURL(URL)
      }
   }
}

class ChatViewController: UITableViewController, ChatConsumer {
   
   var chatViewModel: ChatViewModel? // In "real" life, pass this in and declare variable as protocol conformant
   var chats: [Chat] = []
   
   func addChat(chat: Chat) {
      chats.append(chat)
      tableView.reloadData()
   }
   
   @IBOutlet weak var leftButton: UIButton!
   @IBOutlet weak var middleButton: UIButton!
   @IBOutlet weak var rightButton: UIButton!
   var leftChoice: Chat?
   var middleChoice: Chat?
   var rightChoice: Chat?
   @IBAction func leftChoiceSelected() {
      if let action = leftChoice?.action {
         hideAll()
         action()
      }
   }
   @IBAction func middleChoiceSelected() {
      if let action = middleChoice?.action {
         hideAll()
         action()
      }
   }
   @IBAction func rightChoiceSelected() {
      if let action = rightChoice?.action {
         hideAll()
         action()
      }
   }
   
   func addChatChoices(choices: [Chat]) {
      switch choices.count {
      case 0:
         hideAll()
      case 1:
         hideRight()
         hideMiddle()
         showLeft(choices[0])
      case 2:
         showMiddle(choices[0])
         showLeft(choices[1])
      case 3:
         showLeft(choices[0])
         showMiddle(choices[1])
         showRight(choices[2])
      default:
         println("Too many choices, wtf? Who modified the demo?")
      }
      scrollToBottom()
   }
   
   func hideLeft() {
      leftButton.hidden = true
      leftChoice = nil
   }
   
   func hideMiddle() {
      middleButton.hidden = true
      middleChoice = nil
   }
   
   func hideRight() {
      rightButton.hidden = true
      rightChoice = nil
   }
   
   func hideAll() {
      hideLeft()
      hideMiddle()
      hideRight()
   }
   
   func showLeft(choice: Chat) {
      leftChoice = choice
      leftButton.setTitle(choice.text, forState: .Normal)
      1.secondsFromNowDo { _ in
         self.leftButton.hidden = false
      }
   }
   
   func showMiddle(choice: Chat) {
      middleChoice = choice
      middleButton.setTitle(choice.text, forState: .Normal)
      1.secondsFromNowDo { _ in
         self.middleButton.hidden = false
      }
   }
   
   func showRight(choice: Chat) {
      rightChoice = choice
      rightButton.setTitle(choice.text, forState: .Normal)
      1.secondsFromNowDo { _ in
         self.rightButton.hidden = false
      }
   }
   
   func scrollToBottom() {
      let lastIndex = tableView.numberOfRowsInSection(0) - 1
      if lastIndex == -1 {
         return
      }
      let lastRow = NSIndexPath(forRow: lastIndex, inSection: 0)
      tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: .Bottom, animated: true)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      hideAll()
      chatViewModel = ChatViewModel(chatConsumer: self)
   }
   
   override func viewDidAppear(animated: Bool) {
      self.chats = []
      hideAll()
      chatViewModel?.poke()
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return chats.count
   }
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let chat = chats[indexPath.row]
      var reuseId: String
      switch chat.senderType {
      case .Automaton:
         reuseId = "simple_ah_chat_message_cell_id"
      default:
         reuseId = "simple_customer_chat_message_cell_id"
      }
      let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as SimpleTextCell
      cell.setText(chat.text)
      return cell
   }
   
   /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return NO if you do not want the specified item to be editable.
   return true
   }
   */
   
   /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
   
   /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
   
   /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return NO if you do not want the item to be re-orderable.
   return true
   }
   */
   
   /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
   
}
