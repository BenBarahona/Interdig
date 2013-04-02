//
//  LoginViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 23/03/13.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@protocol loginDelegate <NSObject>

-(void)loginDidFinish:(NSDictionary *)response;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UITextField *userTxt;
    IBOutlet UITextField *passwordTxt;
}

@property (nonatomic, retain) NSString *database;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, assign) id<loginDelegate> delegate;

@end
