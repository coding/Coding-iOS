//
//  WikiHeaderView.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAWiki.h"

@interface WikiHeaderView : UIView
@property (strong, nonatomic) EAWiki *curWiki;
@property (assign, nonatomic) BOOL isForEdit;
@end
