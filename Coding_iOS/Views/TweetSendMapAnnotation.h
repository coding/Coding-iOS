//
//  TweetSendMapAnnotation.h
//  Coding_iOS
//
//  Created by Kevin on 3/16/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TweetSendMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title; //title值
@property (nonatomic, copy) NSString *subtitle;


- (id)initWithTitle:(NSString *)atitle latitue:(float)alatitude longitude:(float)alongitude;

- (id)initWithTitle:(NSString *)atitle andCoordinate:(CLLocationCoordinate2D)location;

@end
