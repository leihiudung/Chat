//
//  ChatCell.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/27.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Emoji;

@interface ChatCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *backgrounImgView;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, strong) NSString *audioTime;

- (void)paddingContent:(NSDictionary *)dict andAudio:(nullable NSData *)audioData inSize:(CGSize)size onScreenSize:(CGSize)screenSize from:(NSInteger)sender;
@end
