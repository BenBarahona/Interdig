//
//  MapViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 03/10/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Annotation.h"
#import "HJObjManager.h"
#import "ASIHTTPRequest.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView *map;
    
    Annotation *itemLocation;
    CLLocation *userLocation;
    CLLocationCoordinate2D userCoordinate;
    CLLocationManager *locationManager;
    IBOutlet HJObjManager *objManager;
    
    BOOL setRegionToUser;
    BOOL openGoogleMaps;
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *mapURL;
@property (nonatomic, retain) NSString *itemTitle;
@property (nonatomic, retain) NSString *itemSubtitle;

@end
