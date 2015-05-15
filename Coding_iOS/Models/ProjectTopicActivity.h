//
//  ProjectTopicActivity.h
//  Coding_iOS
//
//  Created by Ease on 15/5/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectTopicActivity : NSObject
@property (readwrite, nonatomic, strong) NSString *title, *content, *path;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (readwrite, nonatomic, strong) ProjectTopicActivity *parent;

@end
