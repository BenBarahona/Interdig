//
//  RegisterViewController.m
//  interdigApp
//
//  Created by Ben on 13/5/15.
//
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "SBJson.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 80, 35)];
    [btn setTitle:@"Cancelar" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setTextColor:[UIColor whiteColor]];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = cancelBtn;
    [cancelBtn release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registrarClicked:(id)sender
{
    if([self validateFields])
    {
        if([self validateEmail:self.email.text])
        {
        NSString *urlString = [NSString stringWithFormat:@"http://www.interdig.org/jreg.cfm?db=%@&usuario=%@&clave=%@&email=%@&tel=%@&com=%@", self.database, [self.nombre.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.clave.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.email.text, [self.telefono.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.comentario.text];
            NSLog(@"URL: %@", urlString);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.delegate = self;
        [request startAsynchronous];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        else
        {
            [Util showAlertWithTitle:@"Error" andMessage:@"Email no es válido"];
        }
    }
    else
    {
        [Util showAlertWithTitle:@"Error" andMessage:@"Porfavor llene todos los campos para registrarse."];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [Util showAlertWithMessage:@"Registro completo!" andDelegate:nil];
    NSLog(@"REGISTER DONE: %@", request.responseString);
    
    NSArray *temp = [request.responseString JSONValue];
    NSDictionary *resultado = [temp objectAtIndex:0];
    
    //Cuando hay error, el json tae objeto status, con valor "ERROR"
    if([resultado objectForKey:@"status"])
    {
        [Util showAlertWithTitle:@"Error" andMessage:@"Usuario y/o contrasena incorrecta"];
    }
    else
    {
        /*
        if(saveSession.on)
        {
         */
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.email.text forKey:@"cta_user"];
            [defaults setObject:self.clave.text forKey:@"cta_password"];
            [defaults synchronize];
        //}
        
        [self.delegate loginDidFinish:temp WithObject:self.selectedObject];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"REGISTER FAILED: %@   ERROR:%@", request.responseString, request.error);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Ha ocurrido un error en el registro, porfavor intente mas tarde.  Codigo: %ld", (long)request.responseStatusCode]];
}

- (BOOL) validateFields
{
    if([self.nombre.text isEqualToString:@""] || self.nombre.text == nil
       || [self.clave.text isEqualToString:@""] || self.clave.text == nil
       || [self.telefono.text isEqualToString:@""] || self.telefono.text == nil)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.nombre)
    {
        [self.clave becomeFirstResponder];
    }
    else if(textField == self.clave)
    {
        [self.email becomeFirstResponder];
    }
    else if(textField == self.email)
    {
        [self.telefono becomeFirstResponder];
    }
    else if(textField == self.telefono)
    {
        [self.comentario becomeFirstResponder];
    }
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nombre resignFirstResponder];
    [self.clave resignFirstResponder];
    [self.telefono resignFirstResponder];
    [self.email resignFirstResponder];
    [self.comentario resignFirstResponder];
}
@end
