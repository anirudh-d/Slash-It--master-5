//
//  Audio.h
//  Slash It!
//
//  Created by iceking on 4/5/14.
//  Copyright (c) 2014 Savan Rupani. All rights reserved.
//


#import "Audio.h"
@import AVFoundation;

@interface Audio : NSObject

+ (instancetype)sharedInstance;
- (void)playBackgroundMusic:(NSString *)filename;
- (void)pauseBackgroundMusic;
- (void)playSoundEffect:(NSString*)filename;

@end
