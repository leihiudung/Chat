//
//  AddFriendViewController.swift
//  000-Chat
//
//  Created by 李晓东 on 2018/5/2.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

import UIKit
import XMPPFramework
class AddFriendViewController: UIViewController {
    

    @IBOutlet weak var userNameView: UITextField!
    let app = UIApplication.shared.delegate as! AppDelegate
    var roster : XMPPRoster!


    override func viewDidLoad() {
        super.viewDidLoad()
        if app.rosterStorage == nil {
            app.rosterStorage = XMPPRosterCoreDataStorage.init()
        }
        roster = XMPPRoster.init(rosterStorage: app.rosterStorage)
        roster.activate(app.stream)
        roster.addDelegate(self, delegateQueue: app.queue)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneClick(_ sender: Any) {
        if userNameView.text == nil {
            return
        }
        let rosterText = userNameView.text!
        let jid = XMPPJID.init(string: rosterText + HOST_SUFFIX)
        userNameView.text = ""
        roster.subscribePresence(toUser: jid)
        self.navigationController?.popViewController(animated: true)
    }
    

}
