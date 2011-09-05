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
-(void)initView;
@end

@implementation MainViewController

@synthesize mapView;
@synthesize locationManager;


-(void)showPathFrom:(CLLocation*)A To:(CLLocation*)B
{
    [mapView showPathFrom:A to:B];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)addEvent:(UIMenuController *)menuController 
{
    // When add button is pushed, create an EKEventEditViewController to display the event.
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    
    // set the addController's event store to the current event store.
    addController.eventStore =  [CalendarCenter defaultCenter].eventStore;
    addController.event.location = ((UIMenuItem*)[menuController.menuItems objectAtIndex:0]).title;
    
    // present EventsAddViewController as a modal view controller
    [self presentModalViewController:addController animated:YES];
    
    addController.editViewDelegate = [CalendarCenter defaultCenter];
    [addController release];
    
}

-(void)addAnnotationFromEvent:(EKEvent *)event
{
    MyPointAnnotation* annotation = [mapView createAnnotationFromEvent:event];
    [mapView addAnnotation:annotation];
    
    [mapView setNeedsDisplay];
    [mapView setCenterCoordinate:mapView.region.center animated:NO];
    [mapView updateEvents];
    
    
    return;
}


- (IBAction)showInfo:(id)sender
{    

    [self presentModalViewController:controller animated:YES];
    
    //[controller release];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Upon selecting an event, create an EKEventViewController to display the event.
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    
    
    addController.eventStore =  [CalendarCenter defaultCenter].eventStore;
    addController.event = ((MyPointAnnotation*)[view annotation]).event;
    
    // present EventsAddViewController as a modal view controller
    [self presentModalViewController:addController animated:YES];
	//detailViewController.event = ((MyPointAnnotation*)[view annotation]).event;
	//	Push detailViewController onto the navigation controller stack
	//	If the underlying event gets deleted, detailViewController will remove itself from
	//	the stack and clear its event property.
    addController.editViewDelegate = [CalendarCenter defaultCenter];
    [addController release];
    
    
}

- (IBAction)longTap:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) 
    {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        CLLocationCoordinate2D touch = [mapView convertPoint:location toCoordinateFromView:[gestureRecognizer view]];
        
        NSString* str = [NSString stringWithFormat:@"%.5f,%.5f",touch.latitude,touch.longitude];
        
        UIMenuItem *addEventMenuItem = [[UIMenuItem alloc] initWithTitle:str action:@selector(addEvent:)];
//        UIMenuItem *settingsMenuItem = [[UIMenuItem alloc] initWithTitle:@"Settings" action:@selector(showInfo:)];
        
        
        [self.mapView becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObjects:addEventMenuItem,nil]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        [addEventMenuItem release];
    }
    
}


#pragma mark - App Live Circle

-(void)initMapView
{
    mapView = [[TrackMap alloc] initWithFrame:self.view.bounds];
    mapView.showsUserLocation = YES;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.delegate = self;
}

-(UIButton*)initButton
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button setFrame:CGRectMake(282, 422, 18, 18)];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [button addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)initLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

-(void)initGestures
{
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [mapView addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [mapView addGestureRecognizer:rotationGesture];
    [rotationGesture release];
}


-(void)initView
{
    [CalendarCenter defaultCenter].delegate = self;
    [self initMapView];
    [self initGestures];
    
    UIButton* button = [self initButton];
    [mapView addSubview:button];
    
    [self.view addSubview:mapView];
    
    [self initLocationManager];
	[locationManager startUpdatingLocation];
    
    return;
}

-(void)initFlipsideController
{
    controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initView];
    [self initFlipsideController];
    
    
    [mapView performSelectorInBackground:@selector(updateEventsAndPath:) withObject:nil];

    
    return;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    return;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    return;
}


-(void)viewDidLoad
{
    
    return;
}

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];
    
    return;
}


- (void)dealloc
{
    self.locationManager.delegate = nil;
	[locationManager release];
    
    [mapView release];
    [super dealloc];
    
    return;
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

-(BOOL)canBecomeFirstResponder
{
    
    return YES;
}

#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"[%f,%f] ->  [%f,%f]",oldLocation.coordinate.latitude,oldLocation.coordinate.longitude,
                                 newLocation.coordinate.latitude,newLocation.coordinate.longitude);
//    if (!oldLocation)
//    {
		// Zoom to the current user location.
		MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[mapView setRegion:userLocation animated:YES];
//    }
    
    NSLog(@"[%f,%f]",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
    //CLLocationCoordinate2D coors = mapView.userLocation.coordinate;
    
    [mapView updatePath];
    
	return;
}


#pragma mark - Map Delegate
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
    
	pinView.rightCalloutAccessoryView = rightButton;
	
	return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView* aView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay] autorelease];
        
        aView.fillColor = [[UIColor  redColor] colorWithAlphaComponent:0.5];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
        aView.lineWidth = 3;
        
        return aView;
    }
    
    return nil;
}

@end
