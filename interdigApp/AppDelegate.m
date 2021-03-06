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
#import "MapLocationViewController.h"

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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor], UITextAttributeTextColor,
                                [UIColor blackColor], UITextAttributeTextShadowColor,
                                [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset
                                , nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
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
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    nvc.tabBarItem.image = [UIImage imageNamed:@"interdig-57x57"];
    nvc.tabBarItem.title = @"Interdig";
    
    /*
    MapLocationViewController *map = [[MapLocationViewController alloc] init];
    UINavigationController *mapNVC = [[UINavigationController alloc] initWithRootViewController:map];
    mapNVC.tabBarItem.image = [UIImage imageNamed:@"103-map"];
    mapNVC.tabBarItem.title = @"Mapa";
    */
    /*
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:SIP_USER forKey:@"username"];
    [userDef setObject:SIP_DOMAIN forKey:@"server"];
    [userDef setObject:SIP_DOMAIN forKey:@"proxyServer"];
    [userDef setObject:SIP_USER forKey:@"authname"];
    [userDef setObject:SIP_PASSWD forKey:@"password"];
    [userDef setObject:[NSNumber numberWithInt:60] forKey:@"regTimeout"];
    [userDef synchronize];
    */
    //[tabController setViewControllers:[NSArray arrayWithObjects:nvc, map, nil]];
    
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

@end
