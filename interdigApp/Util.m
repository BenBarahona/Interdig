//
//  Util.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "Reachability.h"
#import "ObjectInfo.h"

@implementation Util
@synthesize eCommerceItems, loginBackground;

-(void)dealloc
{
    [eCommerceItems release];
    [super dealloc];
}

- (NSMutableArray *)eCommerceItems
{
    if(eCommerceItems == nil)
    {
        eCommerceItems = [[NSMutableArray alloc] init];
    }
    return eCommerceItems;
}

+(Util *) sharedInstance
{
    static Util *instance;
    if(instance == nil)
    {
        instance = [[Util alloc] init];
    }
    return instance;
}

+(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

+(void)showAlertWithMessage:(NSString *)message andDelegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Interdig" message:message delegate:delegate cancelButtonTitle:@"Cancelar" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

+(void)showErrorAlertWithCode:(NSUInteger)responseCode
{
    NSString *message = @"";
    if(responseCode > 400 && responseCode < 500)
    {
        message = @"La pagina no existe o la petición no fue completada";
    }
    else if(responseCode > 500)
    {
        message = @"";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

+(BOOL)isUserOnIpad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+(NSString *) URLEncodedString_ch:(NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)string;
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+(BOOL)internetConnectionAvailable
{
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    // check for internet connection
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            return NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"The internet is working via WIFI.");
            return YES;
            break;
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"The internet is working via WWAN.");
            return YES;
            break;
        }
            
        default:
            return YES;
            break;
    }
}

+(BOOL)isIOS7
{
    if([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) checkIfItemIsInEcommerceItems:(ObjectInfo *)item
{
    for(ObjectInfo *obj in [Util sharedInstance].eCommerceItems)
    {
        if([item.objectID isEqualToString:obj.objectID])
        {
            return YES;
        }
    }
    return NO;
}

@end
