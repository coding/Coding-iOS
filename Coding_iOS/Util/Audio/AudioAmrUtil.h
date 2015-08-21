//
//  AudioAmrUtil.h
//  audiodemo
//
//  Created by sumeng on 7/28/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioAmrUtil : NSObject

+ (NSString *)encodeWaveToAmr:(NSString *)waveFile;
+ (NSString *)encodeWaveToAmr:(NSString *)waveFile
                  nChannels:(int)nChannels
             nBitsPerSample:(int)nBitsPerSample;

+ (NSString *)decodeAmrToWave:(NSString *)amrFile;

+ (NSString *)convertedAmrFromWave:(NSString *)waveFile;
+ (NSString *)convertedWaveFromAmr:(NSString *)amrFile;
+ (BOOL)cleanCache;

@end
