//
//  InputDataViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 20/01/13.
//
//

#import "InputDataViewController.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "Util.h"
#import "DCRoundSwitch.h"

@interface InputDataViewController ()

@end

@implementation InputDataViewController
@synthesize request, items, objectId, database;

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
    inputItems = [[NSMutableDictionary alloc] init];
    
    if(items) {
        [self buildScreenFromResponse];
    } else {
        [self createRequestToURL:[NSURL URLWithString:@"http://www.interdig.org/jsami.cfm?table=inp"]];
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"01-refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(retryRequest:)];
        self.navigationItem.rightBarButtonItem = refreshBtn;
        [refreshBtn release];
    }
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = logout;
    [logout release];
}

-(void) viewDidUnload
{
    [request setDelegate:nil];
    self.request = nil;
    
    self.items = nil;
    self.database = nil;
    self.objectId = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"cta_user"];
    [defaults removeObjectForKey:@"cta_password"];
    [defaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)errorWithRequest:(ASIHTTPRequest *)_request
{
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Recieved response: %@", _request.responseString]];
    internetMsg.text = @"No se pudo cargar los datos, revise su conexion a internet e intente de nuevo";
    wifiImage.hidden = YES;
    retryBtn.hidden = internetMsg.hidden = NO;
    NSLog(@"ERROR - %@", [_request responseString]);
}

-(IBAction)retryRequest:(id)sender
{
    [self destroyScreenObjects];
    [self createRequestToURL:[NSURL URLWithString:@"http://www.interdig.org/jsami.cfm?table=inp"]];
}

-(void)createRequestToURL:(NSURL *)url
{
    submit.hidden = YES;
    if([Util internetConnectionAvailable])
    {
        request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        [request setDidFailSelector:@selector(didFailRequest:)];
        [request setDidFinishSelector:@selector(didFinishRequest:)];
        
        [request startAsynchronous];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        retryBtn.hidden = wifiImage.hidden = internetMsg.hidden = YES;
    }
    else
    {
        retryBtn.hidden = wifiImage.hidden = internetMsg.hidden = NO;
        internetMsg.text = @"Se necesita una conexion a internet para continuar";
    }
}

-(void)didFailRequest:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self errorWithRequest:_request];
}

-(void)didFinishRequest:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(_request.responseStatusCode == 200 || _request.responseStatusCode == 201)
    {
        NSLog(@"Response recieved: %@", _request.responseString);
        
        NSString *correctedJSON = @"[{\"linea\":\"1\",\"tipo\":\"\",\"nombre\":\"\",\"valor\":\"Titulo de Prueba\"},{\"linea\":\"3\",\"tipo\":\"\",\"nombre\":\"\",\"valor\":\"\"},{\"linea\":\"2\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Titulo\"},{\"linea\":\"2\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Valor1\"},{\"linea\":\"2\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Valor2\"},{\"linea\":\"3\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Titulo 1\"},{\"linea\":\"2\",\"tipo\":\"2\",\"nombre\":\"var1\",\"valor\":\"Prueba\"},{\"linea\":\"2\",\"tipo\":\"3\",\"nombre\":\"var2\",\"valor\":\"Prueba1\"},{\"linea\":\"3\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Titulo 2\"},{\"linea\":\"2\",\"tipo\":\"1\",\"nombre\":\"\",\"valor\":\"Prueba2\"},{\"linea\":\"2\",\"tipo\":\"4\",\"nombre\":\"var3\",\"valor\":\"\"}]";
        
        self.items = [_request.responseString JSONValue];
        
        if(!self.items)
            self.items = [correctedJSON JSONValue];
        
        [self buildScreenFromResponse];
    }
    else
    {
        [self errorWithRequest:_request];
    }
}

-(IBAction)sumbitInput:(id)sender
{
    if([Util internetConnectionAvailable])
    {
        NSString *constructedString = [NSString stringWithFormat:@"http://www.interdig.org/jproc.cfm?db=%@&id=%@&", self.database, self.objectId];
        
        NSInteger index = 1;
        
        for(NSString *key in inputItems)
        {
            id input = [inputItems objectForKey:key];
            if([input isKindOfClass:[UITextField class]])
            {
                UITextField *txt = (UITextField *)input;
                
                if([txt.text isKindOfClass:[NSNull class]] || [txt.text isEqualToString:@""] || txt.text == nil)
                {
                    [Util showAlertWithTitle:@"Interdig" andMessage:@"Favor ingresar todos los datos del formulario"];
                    return;
                }
                
                constructedString = [constructedString stringByAppendingFormat:@"%@=%@", key, txt.text];
            }
            else if([input isKindOfClass:[DCRoundSwitch class]])
            {
                DCRoundSwitch *sw = (DCRoundSwitch *)input;
                
                constructedString = [constructedString stringByAppendingFormat:@"%@=%d", key, sw.on];
            }
            
            if(index < [inputItems count])
            {
                constructedString = [constructedString stringByAppendingString:@"&"];
                index++;
            }
            
            if([input isFirstResponder])
                [input resignFirstResponder];
        }
        
        constructedString = [constructedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"SUBMIT URL:%@", constructedString);
        
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:constructedString]];
        request.delegate = self;
        [request setDidFailSelector:@selector(didFailSubmit:)];
        [request setDidFinishSelector:@selector(didFinishSubmit:)];
        
        [request startAsynchronous];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        retryBtn.hidden = wifiImage.hidden = internetMsg.hidden = YES;
    }
    else
    {
        retryBtn.hidden = wifiImage.hidden = internetMsg.hidden = NO;
        internetMsg.text = @"Se necesita una conexion a internet para continuar";
    }
}

