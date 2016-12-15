//
//  AllSearchDisplayVC.h
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodingSearchDisplayView.h"

@interface AllSearchDisplayVC : UISearchDisplayController
@property (nonatomic,weak)UIViewController *parentVC;
-(void)reloadDisplayData;
@end
