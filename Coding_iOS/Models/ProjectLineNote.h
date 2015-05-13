//
//  ProjectLineNote.h
//  Coding_iOS
//
//  Created by Ease on 15/5/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectLineNote : NSObject
@property (readwrite, strong, nonatomic) NSString *commit_id, *commit_path, *content, *path;
@property (readwrite, strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
