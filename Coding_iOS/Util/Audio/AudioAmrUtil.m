//
//  AudioAmrUtil.m
//  audiodemo
//
//  Created by sumeng on 7/28/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioAmrUtil.h"
#import "amrFileCodec.h"

@implementation AudioAmrUtil

+ (NSString *)encodeWaveToAmr:(NSString *)waveFile {
    return [self encodeWaveToAmr:waveFile nChannels:1 nBitsPerSample:16];
}

+ (NSString *)encodeWaveToAmr:(NSString *)waveFile
                    nChannels:(int)nChannels
               nBitsPerSample:(int)nBitsPerSample {
    if (waveFile == nil) {
        return nil;
    }
    
    NSString *amrFile = [[[self convertDir] stringByAppendingPathComponent:[[waveFile lastPathComponent] md5Str]] stringByAppendingPathExtension:@"amr"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:amrFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:amrFile error:nil];
    }
    NSData *armData = EncodeWAVEToAMR([NSData dataWithContentsOfFile:waveFile], nChannels, nBitsPerSample);
    [armData writeToFile:amrFile atomically:YES];
    return amrFile;
}

+ (NSString *)decodeAmrToWave:(NSString *)amrFile {
    if (amrFile == nil) {
        return nil;
    }
    
    NSString *waveFile = [[[self convertDir] stringByAppendingPathComponent:[[amrFile lastPathComponent] md5Str]] stringByAppendingPathExtension:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:waveFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:waveFile error:nil];
    }
    NSData *waveData = DecodeAMRToWAVE([NSData dataWithContentsOfFile:amrFile]);
    [waveData writeToFile:waveFile atomically:YES];
    return waveFile;
}

+ (NSString *)convertedAmrFromWave:(NSString *)waveFile {
    NSString *amrFile = [[[self convertDir] stringByAppendingPathComponent:[[waveFile lastPathComponent] md5Str]] stringByAppendingPathExtension:@"amr"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:amrFile]) {
        return amrFile;
    }
    return nil;
}

+ (NSString *)convertedWaveFromAmr:(NSString *)amrFile {
    NSString *waveFile = [[[self convertDir] stringByAppendingPathComponent:[[amrFile lastPathComponent] md5Str]] stringByAppendingPathExtension:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:waveFile]) {
        return waveFile;
    }
    return nil;
}

+ (NSString *)convertDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dir = [docDir stringByAppendingPathComponent:@"AudioConvert"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    return dir;
}

+ (BOOL)cleanCache {
    return [[NSFileManager defaultManager] removeItemAtPath:[self convertDir] error:nil];
}

@end
