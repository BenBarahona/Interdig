//
//  DetailViewController.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Util.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "ChatViewController.h"
#import "VOIPCallViewController.h"
#import "AppDelegate.h"

@implementation DetailViewController
@synthesize thisObjectInfo, objManager, dataBase, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (HJObjManager*) objManager
{
    if (!objManager) {
        //if you are using for full screen images, you'll need a smaller memory cache:
        objManager = [[HJObjManager alloc] initWithLoadingBufferSize:5 memCacheSize:5];
        
        NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/interdigApp/"] ;
        HJMOFileCache* fileCache = [[HJMOFileCache alloc] initWithRootPath:cacheDirectory];
        objManager.fileCache = fileCache;
        
        [fileCache release];
    }
    return objManager;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(self.thisObjectInfo.masInfo == nil || [self.thisObjectInfo.masInfo count] == 0)
        masInfo.hidden = YES;
    if([self.thisObjectInfo.siteURL isEqualToString:@""])
        webSiteBtn.hidden = YES;
    if([self.thisObjectInfo.video isEqualToString:@""])
        videoBtn.hidden = YES;
    if([self.thisObjectInfo.sms isEqualToString:@""])
        smsBtn.hidden = YES;
    if([self.thisObjectInfo.ext isEqualToString:@""])
        telefonoBtn.hidden = YES;
    if([self.thisObjectInfo.mapa isEqualToString:@""])
        mapsBtn.hidden = YES;
    if([self.thisObjectInfo.email isEqualToString:@""])
        emailBtn.hidden = YES;
    
    descripcion.text = self.thisObjectInfo.descripcion;
    titulo.text = self.thisObjectInfo.titulo;
    telefono.text = self.thisObjectInfo.ext;
    address1.text = [NSString stringWithFormat:@"%@\n%@", self.thisObjectInfo.address1, self.thisObjectInfo.address2];
    
    [self resizeToFit:descripcion];
    NSLog(@"SIZE: %@", NSStringFromCGSize(descripcion.frame.size));
    CGSize newSize = CGSizeMake(320, descripcion.frame.size.height + descripcion.frame.origin.y + 20);
    
    [self.view setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
    [scrollView setContentSize:newSize];
    
    if(![self.thisObjectInfo.photoURL isEqualToString:@""])
    {
        imageView.url = [NSURL URLWithString:self.thisObjectInfo.photoURL];
        [imageView showLoadingWheel];
        [self.objManager manage:imageView];
    }
    
    /*
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Atras" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
    //[backBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    [backBtn release];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)backButtonClicked:(UIBarButtonItem *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)llamarContacto_Click:(id)sender
{
    /*
    if(![self.thisObjectInfo.ext isEqualToString:@""])
    {
        NSString *number = [NSString stringWithFormat:@"tel:%@", self.thisObjectInfo.ext];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:number]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
        else
            [Util showAlertWithTitle:@"Interdig" andMessage:@"Esta operacion no puede ser realizada en su dispositivo"];
    }
     */
    
    VOIPCallViewController *voip = [[VOIPCallViewController alloc] init];
    voip.domain = self.thisObjectInfo.sipServer;
    voip.username = self.thisObjectInfo.sipUser;
    voip.destinationNumber = self.thisObjectInfo.ext;
    voip.password = self.thisObjectInfo.sipPswd;
    
    //TESTING
    /*
    voip.domain = @"8.6.240.214";
    voip.username = @"1008";
    voip.destinationNumber = @"1007";
    voip.password = @"8686";
    */
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.voipVC = voip;
    
    [self presentViewController:voip animated:YES completion:nil];
    //[self.navigationController pushViewController:voip animated:YES];
}

-(IBAction)enviarSMS_Click:(id)sender
{
    if(![self.thisObjectInfo.sms isEqualToString:@""])
    {
        alertType = MESSAGE;
        UIAlertPrompt *alertView = [[UIAlertPrompt alloc] initWithTitle:@"Enviar SMS" message:@"\n" delegate:self cancelButtonTitle:@"Cancelar" okButtonTitle:@"Enviar"];
        [alertView show];	
        [alertView release];
    }
}

-(IBAction)enviarEmail_Click:(id)sender
{
    if(![self.thisObjectInfo.email isEqualToString:@""])
    {
        alertType = EMAIL;
            UIAlertPrompt *alertPrompt = [[UIAlertPrompt alloc] initWithTitle:@"Enviar E-Mail" message:@"\n" delegate:self cancelButtonTitle:@"Cancelar" okButtonTitle:@"Enviar"];
            [alertPrompt show];
            [alertPrompt release];
    }
}

-(IBAction)showMaps_Click:(id)sender
{
    MapViewController *map = [[MapViewController alloc] init];
    map.mapURL = self.thisObjectInfo.mapa;
    map.itemTitle = self.thisObjectInfo.titulo;
    map.itemSubtitle = [NSString stringWithFormat:@"%@, %@", self.thisObjectInfo.address1, self.thisObjectInfo.address2];
    map.imageURL = self.thisObjectInfo.photoURL;
    [self.navigationController pushViewController:map animated:YES];
    [map release];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *entered = [(UIAlertPrompt *)alertView enteredText];
        switch (alertType) {
            case MESSAGE:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"No puede enviar un mensaje vacío"];
                    return;
                }
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jsms.cfm?db=%@&id=%@&men=%@", self.dataBase, self.thisObjectInfo.objectID, entered];
                NSURL *url = [NSURL URLWithString:urlString];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setDidFailSelector:@selector(enviarMensajitoFailed:)];
                [request setDidFinishSelector:@selector(enviarMensajitoFinished:)];
                [request setDelegate:self];
                [request setTimeOutSeconds:30];
                [request startAsynchronous];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Enviando SMS";
                break;
                
            case CHAT:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"Porfavor ingrese un nombre valido"];
                    return;
                }
                
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                ChatViewController *chat = [[ChatViewController alloc] init];
                chat.userName = entered;
                chat.dataBase = self.dataBase;
                chat.objectID = self.thisObjectInfo.objectID;
                [self.navigationController pushViewController:chat animated:YES];
                [chat release];
                break;
                
            case EMAIL:
                if([entered isEqualToString:@""])
                {
                    [Util showAlertWithTitle:@"Error" andMessage:@"No puede enviar un mensaje vacío"];
                    return;
                }
                entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Entered text: %@", entered);
                
                NSURL *urlEmail = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.interdig.org/jemail.cfm?db=%@&id=%@&men=%@", self.dataBase, self.thisObjectInfo.objectID, entered]];
                
                ASIHTTPRequest *emailRequest = [ASIHTTPRequest requestWithURL:urlEmail];
                [emailRequest setDidFailSelector:@selector(enviarMensajitoFailed:)];
                [emailRequest setDidFinishSelector:@selector(enviarEmailFinished:)];
                [emailRequest setDelegate:self];
                [emailRequest setTimeOutSeconds:30];
                [emailRequest startAsynchronous];
                
                MBProgressHUD *hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud2.labelText = @"Enviando E-Mail";
                break;
                
            default:
                NSLog(@"This should not happen");
                break;
        }
    }
}

