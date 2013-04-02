//
//  GeneralTableViewCell.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@interface GeneralTableViewCell : UITableViewCell <HJManagedImageVDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet HJManagedImageV *cellImage;
@property (nonatomic, retain) IBOutlet UILabel *labelText;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) IBOutlet UIImageView *chatImage;
@property (nonatomic, retain) IBOutlet UILabel *chatLabel;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;
@end
