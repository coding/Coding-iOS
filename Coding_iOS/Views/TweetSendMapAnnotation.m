//
//  TweetSendMapAnnotation.m
//  Coding_iOS
//
//  Created by Kevin on 3/16/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendMapAnnotation.h"

@implementation TweetSendMapAnnotation

- (id)initWithTitle:(NSString *)atitle andCoordinate:(CLLocationCoordinate2D)location
{
    if(self=[super init])
    {
        _title = atitle;
        _coordinate = location;
    }
    return self;
}

- (id) initWithTitle:(NSString *)atitle latitue:(float)alatitude longitude:(float)alongitude
{
    if(self=[super init])
    {
        _title = atitle;
        _coordinate.latitude = alatitude;
        _coordinate.longitude = alongitude;
    }
    return self;
}


//- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
//{
//
//}

@end
