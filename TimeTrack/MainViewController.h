//
//  MainViewController.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MapEventAnnotation.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,MKMapViewDelegate> {
    CalendarCenter  *calendarCenter;
    NSMutableArray  *eventArray;
    IBOutlet MKMapView *mapView;
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;

- (IBAction)showInfo:(id)sender;




@end
