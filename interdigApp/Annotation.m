//
//  Annotation.m
//  interdigApp
//
//  Created by Merci Hernandez on 04/10/12.
//
//

#import "Annotation.h"

@implementation Annotation
@synthesize coordinate, title, subtitle, objectInfo;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)_title andSubtitle:(NSString *)_subtitle andInfo:(ObjectInfo *)info
{
    self = [super init];
    
	self.coordinate = c;
    self.title = _title;
    self.subtitle = _subtitle;
    self.objectInfo = info;
    
	return self;
}

-(void)dealloc
{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
