//
//  EmojiPackager.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Emoji;
@interface EmojiPackager : NSObject

@property (nonatomic, strong) NSArray *emojis;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
//- (void)package:(NSDictionary *)dict;
- (Emoji *)findEmoji:(NSString *)emojiChs;
@end
