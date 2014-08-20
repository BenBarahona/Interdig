//
//  shoppingViewCell.m
//  interdigApp
//
//  Created by Merci Hernandez on 24/07/14.
//
//

#import "shoppingViewCell.h"

@implementation shoppingViewCell
@synthesize delegate, indexPath;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"shoppingViewCell" owner:self options:nil];
        [self addSubview:[screens objectAtIndex:0]];
        
    }
    return self;
}

- (IBAction)increaseClicked:(id)sender
{
    [self.delegate increaseQuantityOfItemWithIndexPath:self.indexPath];
}

- (IBAction)decreaseClicked:(id)sender
{
    [self.delegate decreaseQuantityOfItemWithIndexPath:self.indexPath];
}

@end
