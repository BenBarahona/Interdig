//
//  RegisterViewController.h
//  interdigApp
//
//  Created by Ben on 13/5/15.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoginViewController.h"

@interface RegisterViewController : UIViewController <ASIHTTPRequestDelegate, UITextFieldDelegate>

@property (nonatomic, retain) NSString *database;
@property (nonatomic, assign) IBOutlet UITextField *nombre;
@property (nonatomic, assign) IBOutlet UITextField *clave;
@property (nonatomic, assign) IBOutlet UITextField *email;
@property (nonatomic, assign) IBOutlet UITextField *telefono;
@property (nonatomic, assign) IBOutlet UITextView *comentario;
@property (nonatomic, assign) id<loginDelegate> delegate;
@property (nonatomic, retain) ObjectInfo *selectedObject;
@end
