//
//  XGSetting.h
//  XG-SDK
//
//  Created by xiangchen on 29/08/14.
//  Copyright (c) 2014 mta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGSetting : NSObject

@property (nonatomic,retain) NSString* Channel;
@property (nonatomic,retain) NSString* GameServer;

+(id)getInstance;
@end
