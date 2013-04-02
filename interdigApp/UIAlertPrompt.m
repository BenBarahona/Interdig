//
//  UIAlertPrompt.m
//  FaceApp
//
//  Created by Benjamin Barahona on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertPrompt.h"

@implementation UIAlertPrompt
@synthesize textField, enteredText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    if (self = [super initWithTitle:title message:@"\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0,-1);
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = message;
        [self addSubview:titleLabel];
        [titleLabel release];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(16,60,252,31)];
        textField.font = [UIFont systemFontOfSize:18];
        textField.backgroundColor = [UIColor whiteColor];
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.layer.cornerRadius = 6.0f;
        
        UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
        textField.leftView = paddingView;
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textField becomeFirstResponder];
        [self addSubview:textField];
        [textField release];
    }
    
    return self;
}

- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return textField.text;
}
- (void)dealloc
{
    [textField release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
