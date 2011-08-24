//
//  MainViewController.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MapDelegate.h"

@implementation MainViewController
@synthesize mapView;

-(void)fetchAll:(id)object
{
    eventArray = (NSMutableArray*)[calendarCenter fetchEventsWithCoordinatesFrom:[NSDate dateWithTimeIntervalSinceNow:-86400*10] to:[NSDate dateWithTimeIntervalSinceNow:86400]];
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setTimeStyle:NSDateFormatterShortStyle];
    [formater setDateStyle:NSDateFormatterShortStyle];
    for (EKEvent* event in eventArray) 
    {
        CLLocationCoordinate2D coors = CLLocationCoordinate2DMake([[event.location stringByMatching:@"([0-9\-\.]*),"  capture:1L] floatValue], 
                                                                  [[event.location stringByMatching:@",([0-9\-\.]*) " capture:1L] floatValue]);
        
        [mapView addAnnotation:[MapEventAnnotation mapEventAnnotationWithName:event.title
                                                                  description:[formater stringFromDate:event.startDate]
                                                                     latitude:coors.latitude
                                                                    longitude:coors.longitude]];
    }
    
    
   /* 
    MKMapRect flyTo = MKMapRectNull;
	for (id <MKAnnotation> annotation in mapView.annotations) {
		NSLog(@"fly to on");
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
			//NSLog(@"else-%@",annotationPoint.x);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = flyTo;*/
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark App Live Circle

-(void)viewWillAppear:(BOOL)animated
{
    return;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    calendarCenter = [[CalendarCenter alloc] init];
    [self performSelectorInBackground:@selector(fetchAll:) withObject:nil];
    
    return;
}


-(void)viewDidLoad
{
    mapView.delegate = self;
}

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [calendarCenter release];
    [mapView release];
    [super dealloc];
}

#pragma mark -



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Map Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	// don't change user-pin
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
	static NSString* AnnotationIdentifier = @"pinIdentifier";
	MKPinAnnotationView* pinView = [[[MKPinAnnotationView alloc]
									 initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
	pinView.animatesDrop=YES;
	pinView.canShowCallout=YES;
	pinView.pinColor=MKPinAnnotationColorPurple;
	
	
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton setTitle:annotation.title forState:UIControlStateNormal];
	[rightButton addTarget:self
					action:@selector(showDetails:)
		  forControlEvents:UIControlEventTouchUpInside];
	pinView.rightCalloutAccessoryView = rightButton;
	
	UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
	pinView.leftCalloutAccessoryView = profileIconView;
	[profileIconView release];
	
	
	return pinView;
}
@end
