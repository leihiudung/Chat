//
//  EmojiView.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Emoji;

typedef void(^ClickEmojiBlock)(Emoji *);

@protocol EmojiViewDelegate
// 点击表情
- (void)operaInEmoji:(Emoji *)emoji;
// 在表情选择框下,发送信息
- (void)sendMessageInEmoji;
@end

@interface EmojiView : UIView <EmojiViewDelegate>
@property (nonatomic, strong) id<EmojiViewDelegate> delegate;
@end
