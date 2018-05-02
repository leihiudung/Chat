//
//  AudioRecordManager.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/28.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "AudioRecordManager.h"
@interface AudioRecordManager()<AVAudioRecorderDelegate>

@end
@implementation AudioRecordManager
- (instancetype)init{
    if (self = [super init]) {
        NSMutableDictionary *settings = [NSMutableDictionary dictionary];
        //设置录音格式
        [settings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        [settings setObject:@(8000) forKey:AVSampleRateKey];
        //设置通道,这里采用单声道
        [settings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //每个采样点位数,分为8、16、24、32
        [settings setObject:@(8) forKey:AVLinearPCMIsBigEndianKey];
        //是否使用浮点数采样
        [settings setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
        
        NSString *filePath = [self getSaveFilePath];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        //
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
        _recorder.delegate = self;
    }
    return self;
}
//+ (instancetype)shareAudioRecordManager {
//    AudioRecordManager *audioRecordManager = [[AudioRecordManager alloc]init];
//    // 录制属性
//    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
//    //设置录音格式
//    [settings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
//    [settings setObject:@(8000) forKey:AVSampleRateKey];
//    //设置通道,这里采用单声道
//    [settings setObject:@(1) forKey:AVNumberOfChannelsKey];
//    //每个采样点位数,分为8、16、24、32
//    [settings setObject:@(8) forKey:AVLinearPCMBitDepthKey];
//    //是否使用浮点数采样
//    [settings setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
//
//
//    NSString *filePath = [self getSaveFilePath];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    //
//    NSError *error = nil;
//    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
//    return audioRecordManager;
//}

- (void)startRecord {
    [_recorder record];
}

- (void)stopRecord:(void (^)(NSData *, NSInteger))success andFailure:(void (^)(NSString *))failure {
    NSTimeInterval timeInterval = _recorder.currentTime;
    [_recorder stop];

    if (timeInterval <= 2) {
        failure(@"时间太短");
    } else {
        
        NSData *data = [NSData dataWithContentsOfURL:_recorder.url];
        success(data,  lround(timeInterval));
    }
}

- (NSString *)getSaveFilePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"audioChat.caf"];
    return filePath;
}
@end
