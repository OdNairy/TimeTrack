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
@synthesize mapView,locationManager;

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

#pragma mark -

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
	
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[mapView setRegion:userLocation animated:YES];
	}
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"%@",event);
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"%@",event);
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    NSLog(@"%@",event);
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
