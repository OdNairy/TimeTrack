//
//  EventMap.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 21.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "RegexKitLite.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapDelegate:NSObject <MKMapViewDelegate>
{
	UIImageView* routeView;
	
	NSMutableArray* routes;
    NSString* travelTime;
	
	UIColor* lineColor;
}

@property (nonatomic, retain) UIColor   *lineColor;
@property (nonatomic, copy) NSString    *travelTime;

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
-(void) showRouteFrom: (CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to;

@end
