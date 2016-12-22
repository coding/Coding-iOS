//
//  LDNetTimer.h
//  LDNetDiagnoServieDemo
//
//  Created by 庞辉 on 14-10-29.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDNetTimer : NSObject {
}


/**
 * Retourne un timestamp en microsecondes.
 */
+ (long)getMicroSeconds;


/**
 * Calcule une durée en millisecondes par rapport au timestamp passé en paramètre.
 */
+ (long)computeDurationSince:(long)uTime;
@end
