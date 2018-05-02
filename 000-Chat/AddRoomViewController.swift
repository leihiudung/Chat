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
    var rosterText : String!
    var delegate : RoomQueryDelegate!
    var roster : XMPPRoster!
    var room: XMPPRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新建/加入聊天室"
        
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
        rosterText = roomView.text!
        let jid = XMPPJID.init(string: rosterText + "@" + ROOM_SUFFIX)
        roomView.text = ""
        roster.subscribePresence(toUser: jid)
        joingRoom(jid!.bare())
        
        
    }
    
    func joingRoom(_ jid: String) {
        addRoom(jid)
    }
    
    func addRoom(_ roomName: String) {
        if app.roomStorage == nil {
            app.roomStorage = XMPPRoomCoreDataStorage.init()
        }
        let roomJid = XMPPJID.init(string: roomName)
        room = XMPPRoom.init(roomStorage: app.roomStorage, jid: roomJid)
        
        room.activate(app.stream)
        room.addDelegate(self, delegateQueue: app.queue)
        room.join(usingNickname: app.stream.myJID.user, history: nil)

    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom!) {
//        let field = XMLElement.element(withName: "field") as! XMLElement
//        field.addAttribute(withName: "type", stringValue: "boolean")
//        field.addAttribute(withName: "var", stringValue: rosterText  + "@" + ROOM_SUFFIX)
//        field.addChild(XMLElement.element(withName: "value", stringValue: "1") as! DDXMLNode)
//        let x = XMLElement.element(withName: "x", stringValue:"jabber:x:data") as! XMLElement
//        x.addAttribute(withName: "type", stringValue: "form")
//        x.addChild(field)
//        sender.configureRoom(usingOptions: x)
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

//        NSXMLElement *field = [NSXMLElementelementWithName:@"field"];
//        [field addAttributeWithName:@"type"stringValue:@"boolean"];
//        [field addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];
//        [field addChild:[NSXMLElementelementWithName:@"value"objectValue:@"1"]];  // 将持久属性置为YES。
//        NSXMLElement *x = [NSXMLElementelementWithName:@"x"xmlns:@"jabber:x:data"];
//        [x addAttributeWithName:@"type"stringValue:@"form"];
//        [x addChild:field];
//        [sender configureRoomUsingOptions:x];
    }
    
    override func delete(_ sender: Any?) {
        print("ddd")
    }
}
