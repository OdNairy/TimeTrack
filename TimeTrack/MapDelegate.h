//
//  EventMap.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 21.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapDelegate:NSObject <MKMapViewDelegate>
{
    
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
@end
