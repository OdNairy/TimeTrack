//
//  TrackMap.m
//  TimeTrack
//
//  Created by Roman Hardukevich on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackMap.h"

@interface TrackMap()

-(void)drawPathWithArray:(NSArray *)points;
-(void)createAnotationsFrom:(NSArray*)events;

@end


#pragma mark -
@implementation TrackMap

@synthesize eventsArray;

- (id)init
{
    self = [super init];
    if (self)
    {
        eventsArray = [[NSArray alloc] init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        eventsArray = [[NSArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [eventsArray release];
    [calendarCenter release];
    [super dealloc];
    
    return;
}

#pragma mark - Update Event/Paths

-(void)updateEventsAndPath:(id)sender
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if ([Reachability isNetworkAvailable])
    {
        [self updateEvents];
        [self updatePath];
    }
    
    [pool release];
    return;
}

-(void)updateEventForAnnotation:(id<MKAnnotation>)annotation
{
    if ([self annotations])
    {
        [self removeAnnotation:annotation];
    }
    [self addAnnotation:annotation];
    
    return;
}

-(void)updatePath
{
    NSMutableArray* eventList = [CalendarCenter defaultCenter].eventsList;
    
    NSArray* overlays = [self overlays];
    [self removeOverlays:overlays];
    
    
    CLLocationCoordinate2D coors = self.userLocation.coordinate;
    if (coors.latitude == 0 && coors.longitude == 0)
    {
        return;
    }
    
    if (eventList.count > 0)
    {
        CLLocation* loc = [CalendarCenter createLocationFromEvent:[eventList objectAtIndex:0]];
        [self showPathFrom:self.userLocation.location
                        to:loc];

    }
    
    return;
}



-(void)updateEvents
{
    eventsArray = [[CalendarCenter defaultCenter] fetchEventsWithCoordinatesFrom:
                   [NSDate dateWithTimeIntervalSinceNow:-86400*10]
                to:[NSDate dateWithTimeIntervalSinceNow:86400  ]];
    
    
    if ([self annotations])
    {
        [self removeAnnotations:[self annotations]];
    }
    
    [self createAnotationsFrom:eventsArray];

    return;
}

#pragma mark - Create Annotations



-(MyPointAnnotation*)createAnnotationFromEvent:(EKEvent*)event
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setTimeStyle:NSDateFormatterShortStyle];
    [formater setDateStyle:NSDateFormatterShortStyle];
    
    CLLocation* coors = [CalendarCenter createLocationFromEvent:event];
    
    MyPointAnnotation* pointAnnotation = [[[MyPointAnnotation alloc] init] autorelease];
         pointAnnotation.event = event;
         pointAnnotation.title = event.title;
      pointAnnotation.subtitle = [formater stringFromDate:event.startDate];
    pointAnnotation.coordinate = coors.coordinate;
    
    [formater release];
    return pointAnnotation;
}


-(void)createAnotationsFrom:(NSArray*)events
{
    for (EKEvent* event in events)
    {
        id<MKAnnotation> annotation = [self createAnnotationFromEvent:event];
        [self addAnnotation:annotation];
    }
    
    return;
}


#pragma mark - Show Path



- (NSDate*)showPathFromArray:(NSArray*)locationsArray UserLocationFirst:(BOOL)useUserLocation
{
    // TODO: rewrite message to take array of points: A, B, C, etc. ; but no A1,A2,…,A_N,B
    NSMutableString* travelTime;
    NSArray* pointsOfDirection;
    NSMutableArray* locations = [[NSMutableArray alloc] init];
    
    if (useUserLocation && self.userLocation.location)
    {
        [locations addObject:self.userLocation.location];

    }
    
    [locations addObjectsFromArray:locationsArray];
    
    for (size_t i = 0;i < locations.count - 1; ++i)
    {
        pointsOfDirection = [GADirections calculateRoutesFrom:[locations objectAtIndex:i   ]
                                                           to:[locations objectAtIndex:i +1]
                                                  WriteTimeTo:(i ? nil : &travelTime)];
        [self drawPathWithArray:pointsOfDirection];
    }

    [self updateEvents];
    
    [locations release];
    return nil;
}


-(NSDate *)showPathFrom:(CLLocation*)A to:(CLLocation*)B
{

    NSMutableString* travelTime = [[NSMutableString alloc] init];
    
//    if (!A) 
//    {
//        A = [[CLLocation alloc] initWithLatitude:37.33147 longitude:-122.03077];
//    }

    
    NSArray* routePoints = [[GADirections calculateRoutesFrom:A
                                                          to:B
                                                 WriteTimeTo:&travelTime] retain];

    
    
    [self drawPathWithArray:routePoints];
    NSLog(@"Time for travel: %@",travelTime);
    
    [routePoints release];
    [travelTime release];

    return nil;
    
    
    // TODO parse travelTime and return Date
    
    // days hours/hour
    // Very long way
    /* http://maps.google.com/maps?saddr=U.S.+30+E&daddr=28.62903,-109.99601+to:35.11166,-78.96094+to:23.6424,-103.62574+to:40.79664,-77.67056+to:48.0356,-98.44414+to:45.11,-119.125&hl=en&sll=37.579413,-103.31543&sspn=28.529625,56.90918&geocode=FTzfqgIdiFf6-A%3BFSbYtAEdFphx-Sk72MKcKcvIhjG5NFVKkh9yyw%3BFezCFwId1CZL-ylFq6R6pmuriTFGRPPHAnyseA%3BFSDBaAEd9MvS-SkRymV18FObhjHMgbDoNetuPw%3BFeCBbgIdYNde-yk98QbVFbrOiTEMkeiK_7lYyA%3BFRD33AIdlNwh-imxRIrEM8HEUjH1_U99Lj02dw%3BFfBSsAId-Evm-A&vpsrc=0&mra=mift&mrsp=0&sz=5&via=1,2,3,4,5&z=5 
     
     */
    
}




#pragma mark - Draw Path

-(void)drawPathWithArray:(NSArray *)points
{   
    if (points.count < 3)
    {
        return ;
    }
    CLLocationCoordinate2D* arr = malloc(points.count * sizeof(CLLocationCoordinate2D));
    for (size_t i = 0; i < points.count; ++i) 
    {
        arr[i] = ((CLLocation*)[points objectAtIndex:i]).coordinate;
    }
    
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:arr count:[points count]];
    polyline.title = @"line-Direction";
    
    [self addOverlay:polyline];
    
    free(arr);
    
    return;
}



#pragma mark -

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
