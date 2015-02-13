//
//  ReportIllegalViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/2/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "CodingNetAPIClient.h"



@interface ReportIllegalViewController : BaseViewController

@property (strong, nonatomic) NSString *illegalContent;
@property (nonatomic, assign) IllegalContentType type;

+ (void)showReportWithIllegalContent:(NSString *)illegalContent andType:(IllegalContentType)type;

@end
