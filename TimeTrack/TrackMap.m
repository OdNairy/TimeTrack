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
    
    if (![Reachability isNetworkAvailable])
    {
        return;
    }
    [self updateEvents];
    
//    CLLocation *A = [[CLLocation alloc] initWithLatitude:41.000512 longitude:-109.050116];
//    CLLocation *B = [[CLLocation alloc] initWithLatitude:41.002371 longitude:-102.052066];
//    NSArray *arr  = [[NSArray alloc] initWithObjects: A, B, nil];
//    
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    [self showPathFromArray:arr UserLocationFirst:YES];
//    [pool release];
    
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
        pointsOfDirection = [GADirections calculateRoutesFrom:[locations objectAtIndex:i    ]
                                                           to:[locations objectAtIndex:i +1 ]
                                                  WriteTimeTo:(i ? nil : &travelTime)];
        [self drawPathWithArray:pointsOfDirection];
    }

    [self updateEvents];
    
    NSLog(@"calculate: travelTime = %@",travelTime);
    [travelTime release];
    
    return nil;
}


-(NSDate *)showPathFrom:(CLLocation*)A to:(CLLocation*)B
{
    
    NSMutableString* travelTime = [[NSMutableString alloc] init];
    
    
    NSMutableArray* pointsOfDirection = [[GADirections calculateRoutesFrom:A
                                                       to:B
                                              WriteTimeTo:&travelTime    ] copy];
    
    
    [self drawPathWithArray:pointsOfDirection];
    NSLog(@"%@",travelTime);
    
    
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
    CLLocationCoordinate2D* arr = malloc(points.count * sizeof(CLLocationCoordinate2D));
    for (size_t i = 0; i < points.count; ++i) 
    {
        arr[i] = ((CLLocation*)[points objectAtIndex:i]).coordinate;
    }
    
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:arr count:[points count]];
    polyline.title = @"line-Direction";
    
    [self addOverlay:polyline];
    [polyline release];
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
