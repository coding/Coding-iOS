//
//  TaskCommentActivity.h
//  Coding_iOS
//
//  Created by Ease on 15/5/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskCommentActivity : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