-(void)enviarMensajitoFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Mensaje Enviado!" andMessage:@"Se ha enviado exitosamente su SMS!"];
}

-(void)enviarEmailFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Mensaje Enviado!" andMessage:@"Se ha enviado exitosamente su E-Mail!"];
}

-(void) enviarMensajitoFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Error al mandar mensaje - %@", [request error]]];
}

-(IBAction)showMasInfo:(id)sender
{
    MasInfoViewController *masInfoVC = [[MasInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    masInfoVC.delegate = self;
    masInfoVC.contentType = @"Mas Info";
    NSMutableArray *masInfoArr = [NSMutableArray arrayWithArray:self.thisObjectInfo.masInfo];
    [masInfoArr addObject:self.thisObjectInfo.edatadb];
    masInfoVC.dataArray = masInfoArr;
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

//MAS INFO DELEGATE
-(void)showWebViewWithInfo:(NSDictionary *)info
{
    WebViewController *web = [[WebViewController alloc] init];
    web.title = [info objectForKey:@"title"];
    web.webURL = [info objectForKey:@"url1"];
    [self.navigationController pushViewController:web animated:YES];
    [web release];
}

-(void)showNewMenuViewWithDB:(NSString *)db
{
    [self.delegate createNewMainMenuWithDB:db];
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSDictionary *info = [self.thisObjectInfo.masInfo objectAtIndex:(buttonIndex - 1)];
        WebViewController *web = [[WebViewController alloc] init];
        web.title = [info objectForKey:@"title"];
        web.webURL = [info objectForKey:@"url1"];
        [self.navigationController pushViewController:web animated:YES];
        [web release];
    }
}

-(IBAction)openWebSite:(id)sender
{
    WebViewController *web = [[WebViewController alloc] init];
    web.webURL = [NSString stringWithString:self.thisObjectInfo.siteURL];
    
    [self.navigationController pushViewController:web animated:YES];
    [web release];
}

-(IBAction)verVideoClick:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if(!ok)
    {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
    
    WebViewController *web = [[WebViewController alloc] init];
    web.webURL = [NSString stringWithString:self.thisObjectInfo.video];

    [self.navigationController pushViewController:web animated:YES];
    [web release];
}

-(IBAction)chatBtnClick:(id)sender
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.userName = @"";
    chat.dataBase = self.dataBase;
    chat.objectID = self.thisObjectInfo.objectID;
    [self.navigationController pushViewController:chat animated:YES];
    [chat release];
}

-(float)resizeToFit:(UILabel *)label
{
    float height = [self expectedHeight:label];
    CGRect newFrame = [label frame];
    newFrame.size.height = height;
    [label setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight:(UILabel *)label
{
    [label setNumberOfLines:0];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width,9999);
    
    CGSize expectedLabelSize = [[label text] sizeWithFont:[label font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[label lineBreakMode]];
    return expectedLabelSize.height;
}

-(void)dealloc
{
    [objManager cancelLoadingObjects];
    [objManager release];
    [super dealloc];
}

@end
