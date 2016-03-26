//
//  NSObject+ReviewersInfo.h
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewersInfo:NSObject
@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;
@property (readwrite, nonatomic, strong) NSMutableArray *volunteer_reviewers;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@end
