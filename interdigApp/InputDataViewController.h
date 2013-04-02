//
//  InputDataViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 20/01/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"

@interface InputDataViewController : UIViewController <UITextFieldDelegate>
{
    NSMutableDictionary *inputItems;
        
    CGFloat currentYPosition;
    NSInteger objectsPerLine;
    
    IBOutlet UIImageView *wifiImage;
    IBOutlet UILabel *internetMsg;
    IBOutlet UIButton *retryBtn;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *submit;
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSString *database;
@property (nonatomic, retain) NSString *objectId;
@end
