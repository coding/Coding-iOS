//
//  UIMessageInputView_Voice.h
//  Coding_iOS
//
//  Created by sumeng on 8/1/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Voice : UIView

@property (copy, nonatomic) void(^recordSuccessfully)(NSString*, NSTimeInterval);

@end
