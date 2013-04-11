//
//  AppDelegate.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenuViewController.h"
#import "Util.h"
#import "InputDataViewController.h"
#import "Crittercism.h"

#define NAVBAR @"navigation_bar3.png"

@implementation UINavigationBar (CustomImage)

-(void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:NAVBAR];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize isIpod, isConnected;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID:@"514f6904c463c276d7000002"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /*
    if([nvc.navigationBar respondsToSelector:@selector(setBackgroundImage:forState:barMetrics:)])
    {
        [nvc.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar3.png"] forBarMetrics:UIBarMetricsDefault];
    }*/
    UIImage *gradientImage44 = [[UIImage imageNamed:NAVBAR]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44
                                       forBarMetrics:UIBarMetricsDefault];
    
    //UITabBarController *tabController = [[UITabBarController alloc] init];
    
    MainMenuViewController *menu = [[MainMenuViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:menu];
    nvc.tabBarItem.image = [UIImage imageNamed:@"interdig-57x57"];
    nvc.tabBarItem.title = @"Interdig";
    
    /*
    InputDataViewController *inputVC = [[InputDataViewController alloc] init];
    UINavigationController *inputNVC = [[UINavigationController alloc] initWithRootViewController:inputVC];
    inputNVC.title = @"Input";
    inputNVC.tabBarItem.title = @"Input";
    inputNVC.tabBarItem.image = [UIImage imageNamed:@"216-compose"];
    */
    //[tabController setViewControllers:[NSArray arrayWithObjects:nvc, inputNVC, nil]];
    
    //[self.window setRootViewController:tabController];
    
    [self.window setRootViewController:nvc];
    
    [menu release];
    //[inputVC release];
    //[inputNVC release];
    [nvc release];
    //[tabController release];
    
    if(![Util internetConnectionAvailable])
    {
        [Util showAlertWithTitle:@"Advertencia!" andMessage:@"No se detecta conexion a internet en su dispositivo.  Para poder utilizar esta aplicacion, es necesario tener una conexion activa, de lo contrario, algunas opciones son restringidas."];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"user"] != nil)
    {
        [defaults removeObjectForKey:@"user"];
    }
    if([defaults objectForKey:@"password"] != nil)
    {
        [defaults removeObjectForKey:@"password"];
    }
    
    [defaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"user"] != nil)
    {
        [defaults removeObjectForKey:@"user"];
    }
    if([defaults objectForKey:@"password"] != nil)
    {
        [defaults removeObjectForKey:@"password"];
    }
    
    [defaults synchronize];
}


/***************
    PJSIP SHIT
 ***************/
- (app_config_t *)pjsipConfig
{
    return &_app_config;
}

- (BOOL)sipStartup
{
    if (_app_config.pool)
        return YES;
    
    if (sip_startup(&_app_config) != PJ_SUCCESS)
    {
        return NO;
    }
    
    /** Call management **/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processCallState:)
                                                 name: kSIPCallState object:nil];
    
    /** Registration management */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processRegState:)
                                                 name: kSIPRegState object:nil];
    
    return YES;
}

- (void)sipCleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: kSIPRegState
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSIPCallState
                                                  object:nil];
    [self sipDisconnect];
    
    if (_app_config.pool != NULL)
    {
        sip_cleanup(&_app_config);
    }
}

