//
//  MapLocationViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 14/09/13.
//
//

#import "MapLocationViewController.h"
#import "SBJson.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "MainMenuViewController.h"

@interface MapLocationViewController ()

@end

@implementation MapLocationViewController
@synthesize items, tipoURL, database;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    /*
    for (id <MKAnnotation> annotation in mapView.annotations)
    {
        [[mapView viewForAnnotation:annotation] removeObserver:self forKeyPath:@"coordinate"]; // NOTE: remove ALL observer!
    }
     */
    mapView.delegate = nil;
    [items release];
    [database release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    userLocation = mapView.userLocation;
    [mapView setShowsUserLocation:YES];
    [self getMapPoints:nil];
    
    //UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"01-refresh"] style:UIBarButtonSystemItemRefresh target:self action:@selector(getMapPoints)];
    //self.navigationItem.rightBarButtonItem = refreshBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) getMapPoints :(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Buscando lugares..."];
    /*
     Old URL example: http://www.interdig.org/jloc2.cfm?db=casha
     New URL uses http://www.interdig.org/j<id>.cfm?db=<db>
    */
    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/j%d.cfm?db=%@", self.tipoURL, self.database];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"%@", urlString);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error = nil;
        self.items = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        
        [self zoomInToHonduras];
        [self addAnotations];
        if(error)
        {
            NSLog(@"Error parsing JSON");
        }
        else
        {
            //NSLog(@"ITEMS: %@", self.items);
        }
        
        if(self.items.count == 0)
        {
            [Util showAlertWithTitle:self.database andMessage:@"Se encontraron 0 resultados"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"FAILED: %d %@ %@", operation.response.statusCode, error, operation.responseString);
    }];
    [operation start];
}

- (void) zoomInToHonduras
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 2.0;
    span.longitudeDelta = 2.0;
    
    CLLocationCoordinate2D location;
    location.latitude = 14.0833;
    location.longitude = -87.2167;
    region.span=span;
    region.center=location;
    
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
}

- (void) addAnotations
{
    //Removing old annotations
    [mapView removeAnnotations:mapView.annotations];
    
    for (NSDictionary *info in self.items)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[info objectForKey:@"lat"] floatValue], [[info objectForKey:@"long"] floatValue]);
        Annotation *annotation = [[Annotation alloc] initWithCoordinate:coordinate andTitle:[info objectForKey:@"titulo"] andSubtitle:[info objectForKey:@"id"]];
        [mapView addAnnotation:annotation];
        //[annotation release];
    }
}
/*
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for(MKAnnotationView *annotation in views)
    {
        [annotation addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
}
*/
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
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.annotation isKindOfClass:[Annotation class]])
    {
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    selectedAnnotation = view.annotation;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Seleccione una accion" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Obtener Direcciones", @"Resultados", nil];
    [sheet showInView:self.view];
    
    [sheet release];
}

-(IBAction)locationButtonClicked:(id)sender
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 1.5;
    span.longitudeDelta = 1.5;
    
    region.span=span;
    region.center = userLocation.coordinate;
    
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Selected: %d", buttonIndex);
    if(buttonIndex == 0)
    {
        [self getDirectionsToPin:selectedAnnotation];
    }
    else if(buttonIndex == 1)
    {
        [self getResultadosParaUrna:selectedAnnotation];
    }
}


-(void)getDirectionsToPin:(Annotation *)pinView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    //{
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%0.6f,%0.6f&daddr=%0.6f,%0.6f", userLocation.coordinate.latitude, userLocation.coordinate.longitude, pinView.coordinate.latitude, pinView.coordinate.longitude];
        //urlString = @"comgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit";
        NSLog(@"%@", urlString);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return;
    //}
    
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if (6 == [[versionCompatibility objectAtIndex:0] intValue] ) {
        //iOS-6 code here
        NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%0.6f,%0.6f&daddr=%0.6f,%0.6f", userLocation.coordinate.latitude, userLocation.coordinate.longitude, pinView.coordinate.latitude, pinView.coordinate.longitude];
        NSLog(@"%@", urlString);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: urlString]];
    }
    
    openGoogleMaps = NO;
}

- (void) getResultadosParaUrna:(Annotation *)view
{
    MainMenuViewController *detailViewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
    detailViewController.urlString = [NSString stringWithFormat:@"http://www.interdig.org/jres.cfm?id=%d&db=%@", [view.subtitle intValue], self.database];
    detailViewController.dataBase = self.database;
    detailViewController.title = view.title;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}
@end
