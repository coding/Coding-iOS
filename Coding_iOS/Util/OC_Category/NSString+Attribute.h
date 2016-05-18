//
//  NSString+AttributeEmphasize.h
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString (AttributeStr)

+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasizeTag:(NSString*)tag emphasizeColor:(UIColor*)color;
+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasize:(NSString*)emphasize emphasizeColor:(UIColor*)color;
+(NSString*)getStr:(NSString*)str removeEmphasize:(NSString*)emphasize;

@end
