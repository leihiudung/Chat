//
//  Emoji.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "Emoji.h"
#import "_00_Chat-Swift.h"

@interface Emoji()

@end
@implementation Emoji
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        if ([dict objectForKey:@"code"]) {
            EmojiString *emojiString = [[EmojiString alloc]init];
            [self setEmojiIcon:[emojiString emojiInCharacterWithStr:[dict valueForKey:@"code"]]];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)changeToEmoji:(NSString *)str {
    NSScanner *scanner = [[NSScanner alloc]initWithString:str];
    UInt32 value = 0;
//    [scanner scanHexInt:&value];
//    UnicodeScalarValue(value);
//    [NSString stringWithCharacters:value length:str.length];
//    {
//        let scanner = Scanner.init(string: self)
//        var value : UInt32 = 0
//        scanner.scanHexInt32(&value)
//
//        let chr = Character(UnicodeScalar(value)!)
//        return "\(chr)"
//    }
}
@end
