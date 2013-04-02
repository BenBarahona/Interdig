//
//  WebViewController.m
//  interdigApp
//
//  Created by Escolarea on 10/1/12.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)youTubeVideofullScreen:(id)sender
{   //Set Flag True.
    isFullscreen = TRUE;
    
}

- (void)youTubeVideoExit:(id)sender
{
    //Set Flag False.
    isFullscreen = FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // For FullSCreen Entry
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeVideofullScreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    
    // For FullSCreen Exit
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeVideoExit:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadWebViewContent)];
    self.navigationItem.rightBarButtonItem = reload;
    [reload release];
    
    [self loadWebViewContent];
    
    if([self.title isEqualToString:@""])
    {
        self.title = @"Web";
    }
        
}

-(void)viewDidUnload
{
    webView.delegate = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    //Just Check If Flag is TRUE Then Avoid The Execution of Code which Intrupting the Video Playing.
    if(!isFullscreen)
    {
        [super viewWillDisappear:animated];
    
    [webView stopLoading];
    [webView loadHTMLString:nil baseURL:nil];
    webView.delegate = nil;
    NSLog(@"Web view Will disappear");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)loadWebViewContent
{
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.webURL]] autorelease];
    [webView loadRequest:request];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
/*
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    errorLabel.hidden = YES;
    return YES;
}*/

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    errorLabel.hidden = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    errorLabel.hidden = NO;
}

-(void) dealloc
{
    [super dealloc];
}

@end
