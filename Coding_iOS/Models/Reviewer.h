//
//  NSObject+Reviewer.h
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reviewer:NSObject
@property (readwrite, nonatomic, strong) User *reviewer;
@property (readwrite, nonatomic, strong) NSNumber *value;
@property (readwrite, nonatomic, strong) NSString *volunteer;
@property (readwrite, nonatomic, strong) NSString *name;
@end
