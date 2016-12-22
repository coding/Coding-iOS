//
//  NSData+gzip.h
//  CodingMart
//
//  Created by Ease on 2016/11/30.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (gzip)
+ (NSData *)ungzipData:(NSData *)compressedData;
+ (NSData*)gzipData:(NSData*)pUncompressedData;
@end
