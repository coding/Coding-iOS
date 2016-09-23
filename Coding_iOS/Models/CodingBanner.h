//
//  CodingBanner.h
//  Coding_iOS
//
//  Created by Ease on 15/7/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodingBanner : NSObject
@property (strong, nonatomic) NSNumber *id, *status;
@property (strong, nonatomic) NSString *title, *image, *link, *name;
@property (strong, nonatomic, readonly) NSString *displayName;
@end
