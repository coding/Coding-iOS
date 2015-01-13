//
//  UIImage+GIF.m
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (GIF)
//------------------------------------------------------------
//edited by easeeeeeeeee(modify)
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    return [YLGIFImage imageWithData:data];
}


+ (UIImage *)sd_animatedGIFNamed:(NSString *)name {
    return [YLGIFImage imageNamed:name];
}
//------------------------------------------------------------

@end
