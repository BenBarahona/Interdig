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

#define SIP_DOMAIN @"8.6.240.214"
#define SIP_USER @"1008"
#define SIP_PASSWD @"8686"

@implementation UINavigationBar (CustomImage)

-(void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:NAVBAR];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize voipVC;


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
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    
    MainMenuViewController *menu = [[MainMenuViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:menu];
    nvc.tabBarItem.image = [UIImage imageNamed:@"interdig-57x57"];
    nvc.tabBarItem.title = @"Interdig";
    
    voipVC = [[VOIPCallViewController alloc] init];
    
    //_sip_acc_id = PJSUA_INVALID_ID;
    //isConnected = TRUE;
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:SIP_USER forKey:@"username"];
    [userDef setObject:SIP_DOMAIN forKey:@"server"];
    [userDef setObject:SIP_DOMAIN forKey:@"proxyServer"];
    [userDef setObject:SIP_USER forKey:@"authname"];
    [userDef setObject:SIP_PASSWD forKey:@"password"];
    [userDef setObject:[NSNumber numberWithInt:60] forKey:@"regTimeout"];
    [userDef synchronize];
    
    /*
    NSString *server = [userDef stringForKey: @"proxyServer"];
    NSArray *array = [server componentsSeparatedByString:@","];
    NSEnumerator *enumerator = [array objectEnumerator];
    while (server = [enumerator nextObject])
        if ([server length])break;
    if (!server || [server length] < 1)
        server = [userDef stringForKey: @"server"];
    
    NSRange range = [server rangeOfString:@":"
                                  options:NSCaseInsensitiveSearch|NSBackwardsSearch];
    if (range.length > 0)
    {
        server = [server substringToIndex:range.location];
    }
    
    callViewController = [[CallViewController alloc] initWithNibName:nil bundle:nil];
    
    [callNVC.view addSubview: [self applicationStartWithSettings]];
    
    [self performSelector:@selector(sipConnect) withObject:nil afterDelay:0.2];
    */
    
    [tabController setViewControllers:[NSArray arrayWithObjects:nvc, voipVC, nil]];
    
    [self.window setRootViewController:tabController];
    //[self.window setRootViewController:nvc];
    
    [menu release];
    //[inputVC release];
    //[inputNVC release];
    [nvc release];
    [tabController release];
    
    if(![Util internetConnectionAvailable])
    {
        [Util showAlertWithTitle:@"Advertencia!" andMessage:@"No se detecta conexion a internet en su dispositivo.  Para poder utilizar esta aplicacion, es necesario tener una conexion activa, de lo contrario, algunas opciones son restringidas."];
    }
    
    return YES;
}

- (UIView *)applicationStartWithoutSettings
{
    // TODO: go to settings immediately
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen]
                                                      applicationFrame]];
    mainView.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    [navBar setFrame:CGRectMake(0, 0, 320,45)];
    navBar.barStyle = UIBarStyleBlackOpaque;
    [navBar pushNavigationItem: [[UINavigationItem alloc] initWithTitle:@""]
                      animated: NO];
    [mainView addSubview:navBar];
    
    UIImageView *background = [[UIImageView alloc]
                               initWithFrame:CGRectMake(0.0f, 45.0f, 320.0f, 185.0f)];
    [background setImage:[UIImage imageNamed:@"settings.png"]];
    [mainView addSubview:background];
    
    UILabel *text = [[UILabel alloc]
                     initWithFrame: CGRectMake(0, 220, 320, 200.0f)];
    text.backgroundColor = [UIColor clearColor];
    text.textAlignment = UITextAlignmentCenter;
    text.numberOfLines = 0;
    text.lineBreakMode = UILineBreakModeWordWrap;
    text.font = [UIFont systemFontOfSize: 18];
    text.text = NSLocalizedString(@"Siphon requires a valid\nSIP account.\n\nTo enter this information, select \"Settings\" from your Home screen, and then tap the \"Siphon\" entry.", @"SiphonApp");
    [mainView addSubview:text];
    
    text = [[UILabel alloc] initWithFrame: CGRectMake(0, 420, 320, 40.0f)];
    text.backgroundColor = [UIColor clearColor];
    text.textAlignment = UITextAlignmentCenter;
    text.font = [UIFont systemFontOfSize: 16];
    text.text = NSLocalizedString(@"Press the Home button", @"SiphonApp");
    [mainView addSubview:text];
    
    return mainView;
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
    if([defaults objectForKey:@"cta_user"] != nil)
    {
        [defaults removeObjectForKey:@"cta_user"];
    }
    if([defaults objectForKey:@"cta_password"] != nil)
    {
        [defaults removeObjectForKey:@"cta_password"];
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
    //[self sipCleanup];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"cta_user"] != nil)
    {
        [defaults removeObjectForKey:@"cta_user"];
    }
    if([defaults objectForKey:@"cta_password"] != nil)
    {
        [defaults removeObjectForKey:@"cta_password"];
    }
    
    [defaults synchronize];
}


/***************
 PJSIP SHIT
 ***************/

@end
