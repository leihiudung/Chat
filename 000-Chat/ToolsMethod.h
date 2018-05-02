//
//  ToolsMethod.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/28.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolsMethod : NSObject
+ (CGRect)countCharactersWidthAndHeight:(NSDictionary *)dict inSize:(CGSize)size onScreenSize:(CGSize)screenSize withAttribute:(NSDictionary<NSAttributedStringKey, id> *)attributeDict;
+ (BOOL)adjustIsEmoji:(NSString *)emojiStr;
@end