-(void)didFailSubmit:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self errorWithRequest:_request];
}

-(void)didFinishSubmit:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(_request.responseStatusCode == 200 || _request.responseStatusCode == 201)
    {
        NSLog(@"Response recieved: %@", _request.responseString);
        [Util showAlertWithTitle:@"Interdig" andMessage:@"Se han enviado sus datos exitosamente!"];
    }
    else
    {
        [self errorWithRequest:_request];
    }
}

-(void) buildScreenFromResponse
{
    currentYPosition = 20.;
    objectsPerLine = 0;
    CGFloat sizeBetweenRows = 35.;
    
    NSMutableArray *rowObjects = [[NSMutableArray alloc] init];
    
    for(NSDictionary *object in self.items)
    {
        //NSLog(@"OBJ: %@", object);
        switch([[object objectForKey:@"linea"] intValue])
        {
            case 1:
                objectsPerLine++;
                
                [rowObjects addObject:[self createLabelWithText:[object objectForKey:@"valor"] andSize:22]];
                
                break;
            case 2:
                objectsPerLine++;
                switch([[object objectForKey:@"tipo"] intValue])
            {
                case 1:
                    [rowObjects addObject:[self createLabelWithText:[object objectForKey:@"valor"] andSize:15]];
                    break;
                case 2:
                    [rowObjects addObject:[self createTextFieldFromObject:object]];
                    break;
                case 3:
                    [rowObjects addObject:[self createTextFieldFromObject:object]];
                    break;
                case 4:
                    [rowObjects addObject:[self createSwitchFromObject:object]];
                    break;
                default:
                    NSLog(@"Valor no definido");
                    break;
            }
                break;
            case 3:
                objectsPerLine = 0;
                currentYPosition += sizeBetweenRows;
                [rowObjects removeAllObjects];
                
                if(![[object objectForKey:@"tipo"] isEqualToString:@""])
                {
                    [rowObjects addObject:[self createLabelWithText:[object objectForKey:@"valor"] andSize:15]];
                }
                
                break;
            default:
                NSLog(@"Linea no definida");
                break;
        }
        
        [self optimizeLine:rowObjects];
    }
    
    currentYPosition += 50;
    submit.hidden = NO;
    submit.frame = CGRectMake(submit.frame.origin.x, currentYPosition , submit.frame.size.width, submit.frame.size.height);
    
    currentYPosition += submit.frame.size.height;
    
    if(currentYPosition >= 400)
    {
        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, currentYPosition + 20);
    }
    
    [rowObjects release];
}

-(void)optimizeLine:(NSArray *)objects
{
    CGFloat itemsInRow = [objects count];
    CGFloat currentXPosition = 20.;
    CGFloat objectsWidth = (280 / itemsInRow) - 5;
    
    for(UIView *label in objects)
    {
        [label setFrame:CGRectMake(currentXPosition, label.frame.origin.y, objectsWidth, label.frame.size.height)];
        currentXPosition += (objectsWidth + 5);
    }
}

-(UILabel *)createLabelWithText:(NSString *)text andSize:(CGFloat)size
{
    UILabel *newLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, currentYPosition, 280, 28)] autorelease];
    [newLabel setFont:[UIFont boldSystemFontOfSize:size]];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setText:text];
    [newLabel setTextColor:[UIColor blackColor]];
    [newLabel setNumberOfLines:1];
    [newLabel setMinimumFontSize:9];
    [newLabel setAdjustsFontSizeToFitWidth:YES];
    
    newLabel.layer.borderColor = [UIColor blackColor].CGColor;
    newLabel.layer.borderWidth = 2.;
    newLabel.layer.cornerRadius = 6.;
    
    [scrollView addSubview:newLabel];
    
    return newLabel;
}

-(UITextField *)createTextFieldFromObject:(NSDictionary *)obj
{
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(20, currentYPosition, 280, 30)] autorelease];
    textField.placeholder = [obj objectForKey:@"valor"];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:15.0];
    textField.backgroundColor = [UIColor whiteColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.textAlignment = UITextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    if([[obj objectForKey:@"tipo"] intValue] == 2)
    {
        textField.keyboardType = UIKeyboardTypeDefault;
    } else {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    textField.delegate = self;
    
    [scrollView addSubview:textField];
    
    [inputItems setValue:textField forKey:[obj objectForKey:@"nombre"]];
    
    return textField;
}

/*
 -(UISwitch *)createSwitchFromObject:(NSDictionary *)obj
 {
 UISwitch *thing = [[[UISwitch alloc] initWithFrame:CGRectMake(20, currentYPosition, 79, 27)] autorelease];
 [scrollView addSubview:thing];
 
 return thing;
 }
 */

-(DCRoundSwitch *)createSwitchFromObject:(NSDictionary *)obj
{
    DCRoundSwitch *thing = [[[DCRoundSwitch alloc] initWithFrame:CGRectMake(20, currentYPosition, 280, 27)] autorelease];
    
    thing.onText = @"Si";
    thing.offText = @"No";
    
    [scrollView addSubview:thing];
    [inputItems setValue:thing forKey:[obj objectForKey:@"nombre"]];
    
    return thing;
}


-(void)destroyScreenObjects
{
    for(UIView *view in [scrollView subviews])
    {
        if(![view isKindOfClass:[UIButton class]])
        {
            NSLog(@"Destroying object: %@", view);
            [view removeFromSuperview];
        }
    }
}

-(void)dealloc
{
    [items release];
    [objectId release];
    [database release];
    [super dealloc];
}

@end
