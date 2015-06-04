//
//  AddMDCommentViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "AddMDCommentViewController.h"

@implementation AddMDCommentViewController
+ (AddMDCommentViewController *)vcWithRelatedObj:(id)relatedObj CommentToObj:(id)commentToObj andCompleteBlock:(void (^)(id data, NSError *error))completeBlock{
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    vc.relatedObj = relatedObj;
    vc.commentToObj = commentToObj;
    vc.completeBlock = completeBlock;
    return vc;
}

@end
