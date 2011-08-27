//
//  MainViewController.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 18.08.11.
//  Copyright 2011 iTransition ©. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface MainViewController() 

-(void)fetchAll:(id)object;
@end

@implementation MainViewController
@synthesize mapView,locationManager;


-(void)drawPathWithArray:(NSArray *)points
{   

    CLLocationCoordinate2D* arr = malloc(points.count * sizeof(CLLocationCoordinate2D));
    for (size_t i = 0; i < points.count; ++i) 
    {
        arr[i] = ((CLLocation*)[points objectAtIndex:i]).coordinate;
    }

    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:arr count:[points count]];
    polyline.title = @"Line";
    
    [mapView addOverlay:polyline];
    [polyline release];
    free(arr);
}

-(void)showPathFrom:(CLLocationCoordinate2D)A To:(CLLocationCoordinate2D)B
{
    [mapView showPathFrom:A to:B];
}

-(void)fetchAll:(id)object
{
    
    if (![MainViewController isNetworkAvailable])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
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

    CLLocationCoordinate2D  points[4];
    
    points[0] = CLLocationCoordinate2DMake(41.000512, -109.050116);
    points[1] = CLLocationCoordinate2DMake(41.002371, -102.052066);
   
    
    NSArray* arr = [GADirections calculateRoutesFrom:points[0] to:points[1] WriteTimeTo:nil];
    [self drawPathWithArray:arr];
    
    return;
}




+ (BOOL)isNetworkAvailable {
    
    Reachability *internetReach;
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus == NotReachable) { 
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        NSLog(@"Network Unavailable");
        return NO;
    }
    else
        return YES;
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)addEvent:(id)sender
{
    [calendarCenter addEvent:sender];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];

    [controller release];
}

- (IBAction)longTap:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];

        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Add event HERE" action:@selector(addEvent:)];

        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self.mapView becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        
        [resetMenuItem release];
    }

}


#pragma mark - App Live Circle

-(void)viewWillAppear:(BOOL)animated
{
    return;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    calendarCenter = [[CalendarCenter alloc] init];
    calendarCenter.delegate = self;
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorInBackground:@selector(fetchAll:) withObject:nil];
    [pool release];
    return;
}


-(void)viewDidLoad
{
    mapView.delegate = self;
    
    // Create location manager with filters set for battery efficiency.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Start updating location changes.
	[locationManager startUpdatingLocation];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [mapView addGestureRecognizer:longPressGesture];
    [longPressGesture release];
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
    self.locationManager.delegate = nil;
	[locationManager release];
    [calendarCenter release];
    [mapView release];
    [super dealloc];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView*    aView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay] autorelease];
        
        aView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
        aView.lineWidth = 3;
        
        return aView;
    }
    
    return nil;
}


#pragma mark - LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

    if (oldLocation == nil)
    {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[mapView setRegion:userLocation animated:YES];
    }
	
}


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
