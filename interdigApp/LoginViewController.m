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
#import "RegisterViewController.h"
#import "UIImageView+AFNetworking.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize database, objectId, delegate, selectedObject;

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
    
    self.title = @"Registro";
    NSString *backgroundUrl = self.selectedObject.backgroundURL;
    if(backgroundUrl != nil && ![backgroundUrl isKindOfClass:[NSNull class]])
    {
        [background setImageWithURL:[NSURL URLWithString:backgroundUrl]];
    }
    
    CGRect frame = dummySwitch.frame;
    frame.size.width = 71;
    
    saveSession = [[DCRoundSwitch alloc] initWithFrame:frame];
    saveSession.onText = @"Si";
    saveSession.offText = @"No";
    saveSession.on = YES;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 80, 35)];
    [btn setTitle:@"Cancelar" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setTextColor:[UIColor whiteColor]];

    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = cancelBtn;
    
    [self.view addSubview:saveSession];
    [saveSession release];
    [cancelBtn release];
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
    loginRequest.tag = NORMAL;
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
        
        if(request.tag == NORMAL)
        {
        
            //Cuando hay error, el json tae objeto status, con valor "ERROR"
            if([resultado objectForKey:@"status"])
            {
                [Util showAlertWithTitle:@"Error" andMessage:@"Usuario y/o contrasena incorrecta"];
            }
            else
            {
                if(saveSession.on)
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:userTxt.text forKey:@"cta_user"];
                    [defaults setObject:passwordTxt.text forKey:@"cta_password"];
                    [defaults synchronize];
                }
                [self.delegate loginDidFinish:temp WithObject:self.selectedObject];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else if(request.tag == PASSWORD)
        {
            [Util showAlertWithTitle:@"" andMessage:@"Se ha enviado a su correo instrucciones para reiniciar su contraseña!"];
        }
        else if(request.tag == REGISTER)
        {
            
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
    [Util showAlertWithTitle:@"Error" andMessage:@"Hubo un error en el servidor, porfavor intente de nuevo"];
}

- (IBAction)registerClicked:(id)sender
{
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.database = self.database;
    vc.delegate = self.delegate;
    vc.selectedObject = self.selectedObject;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc release];
}

- (IBAction)forgotPasswordClicked:(id)sender
{
    if(userTxt.text != nil && ![userTxt.text isEqualToString:@""])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *email = [userTxt.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jforgot.cfm?email=%@", email];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.delegate = self;
        request.tag = PASSWORD;
        [request startAsynchronous];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Introdusca su usuario" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)dealloc
{
    [database release];
    [objectId release];
    [super dealloc];
}

@end
