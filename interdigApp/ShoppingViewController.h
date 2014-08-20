//
//  ShoppingViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 10/07/14.
//
//

#import <UIKit/UIKit.h>
#import "shoppingViewCell.h"

@interface ShoppingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, shoppingCellDelegate>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *totalLabel;
    
    NSInteger total;
}

@property (nonatomic, retain) NSArray *list;

@end
