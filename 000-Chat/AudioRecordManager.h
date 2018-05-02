//
//  AudioRecordManager.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/28.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecordManager : NSObject
- (void)startRecord;
- (void)stopRecord:(void (^)(NSData *, NSInteger))success andFailure:(void (^)(NSString *))failure;
/** 录音器 */
@property(nonatomic,strong) AVAudioRecorder *recorder;
/** 录音地址 */
@property(nonatomic,strong) NSURL *recordURL;
@end
