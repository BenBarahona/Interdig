//
//  Annotation.m
//  interdigApp
//
//  Created by Merci Hernandez on 04/10/12.
//
//

#import "Annotation.h"

@implementation Annotation
@synthesize coordinate, title, subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)_title andSubtitle:(NSString *)_subtitle
{
    self = [super init];
    
	self.coordinate = c;
    self.title = _title;
    self.subtitle = _subtitle;
    
	return self;
}

-(void)dealloc
{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
