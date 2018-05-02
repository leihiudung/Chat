//
//  EmojiString.swift
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

import UIKit

class EmojiString: NSObject {
    
    func emojiInCharacter(str: String) -> String {
        let scanner = Scanner.init(string: str)
        var value : UInt32 = 0
        scanner.scanHexInt32(&value)
        
        let chr = Character(UnicodeScalar(value)!)
        return "\(chr)"
    }
}
