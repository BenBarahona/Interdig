//
//  AppDelegate.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "call.h"
#import "CallViewController.h"
#import "PhoneViewController.h"
#import "PhoneCallDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PhoneCallDelegate>
{
    CallViewController    *callViewController;
    app_config_t _app_config;
    BOOL isConnected;
    BOOL isIpod;
    
    pjsua_acc_id  _sip_acc_id;
    
@private
    NSString *_phoneNumber;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) BOOL isIpod;
@property BOOL isConnected;

-(void) displayError:(NSString *)error withTitle:(NSString *)title;
-(void) displayParameterError:(NSString *)error;
- (void) callDisconnecting;
- (void) disconnected:(id)fp8;
- (app_config_t *) pjsipConfig;
@end
