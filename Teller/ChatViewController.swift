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
            Chat(text: "Hi!", senderType: .Automaton, action: nil),
            Chat(text: "Welcome to Activehours.", senderType: .Automaton, action: nil),
         ],
         choices: [
            Chat(text: "Er, thanks...", senderType: .Customer, action: {
               println("Wahoo!")
            })]
      )
   }
   
   func presentChatSequence(chats: [Chat], choices: [Chat]) {
      let (chat, rest) = firstAndRest(chats)
      if let chat = chat {
         1.secondsFromNowDo({ _ in
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
}

class ChatViewController: UITableViewController, ChatConsumer {
   
   var chatViewModel: ChatViewModel? // In "real" life, pass this in and declare variable as protocol conformant
   var chats: [Chat] = []
   
   func addChat(chat: Chat) {
      chats.append(chat)
      tableView.reloadData()
   }
   
   @IBOutlet weak var leftButton: UIButton!
   @IBOutlet weak var rightButton: UIButton!
   var leftChoice: Chat?
   var rightChoice: Chat?
   @IBAction func leftChoiceSelected() {
      if let action = leftChoice?.action! {
         action()
      }
   }
   @IBAction func rightChoiceSelected() {
      if let action = rightChoice?.action! {
         action()
      }
   }
   
   func addChatChoices(choices: [Chat]) {
      switch choices.count {
      case 0:
         hideLeft()
         hideRight()
      case 1:
         hideLeft()
         showRight(choices[0])
      case 2:
         showLeft(choices[0])
         showRight(choices[1])
      default:
         println("Too many choices, wtf? Who modified the demo?")
      }
      scrollToBottom()
   }
   
   func hideLeft() {
      leftButton.hidden = true
      leftChoice = nil
   }
   
   func hideRight() {
      rightButton.hidden = true
      rightChoice = nil
   }
   
   func showLeft(choice: Chat) {
      leftChoice = choice
      leftButton.setTitle(choice.text, forState: .Normal)
      1.secondsFromNowDo { _ in
         self.rightButton.hidden = false
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
      hideLeft()
      hideRight()
      chatViewModel = ChatViewModel(chatConsumer: self)
   }
   
   override func viewDidAppear(animated: Bool) {
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
