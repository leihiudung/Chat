//
//  EmojiViewCollectionCell.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Emoji;
@interface EmojiViewCollectionCell : UICollectionViewCell

- (void)fillContent:(Emoji *)emoji;
@end
