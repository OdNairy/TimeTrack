//
//  MainViewController.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>

@implementation MainViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    calendarCenter = [[CalendarCenter alloc] init];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occured"
//                                                    message:@"Geocoding failed" 
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"Ok!" 
//                                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    
//    NSArray* arr = [calendarCenter fetchEventsForToday];
//    //EKEventStore* myStore = [[EKLocation alloc] init];

    [calendarCenter fetchEventsWithCoordinatesFrom:[NSDate date] to:[NSDate dateWithTimeIntervalSinceNow:86400]];
    
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
