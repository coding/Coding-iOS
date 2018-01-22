//
//  WikiViewController.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"
#import "EAWiki.h"

@interface WikiViewController : BaseViewController
@property (nonatomic, strong) Project *myProject;
- (void)setWikiIid:(NSNumber *)iid version:(NSNumber *)version;
@end

@interface WikiFooterView : UIView
@property (strong, nonatomic) EAWiki *curWiki;
@property (readonly, nonatomic, strong) NSArray *menuBtnList;
@property (copy, nonatomic) void(^buttonClickedBlock)(NSInteger index);
@end
