//
//  Annotation.h
//  interdigApp
//
//  Created by Merci Hernandez on 04/10/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ObjectInfo.h"

@interface Annotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)_title andSubtitle:(NSString *)_subtitle andInfo:(ObjectInfo *)info;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) ObjectInfo *objectInfo;

@end
