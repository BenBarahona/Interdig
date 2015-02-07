//
//  MapViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 03/10/12.
//
//

#import "MapViewController.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "SBJson.h"
#import "HJManagedImageV.h"
#import "MBProgressHUD.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapURL, itemTitle, itemSubtitle, imageURL, request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (HJObjManager*) objManager
{
    if (!objManager) {
        //if you are using for full screen images, you'll need a smaller memory cache:
        objManager = [[HJObjManager alloc] initWithLoadingBufferSize:5 memCacheSize:5];
        
        NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/interdigApp/"] ;
        HJMOFileCache* fileCache = [[HJMOFileCache alloc] initWithRootPath:cacheDirectory];
        objManager.fileCache = fileCache;
        
        [fileCache release];
    }
    return objManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Mapa";
    
    NSArray *separatedString = [self.mapURL componentsSeparatedByString:@"?q="];
    if([separatedString count] > 1)
    {
        NSString *finalMapsURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [separatedString objectAtIndex:1]];
        finalMapsURL = [finalMapsURL stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        finalMapsURL = [finalMapsURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURL *url = [NSURL URLWithString:finalMapsURL];
        NSLog(@"Map URL String: %@", finalMapsURL);
        self.request = [ASIHTTPRequest requestWithURL:url];
        [self.request setDelegate:self];
        [self.request setTimeOutSeconds:30];
        [self.request setDidFinishSelector:@selector(requestDidFinish:)];
        [self.request setDidFailSelector:@selector(requestDidFail:)];
        [self.request startAsynchronous];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        //Show error message *no address provided*
        [Util showAlertWithTitle:@"Error" andMessage:@"Direccion invalida"];
        NSLog(@"No address provided");
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    openGoogleMaps = NO;
    setRegionToUser = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(self.request)
    {
        [self.request cancel];
        self.request.delegate = nil;
        self.request = nil;
    }
    [locationManager stopUpdatingLocation];
}

-(void)viewDidUnload
{
    NSLog(@"UNLOADING MAP VIEW");
    [locationManager stopUpdatingLocation];
    if(self.request)
    {
        [self.request cancel];
        self.request.delegate = nil;
    }
    self.request = nil;
}

-(void)requestDidFinish:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //NSLog(@"Request finished: %@", [_request responseString]);
    NSDictionary *responseArray = [[_request responseString] JSONValue];
    if([[responseArray objectForKey:@"status"] isEqualToString:@"OK"])
    {
        NSDictionary *results = [[responseArray objectForKey:@"results"] objectAtIndex:0];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[[results objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
        coordinate.longitude = [[[[results objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
        
        itemLocation = [[Annotation alloc] initWithCoordinate:coordinate andTitle:self.itemTitle andSubtitle:self.itemSubtitle andInfo:nil];
        [map addAnnotation:itemLocation];
        [itemLocation release];
        
        [self pinButtonClicked:nil];
    }
    else if([[responseArray objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
    {
        [Util showAlertWithMessage:@"No se encontraron resultados" andDelegate:nil];
    }
    else if([[responseArray objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"])
    {
        [Util showAlertWithMessage:@"Se ha excedido el numero de busquedas.  Intente de nuevo mas tarde" andDelegate:nil];
    }
    else
    {
        [Util showAlertWithMessage:@"Direccion invalida" andDelegate:nil];
    }
}

-(void)requestDidFail:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Request Failed with error - %@", [_request error]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
        MKAnnotationView *annotationView = [views objectAtIndex:0];
        id <MKAnnotation> mp = [annotationView annotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
    
        [mv setRegion:region animated:YES];
        [mv selectAnnotation:mp animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [sender dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if(![self.imageURL isEqualToString:@""] && [view.annotation isKindOfClass:[Annotation class]])
    {
        HJManagedImageV *imageView;
        imageView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(0,0,30,30)];
        
        view.leftCalloutAccessoryView = imageView;
        imageView.url = [NSURL URLWithString:self.imageURL];
        [imageView showLoadingWheel];
        [self.objManager manage:imageView];
        [imageView release];
    }
}

-(IBAction)locationButtonClicked:(id)sender
{
    for (id annotion in map.selectedAnnotations)
    {
        [map deselectAnnotation:annotion animated:YES];
    }
    if(sender)
        setRegionToUser = YES;
    else
        setRegionToUser = NO;
    
    if(!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    locationManager.delegate = self;
    locationManager.distanceFilter = 200;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    map.showsUserLocation = YES;
}

-(IBAction)mapButtonClicked:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (userCoordinate.latitude >= -90.0f && userCoordinate.latitude <= 90.0f && userCoordinate.longitude >= -180.0f && userCoordinate.longitude <= 180.0f && userCoordinate.latitude != 0 && userCoordinate.longitude != 0)
    {
        [self getDirections];
    }
    else
    {
        openGoogleMaps = YES;
        [self locationButtonClicked:nil];
    }
}

-(IBAction)pinButtonClicked:(id)sender
{
    for (id annotion in map.selectedAnnotations)
    {
        [map deselectAnnotation:annotion animated:YES];
    }
	id <MKAnnotation> mp = itemLocation;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[map setRegion:region animated:YES];
	[map selectAnnotation:mp animated:YES];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    userLocation = newLocation;
    userCoordinate = newLocation.coordinate;
    
    [locationManager stopUpdatingLocation];
    //Creating region for mapview
    if(setRegionToUser)
    {
        MKCoordinateRegion region = {{userCoordinate.latitude, userCoordinate.longitude}, {0.01, 0.01}};
        [map setRegion:region animated:YES];
    }
    else if(openGoogleMaps)
    {
        [self getDirections];
    }
}

-(void)getDirections
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if (6 == [[versionCompatibility objectAtIndex:0] intValue] ) {
        //iOS-6 code here
        NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%0.6f,%0.6f&daddr=%0.6f,%0.6f", userCoordinate.latitude, userCoordinate.longitude, itemLocation.coordinate.latitude, itemLocation.coordinate.longitude];
        NSLog(@"%@", urlString);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: urlString]];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%0.6f,%0.6f&daddr=%0.6f,%0.6f", userCoordinate.latitude, userCoordinate.longitude, itemLocation.coordinate.latitude, itemLocation.coordinate.longitude];
        NSLog(@"%@", urlString);
        // Pre iOS-6 code here
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: urlString]];
    }
    
    openGoogleMaps = NO;
    [self pinButtonClicked:nil];
}

-(void)dealloc
{
    [imageURL release];
    [mapURL release];
    [itemTitle release];
    [itemSubtitle release];
    [request clearDelegatesAndCancel];
    [request release];
    [super dealloc];
}
@end
