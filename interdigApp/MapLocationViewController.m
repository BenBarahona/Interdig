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
#import "ChatViewController.h"
#import "VOIPCallViewController.h"
#import "AppDelegate.h"

#define OPTION_SMS @"Enviar Sms"
#define OPTION_LLAMAR @"Llamar"
#define OPTION_EMAIL @"Enviar Email"
#define OPTION_CHAT @"Chat"

@interface MapLocationViewController ()

@end

@implementation MapLocationViewController
@synthesize items, tipoURL, database, annotationTypeGPS;

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
    if(self.items == nil)
    {
        self.annotationTypeGPS = NO;
        [self getMapPoints:nil];
    }
    else
    {
        self.annotationTypeGPS = NO;
        [refreshBtn setEnabled:NO];
        [self addAnotations];
        [self centerMapToAnnotions:nil];
    }
    
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
        
        //[self zoomInToHonduras];
        [self addAnotations];
        [self centerMapToAnnotions:nil];
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
        
        ObjectInfo *objInfo = [info objectForKey:@"info"];
        Annotation *annotation = [[Annotation alloc] initWithCoordinate:coordinate andTitle:[info objectForKey:@"titulo"] andSubtitle:[info objectForKey:@"id"] andInfo:objInfo];
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Seleccione una accion" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Obtener Direcciones", nil];
    NSInteger cancelIndex = 1;
    
    if(selectedAnnotation.objectInfo != nil)
    {
        ObjectInfo *inf = selectedAnnotation.objectInfo;
        if(![inf.sms isKindOfClass:[NSNull class]] || ![inf.sms isEqualToString:@""])
        {
            [sheet addButtonWithTitle:OPTION_SMS];
            cancelIndex++;
        }
        
        if(![inf.telefono isKindOfClass:[NSNull class]] || ![inf.telefono isEqualToString:@""])
        {
            [sheet addButtonWithTitle:OPTION_LLAMAR];
            cancelIndex++;
        }
        
        if(![inf.email isKindOfClass:[NSNull class]] || ![inf.email isEqualToString:@""])
        {
            [sheet addButtonWithTitle:OPTION_EMAIL];
            cancelIndex++;
        }
        
        if(inf.chatOn)
        {
            [sheet addButtonWithTitle:CHAT];
            cancelIndex++;
        }
    }
    
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = cancelIndex;
    
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
    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"Selected: %d", buttonIndex);
    if(buttonIndex == 0)
    {
        [self getDirectionsToPin:selectedAnnotation];
    }
    else if(buttonIndex == 1 && self.annotationTypeGPS)
    {
        [self getResultadosParaUrna:selectedAnnotation];
    }
    else if([title isEqualToString:OPTION_SMS])
    {
        [self enviarSMS_Click];
    }
    else if([title isEqualToString:OPTION_EMAIL])
    {
        [self enviarEmail_Click];
    }
    else if([title isEqualToString:OPTION_LLAMAR])
    {
        [self llamarClicked];
    }
    else if([title isEqualToString:OPTION_CHAT])
    {
        [self chatBtnClick];
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

- (IBAction) centerMapToAnnotions:(id)sender
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect animated:YES];
}


-(void)enviarSMS_Click
{
        alertType = MESSAGE;
        if([Util isIOS7])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enviar SMS" message:@"" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Enviar", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
            [alert release];
        }
        else
        {
            UIAlertPrompt *alertView = [[UIAlertPrompt alloc] initWithTitle:@"Enviar SMS" message:@"\n" delegate:self cancelButtonTitle:@"Cancelar" okButtonTitle:@"Enviar"];
            [alertView show];
            [alertView release];
        }
}

-(void)enviarEmail_Click
{
        alertType = EMAIL;
        if([Util isIOS7])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enviar E-Mail" message:@"" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Enviar", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
            [alert release];
        }
        else
        {
            UIAlertPrompt *alertPrompt = [[UIAlertPrompt alloc] initWithTitle:@"Enviar E-Mail" message:@"\n" delegate:self cancelButtonTitle:@"Cancelar" okButtonTitle:@"Enviar"];
            [alertPrompt show];
            [alertPrompt release];
        }
}

-(void)chatBtnClick
{
    ObjectInfo *selected = selectedAnnotation.objectInfo;
    
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.userName = @"";
    chat.dataBase = self.database;
    chat.objectID = selected.objectID;
    [self.navigationController pushViewController:chat animated:YES];
    [chat release];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *entered = @"";
        if([alertView isKindOfClass:[UIAlertPrompt class]])
        {
            entered = [(UIAlertPrompt *)alertView enteredText];
        }
        else{
            UITextField *textField = [alertView textFieldAtIndex:0];
            entered = textField.text;
        }
        
        ObjectInfo *selected = selectedAnnotation.objectInfo;
        
        switch (alertType) {
            case MESSAGE:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"No puede enviar un mensaje vacío"];
                    return;
                }
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jsms.cfm?db=%@&id=%@&men=%@", self.database, selected.objectID, entered];
                NSURL *url = [NSURL URLWithString:urlString];
                NSLog(@"SMS URL: %@", urlString);
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setDidFailSelector:@selector(enviarMensajitoFailed:)];
                [request setDidFinishSelector:@selector(enviarMensajitoFinished:)];
                [request setDelegate:self];
                [request setTimeOutSeconds:30];
                [request startAsynchronous];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Enviando SMS";
                break;
                
            case CHAT:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"Porfavor ingrese un nombre valido"];
                    return;
                }
                
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                ChatViewController *chat = [[ChatViewController alloc] init];
                chat.userName = entered;
                chat.dataBase = self.database;
                chat.objectID = selected.objectID;
                [self.navigationController pushViewController:chat animated:YES];
                [chat release];
                break;
                
            case EMAIL:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"No puede enviar un mensaje vacío"];
                    return;
                }
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                NSURL *urlEmail = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.interdig.org/jemail.cfm?db=%@&id=%@&men=%@", self.database, selected.objectID, entered]];
                
                NSLog(@"EMAIL URL: %@", urlEmail.path);
                
                ASIHTTPRequest *emailRequest = [ASIHTTPRequest requestWithURL:urlEmail];
                [emailRequest setDidFailSelector:@selector(enviarMensajitoFailed:)];
                [emailRequest setDidFinishSelector:@selector(enviarEmailFinished:)];
                [emailRequest setDelegate:self];
                [emailRequest setTimeOutSeconds:30];
                [emailRequest startAsynchronous];
                
                MBProgressHUD *hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud2.labelText = @"Enviando E-Mail";
                break;
                
            default:
                NSLog(@"This should not happen");
                break;
        }
    }
}

-(void)enviarMensajitoFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Mensaje Enviado!" andMessage:@"Se ha enviado exitosamente su SMS!"];
}

-(void)enviarEmailFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Mensaje Enviado!" andMessage:@"Se ha enviado exitosamente su E-Mail!"];
}

-(void) enviarMensajitoFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Error al mandar mensaje - %@", [request error]]];
}

-(void)llamarClicked
{
    ObjectInfo *selected = selectedAnnotation.objectInfo;
    
    VOIPCallViewController *voip = [[VOIPCallViewController alloc] init];
    voip.domain = selected.sipServer;
    voip.username = selected.sipUser;
    voip.destinationNumber = selected.ext;
    voip.password = selected.sipPswd;
    
    //TESTING
    /*
     voip.domain = @"8.6.240.214";
     voip.username = @"1008";
     voip.destinationNumber = @"1007";
     voip.password = @"8686";
     */
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.voipVC = voip;
    
    [self presentViewController:voip animated:YES completion:nil];
}


@end
