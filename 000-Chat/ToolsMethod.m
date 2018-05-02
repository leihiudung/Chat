//
//  ToolsMethod.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/28.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "ToolsMethod.h"

@implementation ToolsMethod
+ (CGRect)countCharactersWidthAndHeight:(NSDictionary *)dict inSize:(CGSize)size onScreenSize:(CGSize)screenSize withAttribute:(NSDictionary<NSAttributedStringKey, id> *)attributeDict{

    NSString *content = dict[@"msg"];
    NSString *name = dict[@"sender"];
    
    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDict context:nil];
    
    return rect;
}

+ (BOOL)adjustIsEmoji:(NSString *)emojiStr {
    NSString *regex = @"[\u4e00-\u9fa5]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:emojiStr];
    return NO;
}

// 判断是否有中文
-(BOOL)isChinese:(NSString*)c{
    
    int strlength = 0;
    
    char* p = (char*)[c cStringUsingEncoding:NSUnicodeStringEncoding];
    
    for (int i=0 ; i<[c lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        
        if (*p) {
            
            p++;
            
            strlength++;
            
        }
        
        else {
            
            p++;
            
        }
        
    }
    
    return ((strlength/2)==1)?YES:NO;
    
}
@end
