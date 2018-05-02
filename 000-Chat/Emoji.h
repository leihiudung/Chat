//
//  Emoji.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emoji : NSObject
@property (nonatomic, strong) NSString *chs;
@property (nonatomic, strong) NSString *png;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *emojiIcon;
@property (nonatomic, assign) BOOL isRemove;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
