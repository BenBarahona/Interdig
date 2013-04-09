//
//  LoginViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 23/03/13.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "DCRoundSwitch.h"
#import "ObjectInfo.h"

@protocol loginDelegate <NSObject>

-(void)loginDidFinish:(NSDictionary *)response WithObject:(ObjectInfo *)info;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UITextField *userTxt;
    IBOutlet UITextField *passwordTxt;
    DCRoundSwitch *saveSession;
}

@property (nonatomic, retain) NSString *database;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, assign) id<loginDelegate> delegate;
@property (nonatomic, retain) ObjectInfo *selectedObject;
@end
