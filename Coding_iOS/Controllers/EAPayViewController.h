//
//  EAPayViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/11/29.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ShopOrder.h"

@interface EAPayViewController : BaseViewController

@property (strong, nonatomic) ShopOrder *shopOrder;

- (void)handlePayURL:(NSURL *)url;

@end
