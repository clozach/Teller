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
}

protocol ChatConsumer {
    func addChat(chat: Chat)
}

protocol ChatResponder {
    func chatActionTriggered(chat: Chat)
}

struct ChatViewModel: ChatResponder {
    var chatConsumer: ChatConsumer
    
    func chatActionTriggered(chat: Chat) {
        println("Action triggered for chat: \(chat.text)")
    }
    
    func poke() {
        presentChatSequence([
            Chat(text: "Hi!", senderType: .Automaton),
            Chat(text: "Welcome to Activehours.", senderType: .Automaton),
            Chat(text: "Er, thanks...", senderType: .Customer)
            ]
        )
    }
    
    func presentChatSequence(chats: [Chat]) {
        let (chat, rest) = firstAndRest(chats)
        if let chat = chat {
            1.secondsFromNowDo({ () -> () in
                self.chatConsumer.addChat(chat)
                if let rest = rest {
                    self.presentChatSequence(rest)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
