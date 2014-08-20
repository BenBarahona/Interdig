//
//  shoppingViewCell.h
//  interdigApp
//
//  Created by Merci Hernandez on 24/07/14.
//
//

#import <UIKit/UIKit.h>

@protocol shoppingCellDelegate <NSObject>

- (void) increaseQuantityOfItemWithIndexPath:(NSIndexPath *)indexPath;
- (void) decreaseQuantityOfItemWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface shoppingViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *name;
@property (nonatomic, assign) IBOutlet UILabel *price;
@property (nonatomic, assign) IBOutlet UILabel *quantity;
@property (nonatomic, assign) IBOutlet UIImageView *mainImage;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id <shoppingCellDelegate> delegate;
@end
