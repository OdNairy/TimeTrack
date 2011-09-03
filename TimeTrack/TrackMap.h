//
//  TrackMap.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "RegexKitLite.h"
#import "GADirections.h"

#import "CalendarCenter.h"
#import "MyPointAnnotation.h"

@interface TrackMap : MKMapView
{
    UIColor* lineColor;
    CalendarCenter* calendarCenter;
    NSArray* eventsArray;
}

@property (nonatomic, retain) NSArray* eventsArray;

// returned time to pass from A to B
- (NSDate*)showPathFrom:(CLLocation*)A to:(CLLocation*)B;
- (NSDate*)showPathFromArray:(NSArray*)locationsArray UserLocationFirst:(BOOL)useUserLocation;

- (MyPointAnnotation*)createAnnotationFromEvent:(EKEvent*)event;

- (void)updateEvents;
- (void)updateEventsAndPath:(id)sender;
- (void)updateEventForAnnotation:(id<MKAnnotation>)annotation;

@end
