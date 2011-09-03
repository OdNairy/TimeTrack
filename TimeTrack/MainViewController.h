//
//  MainViewController.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "FlipsideViewController.h"


#import "Reachability.h"
#import "TrackMap.h"
#import "GADirections.h"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate> {
    CalendarCenter  *calendarCenter;
    NSMutableArray  *eventArray;
          TrackMap  *mapView;
    
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) TrackMap *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;


- (IBAction)showInfo:(id)sender;
- (IBAction)longTap:(UILongPressGestureRecognizer *)gestureRecognizer;

- (void)addAnnotationFromEvent:(EKEvent*)event;
- (void)showPathFrom:(CLLocation*)A To:(CLLocation*)B;

@end
