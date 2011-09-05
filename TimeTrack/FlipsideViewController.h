//
//  FlipsideViewController.h
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CalendarCenter.h"
#import "GeoCoder.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController
{
    
    IBOutlet UISegmentedControl *navigationModeSegment;
    IBOutlet UISwitch *useGeolocationSwitch;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
