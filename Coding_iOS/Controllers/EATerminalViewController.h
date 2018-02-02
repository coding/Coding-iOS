//
//  EATerminalViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/1/30.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "WebViewController.h"

@interface EATerminalViewController : WebViewController

+ (instancetype)terminalVC;

@end

@interface EATerminalButton : UIButton

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isChoosed;

+ (instancetype)terminalButtonWithName:(NSString *)name;
+ (instancetype)smallTerminalButtonWithName:(NSString *)name choosed:(BOOL)isChoosed;

@end

@interface EATerminalPopView : UIView

@property (assign, nonatomic) NSInteger choosedIndex;
@property (assign, nonatomic, readonly) NSArray *choosedList;
@property (copy, nonatomic) void(^choosedIndexBlock)(NSArray *choosedList);

@end
