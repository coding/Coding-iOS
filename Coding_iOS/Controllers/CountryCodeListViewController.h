//
//  CountryCodeListViewController.h
//  CodingMart
//
//  Created by Ease on 16/5/11.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "BaseViewController.h"

@interface CountryCodeListViewController : BaseViewController
@property (copy, nonatomic) void(^selectedBlock)(NSDictionary *countryCodeDict);//country, country_code, iso_code

@end
