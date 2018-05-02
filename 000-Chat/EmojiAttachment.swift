//
//  EmojiAttachment.swift
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

import UIKit

class EmojiAttachment: NSTextAttachment {
    func imageText(font: UIFont) -> NSAttributedString {
        image = UIImage(contentsOfFile: em!.png!)
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
        imageText.addAttribute(NSFontAttributeName, value: font, range: NSRange.init(location: 0, length: 1))
        //        imageText.
        let textHeight = font.lineHeight
        
        bounds = CGRect(x: 0, y: -4, width: textHeight, height: textHeight)
        
        return imageText
    }
    
    init(em: Emoji) {
        self.em = em
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var em : Emoji?
    
    // 这里可以修改选择 emoji 时,在 contentView 的大小
//    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
//        return CGRect.init(x: 0, y: 0, width: 20, height: 20)
//    }
}
