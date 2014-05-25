//
//  MapLocationViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 14/09/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Annotation.h"
#import "AFNetworking.h"
#import "ObjectInfo.h"
#import "Util.h"

@interface MapLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    IBOutlet MKMapView *mapView;

    MKUserLocation *userLocation;
    
    BOOL openGoogleMaps;
    
    Annotation *selectedAnnotation;
    
    IBOutlet UIBarButtonItem *refreshBtn;
    
    enum alertPromptType alertType;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) NSUInteger tipoURL;
@property (nonatomic, retain) NSString *database;
@property (nonatomic, assign) BOOL annotationTypeGPS;
@end