- (BOOL)sipConnect
{
    pj_status_t status;
    
    if (![self sipStartup])
        return FALSE;
    
    if (_sip_acc_id == PJSUA_INVALID_ID)
    {
        if ((status = sip_connect(_app_config.pool, &_sip_acc_id)) != PJ_SUCCESS)
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

- (BOOL)sipDisconnect
{
    if ((_sip_acc_id != PJSUA_INVALID_ID) &&
        (sip_disconnect(&_sip_acc_id) != PJ_SUCCESS))
    {
        return FALSE;
    }
    
    _sip_acc_id = PJSUA_INVALID_ID;
    
    isConnected = FALSE;
    
    return TRUE;
}

- (void)callDisconnecting
{
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    if (pjsua_call_get_count() <= 1)
        [self performSelector:@selector(disconnected:)
                   withObject:nil afterDelay:1.0];
}

- (void) disconnected:(id)fp8
{
    [[callViewController view] removeFromSuperview];
    [callViewController release];
}

-(void) dialup:(NSString *)phoneNumber number:(BOOL)isNumber
{
    pjsua_call_id call_id;
    pj_status_t status;
    NSString *number;
    
    UInt32 hasMicro, size;
    
    // Verify if microphone is available (perhaps we should verify in another place ?)
    size = sizeof(hasMicro);
    AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable,
                            &size, &hasMicro);
    if (!hasMicro)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Microphone Available", @"SiphonApp")
                                                        message:NSLocalizedString(@"Connect a microphone to phone", @"SiphonApp")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"SiphonApp")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if (isNumber)
        number = [self normalizePhoneNumber:phoneNumber];
    else
        number = phoneNumber;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"removeIntlPrefix"])
    {
        number = [number stringByReplacingOccurrencesOfString:@"+"
                                                   withString:@""
                                                      options:0
                                                        range:NSMakeRange(0,1)];
    }
    else
    {
        NSString *prefix = [[NSUserDefaults standardUserDefaults] stringForKey:
                            @"intlPrefix"];
        if ([prefix length] > 0)
        {
            number = [number stringByReplacingOccurrencesOfString:@"+"
                                                       withString:prefix
                                                          options:0
                                                            range:NSMakeRange(0,1)];
        }
    }
    
    // Manage pause symbol
    NSArray * array = [number componentsSeparatedByString:@","];
    [callViewController setDtmfCmd:@""];
    if ([array count] > 1)
    {
        number = [array objectAtIndex:0];
        [callViewController setDtmfCmd:[array objectAtIndex:1]];
    }
    
    if (!isConnected)
    {
        _phoneNumber = [[NSString stringWithString: number] retain];
        if (isIpod)
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"You must enable Wi-Fi or SIP account to place a call."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"SIP server is unreachable!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }
        return;
    }
    
    if ([self sipConnect])
    {
        NSRange range = [number rangeOfString:@"@"];
        if (range.location != NSNotFound)
        {
            status = sip_dial_with_uri(_sip_acc_id, [[NSString stringWithFormat:@"sip:%@", number] UTF8String], &call_id);
        }
        else
            status = sip_dial(_sip_acc_id, [number UTF8String], &call_id);
        if (status != PJ_SUCCESS)
        {
            // FIXME
            //[self displayStatus:status withTitle:nil];
            const pj_str_t *str = pjsip_get_status_text(status);
            NSString *msg = [[NSString alloc]
                             initWithBytes:str->ptr
                             length:str->slen
                             encoding:[NSString defaultCStringEncoding]];
            [self displayError:msg withTitle:@"registration error"];
        }
    }
}

- (NSString *)normalizePhoneNumber:(NSString *)number
{
    const char *phoneDigits = "22233344455566677778889999",
    *nb = [[number uppercaseString] UTF8String];
    int i, len = [number length];
    char *u, *c, *utf8String = (char *)calloc(sizeof(char), len+1);
    c = (char *)nb; u = utf8String;
    for (i = 0; i < len; ++c, ++i)
    {
        if (*c == ' ' || *c == '(' || *c == ')' || *c == '/' || *c == '-' || *c == '.')
            continue;
        if (*c >= 'A' && *c <= 'Z')
        {
            *u = phoneDigits[*c - 'A'];
        }
        else
            *u = *c;
        u++;
    }
    NSString * norm = [[NSString alloc] initWithUTF8String:utf8String];
    free(utf8String);
    return norm;
}


-(void)displayError:(NSString *)error withTitle:(NSString *)title
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:error
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"SiphonApp")
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

-(void)displayParameterError:(NSString *)msg
{
    NSString *message = NSLocalizedString(msg, msg);
    NSString *error = [message stringByAppendingString:NSLocalizedString(
                                                                         @"\nTo correct this parameter, select \"Settings\" from your Home screen, "
                                                                         "and then tap the \"Siphon\" entry.", @"SiphonApp")];
    
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                                     message:error
#if defined(CYDIA) && (CYDIA == 1)
                                                    delegate:self
#else
                                                    delegate:nil
#endif
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"SiphonApp")
                                           otherButtonTitles:NSLocalizedString(@"Settings", @"SiphonApp"), nil ] autorelease];
    [alert show];
}

@end
