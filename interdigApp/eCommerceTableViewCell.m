//
//  eCommerceTableViewCell.m
//  interdigApp
//
//  Created by Merci Hernandez on 03/07/14.
//
//

#import "eCommerceTableViewCell.h"
#import "Util.h"

@implementation eCommerceTableViewCell
@synthesize item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"eCommerceTableViewCell" owner:self options:nil];
        [self addSubview:[screens objectAtIndex:0]];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
