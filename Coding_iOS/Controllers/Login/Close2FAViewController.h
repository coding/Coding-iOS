//
//  Close2FAViewController.h
//  Coding_iOS
//
//  Created by Ease on 16/3/15.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface Close2FAViewController : BaseViewController
+ (id)vcWithPhone:(NSString *)phone sucessBlock:(void(^)(UIViewController *vc))block;
@end
