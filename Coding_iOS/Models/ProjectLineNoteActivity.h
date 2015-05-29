//
//  ProjectLineNoteActivity.h
//  Coding_iOS
//
//  Created by Ease on 15/5/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectLineNoteActivity : NSObject
@property (readwrite, strong, nonatomic) NSString *noteable_id, *noteable_title, *noteable_url, *content, *path, *noteable_type;
@property (readwrite, strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
