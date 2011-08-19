//
//  MainViewController.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

}*/

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
    
   // NSLog([GeoCoder stringToCoordinate:@"London"]);
    NSArray* arr = [calendarCenter fetchEventsForToday];
    [GeoCoder getCoordinatesOfPlace:@"London"];
    for (EKEvent* event in arr) {
     //   CLLocationCoordinate2D* a;
        ;// event.location
    }
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    //controller.modalPresentationStyle = UIModalPresentationPageSheet;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
