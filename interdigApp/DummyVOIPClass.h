//
//  DummyVOIPClass.h
//  interdigApp
//
//  Created by Merci Hernandez on 13/04/13.
//
//

#import <UIKit/UIKit.h>
#import "CallViewController.h"
#import "PhoneViewController.h"
#import "PhoneCallDelegate.h"
#import "call.h"

@interface DummyVOIPClass : UIViewController <PhoneCallDelegate>
{
CallViewController    *callViewController;
PhoneViewController   *phoneViewController;
app_config_t _app_config;
BOOL isConnected;

pjsua_acc_id  _sip_acc_id;
int			    ringback_slot;

@private
NSString *_phoneNumber;
}

@property BOOL isConnected;

-(void) displayError:(NSString *)error withTitle:(NSString *)title;
-(void) displayParameterError:(NSString *)error;
- (void) callDisconnecting;
- (void) disconnected:(id)fp8;

- (app_config_t *) pjConfig;
@end
