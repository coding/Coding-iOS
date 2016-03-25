//
//  DemoModel.h
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//  https://github.com/Lanmaq/iOS_HelpOther_WorkSpace


#import <Foundation/Foundation.h>

@interface DemoModel : NSObject<NSCoding>

@property (nonatomic,copy)   NSString *friendName;
@property (nonatomic,copy)   NSString *friendId;
@property (nonatomic,strong) NSData   *imageData;

+ (DemoModel *) modelWithName:(NSString *)friendName friendId:(NSString *)friendId imageData:(NSData *)imageData;

@end
