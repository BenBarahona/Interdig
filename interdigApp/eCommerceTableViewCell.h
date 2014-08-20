//
//  eCommerceTableViewCell.h
//  interdigApp
//
//  Created by Merci Hernandez on 03/07/14.
//
//

#import <UIKit/UIKit.h>

@class ObjectInfo;

@interface eCommerceTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *mainImage;
@property (nonatomic, assign) IBOutlet UIImageView *checkbox;
@property (nonatomic, assign) IBOutlet UILabel *name;
@property (nonatomic, assign) IBOutlet UILabel *price;
@property (nonatomic, assign) IBOutlet UILabel *stock;
@property (nonatomic, assign) UIButton *select;
@property (nonatomic, retain) ObjectInfo *item;

@end
