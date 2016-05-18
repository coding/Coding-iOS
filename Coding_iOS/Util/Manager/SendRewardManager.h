//
//  SendRewardManager.h
//  Coding_iOS
//
//  Created by Ease on 15/12/2.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface SendRewardManager : NSObject
+ (instancetype)handleTweet:(Tweet *)curTweet completion:(void(^)(Tweet *curTweet, BOOL sendSucess))block;
@end
