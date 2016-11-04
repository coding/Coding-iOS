//
//  HtmlMediaViewController.h
//  Coding_iOS
//
//  Created by Ease on 2016/11/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "HtmlMedia.h"

@interface HtmlMediaViewController : BaseViewController
+ (instancetype)instanceWithHtmlMedia:(HtmlMedia *)htmlMedia title:(NSString *)title;
@end
