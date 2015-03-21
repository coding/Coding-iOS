//
//  TweetSendLocaitonMapViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/16/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocaitonMapViewController.h"
#import <MapKit/MapKit.h>
#import "TweetSendMapAnnotation.h"
#import "Tweets.h"
#import "LocationHelper.h"


@interface TweetSendLocaitonMapViewController ()<MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation TweetSendLocaitonMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置";
    
    self.mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
//    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    [self.view addSubview:self.mapView];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray *locationArray = [self.tweet.coord componentsSeparatedByString:@","];
    @try {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [locationArray[0] doubleValue];
        coordinate.longitude = [locationArray[1] doubleValue];
        
        coordinate = [LocationHelper bdToGGEncrypt:coordinate];
        
        NSArray *array = [self.tweet.location componentsSeparatedByString:@"·"];
        NSString *title = self.tweet.location;
        if (array.count == 2) {
            title = array[1];
        }
        TweetSendMapAnnotation *newAnnotation = [[TweetSendMapAnnotation alloc]
                                                 initWithTitle:title andCoordinate:coordinate];
        newAnnotation.subtitle = self.tweet.address;
        [self.mapView addAnnotation:newAnnotation];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 250, 250);
        
        [self.mapView setRegion:region animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TweetSendMapAnnotation class]]) {
        
        MKAnnotationView *annotationView =[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:@"CustomAnnotation"];
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"map_annotation"];
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id <MKAnnotation> mp = [annotationView annotation];
    
    [self.mapView selectAnnotation:mp animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
