//
//  AddRoomViewController.swift
//  000-Chat
//
//  Created by 李晓东 on 2018/5/2.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

import UIKit
import XMPPFramework

@objc(RoomQueryDelegate)
protocol RoomQueryDelegate {
    func joinRoom()
}
class AddRoomViewController: UIViewController, XMPPRoomDelegate {

    @IBOutlet weak var roomView: UITextField!
    let app = UIApplication.shared.delegate as! AppDelegate
    var delegate : RoomQueryDelegate!
    var roster : XMPPRoster!
    var room: XMPPRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if app.rosterStorage == nil {
            app.rosterStorage = XMPPRosterCoreDataStorage.init()
        }
        roster = XMPPRoster.init(rosterStorage: app.rosterStorage)
        roster.activate(app.stream)
        roster.addDelegate(self, delegateQueue: app.queue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnCLick(_ sender: Any) {
        if roomView.text == nil {
            return
        }
        let rosterText = roomView.text!
        let jid = XMPPJID.init(string: rosterText + "@" + ROOM_SUFFIX)
        roomView.text = ""
        roster.subscribePresence(toUser: jid)
        joingRoom(jid!.bare())
        
        
    }
    
    func joingRoom(_ jid: String) {
        addRoom(jid)
    }
    
    func addRoom(_ roomName: String) {
        if room == nil {
            app.roomStorage = XMPPRoomCoreDataStorage.init()
        }
        let roomJid = XMPPJID.init(string: roomName)
        room = XMPPRoom.init(roomStorage: app.roomStorage, jid: roomJid)
        
        room.activate(app.stream)
        room.addDelegate(self, delegateQueue: app.queue)
        room.join(usingNickname: app.stream.myJID.user, history: nil)

    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        DispatchQueue.main.sync {
            self.navigationController?.popViewController(animated: true)
        };
    }
    
    func xmppRoomDidJoin(_ sender: XMPPRoom!) {
        DispatchQueue.main.sync {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
            viewController.currentSession = room.roomJID.full()
            viewController.roomUserSession = app.stream.myJID.bare()
            viewController.room = room
            self.present(viewController, animated: true, completion: nil)
        };
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            ChatViewController *viewController = (ChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
//            [viewController setCurrentSession:_room.roomJID.full];
//            [viewController setRoomUserSession:_app.stream.myJID.bare];
//            [viewController setRoom:self.room];
//            [self presentViewController:viewController animated:YES completion:nil];
//            });
    }
}
