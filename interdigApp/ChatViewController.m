//
//  ChatViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 14/10/12.
//
//

#import "ChatViewController.h"
#import "Util.h"
#import "SSMessageTableViewCell.h"
#import <SSToolkit/SSTextField.h>
#import "ASIHTTPRequest.h"
#import "AFNetworking.h"
#import "SBJson.h"
#import "WebViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize userName, dataBase, chatArray, objectID, randomNumber, requestQueue;

-(ASINetworkQueue *)requestQueue
{
    if(!requestQueue)
    {
        [requestQueue cancelAllOperations];
        requestQueue = [[ASINetworkQueue alloc] init];
        [requestQueue setShouldCancelAllRequestsOnFailure:NO];
    }
    
    return requestQueue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)chatArray
{
    if(!chatArray)
        chatArray = [[NSMutableArray alloc] init];
    
    return chatArray;
}

- (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [NSString stringWithFormat:@"Chat: %@", self.userName];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"deviceToken"] == nil)
    {
        [defaults setObject:[self uuidString] forKey:@"deviceToken"];
        [defaults synchronize];
    }
    
    NSLog(@"TOKEN: %@", [defaults objectForKey:@"deviceToken"]);
    self.randomNumber = [defaults objectForKey:@"deviceToken"];
    
    //self.randomNumber = [[UIDevice currentDevice] uniqueIdentifier];

    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jchat.cfm?db=%@&id=%@&idme=%@", self.dataBase, self.objectID, self.randomNumber];
    NSLog(@"URL: %@", urlString);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDidFinish:)];
    [request setDidFailSelector:@selector(requestDidFail:)];
    [request setTimeOutSeconds:60];
    
    [self.requestQueue addOperation:request];
    [self.requestQueue go];
    [request release];
    
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    forceRefresh = NO;
    
    UIBarButtonItem *docs = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"265-download"] style:UIBarButtonItemStylePlain target:self action:@selector(didSelectDocsButton)];
    self.navigationItem.rightBarButtonItem = docs;
    
    [docs release];
}

-(void)didSelectDocsButton
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jget.cfm?db=%@&id=%@&idme=%@", self.dataBase, self.objectID, self.randomNumber];
    //NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jget.cfm?db=%@&id=%@&idme=rebo", self.dataBase, self.objectID];
    NSLog(@"URL: %@", urlString);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(getDocsFinished:)];
    [request setDidFailSelector:@selector(getDocsFailed:)];
    [request setTimeOutSeconds:60];
    
    [self.requestQueue addOperation:request];
    [self.requestQueue go];
    
    [request release];
}

-(void)getDocsFinished:(ASIHTTPRequest *)request
{
    NSLog(@"REQUEST FINISHED: %@", request);
    if(request.responseStatusCode == 200 || request.responseStatusCode == 201)
    {
        //Do stuff
        NSArray *docs = [request.responseString JSONValue];
        
        MasInfoViewController *masInfoVC = [[MasInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        masInfoVC.delegate = self;
        masInfoVC.dataArray = docs;
        masInfoVC.contentType = @"Docs";
        UINavigationController *nvc = [[UINavigationController alloc] init];
        [nvc pushViewController:masInfoVC animated:YES];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:nvc animated:YES];
        if([Util isUserOnIpad])
        {
            nvc.view.superview.frame = CGRectMake(0, 0, 320, 460);
            nvc.view.superview.center = self.view.center;
        }
        [masInfoVC release];
        [nvc release];
    }
}

-(void)requestDidFinish:(ASIHTTPRequest *)request
{
    NSLog(@"REQUEST FINISHED: %@", request.responseString);
    if(request.responseStatusCode == 200 || request.responseStatusCode == 201)
    {
        //Do stuff
        if(forceRefresh)
        {
            [mainTimer invalidate];
            mainTimer = nil;
            [self timerTick:nil];
        }
    }
}

-(void)requestDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"REQUEST FAILED: %@", request);
}

-(void)showWebViewWithURL:(NSDictionary *)url
{
    WebViewController *web = [[WebViewController alloc] init];
    web.title = [url objectForKey:@"titulo"];
    web.webURL = [url objectForKey:@"link1"];
    [self.navigationController pushViewController:web animated:YES];
    [web release];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [mainTimer invalidate];
    mainTimer = nil;
    self.chatArray = nil;
    [self.requestQueue cancelAllOperations];
    self.requestQueue.delegate = nil;
    self.requestQueue = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

-(void)timerTick:(NSTimer *)timer
{
    //Refreshing chat messages http://www.interdig.org/jchat2.cfm?db=rio&idme=xxxxxx
    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jchat2.cfm?db=%@&idme=%@", self.dataBase, self.randomNumber];
    NSLog(@"CHAT URL: %@", urlString);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(refreshChatDidFinish:)];
    [request setDidFailSelector:@selector(refreshChatDidFinish:)];
    [request setTimeOutSeconds:60];
    [self.requestQueue addOperation:request];
    [self.requestQueue go];
    [request release];
    if(!mainTimer)
    {
        mainTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
}

-(void)refreshChatDidFinish:(ASIHTTPRequest *)request
{
    NSLog(@"CHAT REFRESHED: %@", request.responseString);
    
    if(request.responseStatusCode == 200 || request.responseStatusCode == 201)
    {
        //Do stuff
        NSArray *response = [request.responseString JSONValue];
        if([response count])
        {
            for(int i = 0; i < [response count]; i++)
            {
                NSDictionary *msg = [response objectAtIndex:i];
                [self.chatArray addObject:msg];
            }
            /*if([[msg1 objectForKey:@"who1"] isEqualToString:@"me"])
            {
                //[self.chatArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[msg1 objectForKey:@"men"], @"me",nil] forKeys:[NSArray arrayWithObjects:@"message", @"sender", nil]]];
                [self.chatArray addObject:msg1];
            }
             */
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        /*
        [self.chatArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_textField.text, @"me",nil] forKeys:[NSArray arrayWithObjects:@"message", @"sender", nil]]];
        _textField.text = @"";
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         */
    }
    else
    {
        
    }
}

-(void)refreshChatDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"CHAT FAILED: %@", request.responseString);
}

#pragma mark SSMessagesViewController

- (SSMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if([self.chatArray count])
    //{
        if ([[[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"who1"] isEqualToString:@"me"]) {
            return SSMessageStyleRight;
        }
        return SSMessageStyleLeft;
    //}
    //return nil;
}


- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if([self.chatArray count])
    //{
        return [[self.chatArray objectAtIndex:indexPath.row] objectForKey:@"men"];
    //}
    //return nil;
}

-(void)sendMessageClick:(id)sender
{
    NSLog(@"SEND: %@", _textField.text);
    forceRefresh = YES;
    
    //Send message http://www.interdig.org/jchat1.cfm?db=rio&idme=xxxxxx&men=jsjsjsjsjsjsj
    NSString *enteredText = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)_textField.text,
                                                                                NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8 );
    NSLog(@"TEXT: %@", enteredText);
    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jchat1.cfm?db=%@&idme=%@&men=%@", self.dataBase, self.randomNumber, enteredText];
    NSLog(@"URL: %@", urlString);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDidFinish:)];
    [request setDidFailSelector:@selector(requestDidFail:)];
    [request setTimeOutSeconds:30];
    [self.requestQueue addOperation:request];
    [self.requestQueue go];
    [request release];
    _textField.text = @"";
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.chatArray count];
}

-(void)dealloc
{
    [requestQueue release];
    [chatArray release];
    [super dealloc];
}

@end
