//
//  NSAttributedString+NSAttributedString.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/30.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "NSAttributedString+NSAttributedString.h"
#import "Emoji.h"
#import "_00_Chat-Swift.h"
#import <UIKit/UIKit.h>
@implementation NSAttributedString (NSAttributedString)

- (NSString *)getPlainString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[EmojiAttachment class]]) {
//                          NSInteger lengt = [(EmojiAttachment *)value ];
                          // 这里要实时修改 range 的location, 是因为这里用到的是replaceCharactersInRange,替换上来的是中文
                          // 那么 plainString 的 characters 已经发生改变了.需要取出替换的中文的长度来作为 location 的位置
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:[(EmojiAttachment *)value em].chs];
                          base += [(EmojiAttachment *)value em].chs.length - 1 ;
                      }
                      NSLog(@"done");
                  }];
    
    return plainString;
}

- (NSString *)getPlainString2 {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[EmojiAttachment class]]) {
                          // 这里要实时修改 range 的location, 是因为这里用到的是replaceCharactersInRange,替换上来的是中文
                          // 那么 plainString 的 characters 已经发生改变了.需要取出替换的中文的长度来作为 location 的位置
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:[(EmojiAttachment *)value em].chs];
                          base += [(EmojiAttachment *)value em].chs.length - 1 ;
                      }
                      NSLog(@"done");
                  }];
    
    return plainString;
}
@end
