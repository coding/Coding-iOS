//
//  MRPRBaseInfo.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPR.h"
#import "ProjectLineNote.h"

@interface MRPRBaseInfo : NSObject
@property (strong, nonatomic) MRPR *pull_request, *merge_request, *mrpr;
@property (strong, nonatomic) NSMutableArray *discussions;
@property (strong, nonatomic) NSString *pull_request_description, *merge_request_description;
@property (strong, nonatomic) NSNumber *can_edit_src_branch, *can_edit, *author_can_edit;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) CGFloat contentHeight;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;


@end
