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
@interface TrackMap : MKMapView
{
    
}

// returned time to pass from A to B
- (NSDate*)showPathFrom:(CLLocationCoordinate2D)A to:(CLLocationCoordinate2D)B;


@end
