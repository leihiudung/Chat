//
//  NSString+EmojiString.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/30.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "NSString+EmojiString.h"


@implementation NSString (EmojiString)
- (NSArray *)adjustEmojiInString{
    //表情正则表达式
    //  \\u4e00-\\u9fa5 代表unicode字符
    // \[ == [; [标记一个中括号表达式的开始
    NSString *emopattern = @"\\[[\\u4e00-\\u9fa5]*\]";
//    NSString *emopattern = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]\[[a-zA-Z\\u4e00-\\u9fa5]*\]+";
//    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+";
    
    //设定总的正则表达式
    NSString *pattern = [NSString stringWithFormat:@"%@",emopattern];
    //根据正则表达式设定OC规则
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    //获取匹配结果
    NSArray *results = [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    NSMutableArray *resultArray = [NSMutableArray array];
    NSDictionary *objDict = nil;
    //遍历结果
    for (NSTextCheckingResult *result in results) {
        NSLog(@"%@ %@",NSStringFromRange(result.range),[self substringWithRange:result.range]);
        
        objDict = @{@"emoji": [self substringWithRange:result.range], @"rangeLocation": @(result.range.location), @"rangeLength": @(result.range.length)};
        [resultArray addObject:objDict];
//        [resultArray addObject:[self substringWithRange:result.range]];
    }
    return resultArray.copy;
}

// 正则表达式,比较是否是[中文].
- (void)tempMethod2 {
    //需要被筛选的字符串
    NSString *str = @"#今日要闻#[偷笑] http://asd.fdfs.2ee/aas/1e @sdf[test] #你确定#@rain李23: @张三[挖鼻屎]m123m";
    //表情正则表达式
    //  \\u4e00-\\u9fa5 代表unicode字符
    NSString *emopattern = @"\\[[\\u4e00-\\u9fa5]*\]";
    //    NSString *emopattern = @"\\[[\\u4e00-\\u9fa5]*\\]";
    //@正则表达式
    NSString *atpattern = @"@[0-9a-zA-Z\\u4e00-\\u9fa5]+";
    //#...#正则表达式
    NSString *toppattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    //url正则表达式
    NSString *urlpattern = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
    NSString *emojiPattern = @"\\[\\u4e00-\\u9fa5\]+\\";
    //设定总的正则表达式
    NSString *pattern = [NSString stringWithFormat:@"%@",emopattern];
    //根据正则表达式设定OC规则
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    //获取匹配结果
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    //NSLog(@"%@",results);
    //遍历结果
    for (NSTextCheckingResult *result in results) {
        NSLog(@"%@ %@",NSStringFromRange(result.range),[str substringWithRange:result.range]);
    }
}
@end
