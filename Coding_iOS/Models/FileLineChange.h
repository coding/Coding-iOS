//
//  FileLineChange.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileLineChange : NSObject
@property (strong, nonatomic) NSNumber *index, *leftNo, *rightNo;
@property (strong, nonatomic) NSString *prefix, *text;
@end
