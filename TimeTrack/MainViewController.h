//
//  MainViewController.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "FlipsideViewController.h"

#import "MapEventAnnotation.h"
#import "Reachability.h"
#import "TrackMap.h"
#import "GADirections.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate> {
    CalendarCenter  *calendarCenter;
    NSMutableArray  *eventArray;
    IBOutlet TrackMap *mapView;
    
    CLLocationManager *locationManager;
}

@property (nonatomic,retain) IBOutlet TrackMap *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)showInfo:(id)sender;
- (IBAction)longTap:(UILongPressGestureRecognizer *)gestureRecognizer;
+ (BOOL)isNetworkAvailable;
- (void)showPathFrom:(CLLocationCoordinate2D)A To:(CLLocationCoordinate2D)B;
- (void)drawPathWithArray:(NSArray*)points;

@end
