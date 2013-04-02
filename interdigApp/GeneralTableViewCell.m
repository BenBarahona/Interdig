//
//  GeneralTableViewCell.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralTableViewCell.h"

@implementation GeneralTableViewCell
@synthesize labelText, cellImage, imageURL, chatImage, chatLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"GeneralTableViewCell" owner:self options:nil];
        [self addSubview:[screens objectAtIndex:0]];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    [self.bgImage setHighlighted:selected];
}

-(void)managedImageSet:(HJManagedImageV *)mi
{
    NSLog(@"Image loaded");
}


-(void)managedImageCancelled:(HJManagedImageV *)mi
{
    NSLog(@"Imaged Failed to load: %@", mi);
}

@end
