//
//  WebViewController.h
//  interdigApp
//
//  Created by Escolarea on 10/1/12.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *errorLabel;
    IBOutlet UIActivityIndicatorView *activityView;
    MBProgressHUD *hud;
    BOOL isFullscreen;
}

-(void)loadWebViewContent;
@property (nonatomic, retain) NSString *webURL;

@end
