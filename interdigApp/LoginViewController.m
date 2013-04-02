//
//  LoginViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 23/03/13.
//
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "SBJson.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize database, objectId, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidUnload
{
    self.objectId = nil;
    self.database = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [userTxt resignFirstResponder];
    [passwordTxt resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == userTxt)
    {
        [userTxt resignFirstResponder];
        [passwordTxt becomeFirstResponder];
    }
    else
    {
        [passwordTxt resignFirstResponder];
        [self loginClicked:nil];
    }
    return YES;
}

-(IBAction)loginClicked:(id)sender
{
    if(userTxt.text == nil || [userTxt.text isEqualToString:@""]
       || passwordTxt.text == nil || [passwordTxt.text isEqualToString:@""])
    {
        [Util showAlertWithTitle:@"Error" andMessage:@"Ingrese su clave y usuario"];
        return;
    }
    
    [userTxt resignFirstResponder];
    [passwordTxt resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jseg.cfm?db=%@&id=%@&usuario=%@&clave=%@", self.database, self.objectId, userTxt.text, passwordTxt.text];
    ASIHTTPRequest *loginRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    loginRequest.delegate = self;
    [loginRequest startAsynchronous];
}

-(IBAction)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //NSLog(@"REQUEST FINISHED: %d %@", request.responseStatusCode, request.responseString);
    if(request.responseStatusCode == 200 || request.responseStatusCode == 201)
    {
        NSArray *temp = [request.responseString JSONValue];
        NSDictionary *resultado = [temp objectAtIndex:0];
        NSLog(@"REQUEST FINISHED: %@", resultado);
        
        //Cuando inpid viene vacio, quiere decir q el login esta malo, de lo contrario esta bueno
        if([[resultado objectForKey:@"inpid"] isEqualToString:@""])
        {
            [Util showAlertWithTitle:@"Error" andMessage:@"Usuario y/o contrasena incorrecta"];
        }
        else
        {
            [self.delegate loginDidFinish:resultado];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        [self requestFailed:request];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"REQUEST FAILED: %d %@ %@", request.responseStatusCode, request.error, request.responseString);
    [Util showAlertWithTitle:@"Error" andMessage:@"Hubo un error en autenticar, porfavor intente de nuevo"];
}

-(void)dealloc
{
    [database release];
    [objectId release];
    [super dealloc];
}

@end
