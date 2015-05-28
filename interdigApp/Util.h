//
//  Util.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;
@class ObjectInfo;

enum alertPromptType{
    CHAT = 1,
    MESSAGE = 2,
    EMAIL = 3,
};

@interface Util : NSObject
{
    
}

@property (nonatomic, retain) NSMutableArray *eCommerceItems;
@property (nonatomic, retain) UIImage *loginBackground;

+ (Util *) sharedInstance;
+(BOOL)internetConnectionAvailable;
+(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)showAlertWithMessage:(NSString *)message andDelegate:(id<UIAlertViewDelegate>)delegate;
+(BOOL)isUserOnIpad;
+(NSString *) URLEncodedString_ch:(NSString *)string;
+(BOOL)isIOS7;
+ (BOOL) checkIfItemIsInEcommerceItems:(ObjectInfo *)item;
@end
