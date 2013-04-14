//
//  DummyVOIPClass.m
//  interdigApp
//
//  Created by Merci Hernandez on 13/04/13.
//
//

#import "DummyVOIPClass.h"

@implementation DummyVOIPClass

- (UIView *)applicationStartWithSettings
{
    /* Dialpad */
    phoneViewController = [[[PhoneViewController alloc]
                            initWithNibName:nil bundle:nil] autorelease];
    phoneViewController.phoneCallDelegate = self;
    return phoneViewController.view;
    
}

-(void)makeCallFromSiphone
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *server = [userDef stringForKey: @"proxyServer"];
    NSArray *array = [server componentsSeparatedByString:@","];
    NSEnumerator *enumerator = [array objectEnumerator];
    while (server = [enumerator nextObject])
        if ([server length])break;
    if (!server || [server length] < 1)
        server = [userDef stringForKey: @"server"];
    
    NSRange range = [server rangeOfString:@":"
                                  options:NSCaseInsensitiveSearch|NSBackwardsSearch];
    if (range.length > 0)
    {
        server = [server substringToIndex:range.location];
    }
    
    callViewController = [[CallViewController alloc] initWithNibName:nil bundle:nil];
    callViewController.voipVC = self;
    
    [self.view addSubview: [self applicationStartWithSettings]];
    
    [self performSelector:@selector(sipConnect) withObject:nil afterDelay:0.2];
}


- (app_config_t *)pjConfig
{
    return &_app_config;
}

- (BOOL)sipStartup
{
    if (_app_config.pool)
        return YES;
    
    if (sip_startup(&_app_config) != PJ_SUCCESS)
    {
        return NO;
    }
    
    /** Call management **/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processCallState:)
                                                 name: kSIPCallState object:nil];
    
    /** Registration management */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processRegState:)
                                                 name: kSIPRegState object:nil];
    return YES;
}

- (void)sipCleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: kSIPRegState
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSIPCallState
                                                  object:nil];
    [self sipDisconnect];
    
    if (_app_config.pool != NULL)
    {
        sip_cleanup(&_app_config);
    }
}

- (BOOL)sipConnect
{
    pj_status_t status;
    
    if (![self sipStartup])
        return FALSE;
    
    if (_sip_acc_id == PJSUA_INVALID_ID)
    {
        if ((status = sip_connect(_app_config.pool, &_sip_acc_id)) != PJ_SUCCESS)
        {
            return FALSE;
        }
    }
    NSLog(@"ACC ID: %i", _sip_acc_id);
    
    return TRUE;
}

- (BOOL)sipDisconnect
{
    if ((_sip_acc_id != PJSUA_INVALID_ID) &&
        (sip_disconnect(&_sip_acc_id) != PJ_SUCCESS))
    {
        return FALSE;
    }
    
    _sip_acc_id = PJSUA_INVALID_ID;
    
    isConnected = FALSE;
    
    return TRUE;
}

- (void)callDisconnecting
{
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    if (pjsua_call_get_count() <= 1)
        [self performSelector:@selector(disconnected:)
                   withObject:nil afterDelay:1.0];
}

- (void) disconnected:(id)fp8
{
    [[callViewController view] removeFromSuperview];
    [callViewController release];
}

-(void) dialup:(NSString *)phoneNumber number:(BOOL)isNumber
{
    pjsua_call_id call_id;
    pj_status_t status;
    NSString *number;
    
    UInt32 hasMicro, size;
    
    // Verify if microphone is available (perhaps we should verify in another place ?)
    size = sizeof(hasMicro);
    AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable,
                            &size, &hasMicro);
    if (!hasMicro)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Microphone Available", @"SiphonApp")
                                                        message:NSLocalizedString(@"Connect a microphone to phone", @"SiphonApp")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"SiphonApp")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if (isNumber)
        number = [self normalizePhoneNumber:phoneNumber];
    else
        number = phoneNumber;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"removeIntlPrefix"])
    {
        number = [number stringByReplacingOccurrencesOfString:@"+"
                                                   withString:@""
                                                      options:0
                                                        range:NSMakeRange(0,1)];
    }
    else
    {
        NSString *prefix = [[NSUserDefaults standardUserDefaults] stringForKey:
                            @"intlPrefix"];
        if ([prefix length] > 0)
        {
            number = [number stringByReplacingOccurrencesOfString:@"+"
                                                       withString:prefix
                                                          options:0
                                                            range:NSMakeRange(0,1)];
        }
    }
    
    // Manage pause symbol
    NSArray * array = [number componentsSeparatedByString:@","];
    [callViewController setDtmfCmd:@""];
    if ([array count] > 1)
    {
        number = [array objectAtIndex:0];
        [callViewController setDtmfCmd:[array objectAtIndex:1]];
    }
    
    if (!isConnected)
    {
        _phoneNumber = [[NSString stringWithString: number] retain];
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"SIP server is unreachable!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    if ([self sipConnect])
    {
        NSRange range = [number rangeOfString:@"@"];
        if (range.location != NSNotFound)
        {
            status = sip_dial_with_uri(_sip_acc_id, [[NSString stringWithFormat:@"sip:%@", number] UTF8String], &call_id);
        }
        else {
            status = sip_dial(_sip_acc_id, [number UTF8String], &call_id);
        }
        if (status != PJ_SUCCESS)
        {
            // FIXME
            //[self displayStatus:status withTitle:nil];
            const pj_str_t *str = pjsip_get_status_text(status);
            NSString *msg = [[NSString alloc]
                             initWithBytes:str->ptr
                             length:str->slen
                             encoding:[NSString defaultCStringEncoding]];
            [self displayError:msg withTitle:@"registration error"];
        }
    }
}

- (NSString *)normalizePhoneNumber:(NSString *)number
{
    const char *phoneDigits = "22233344455566677778889999",
    *nb = [[number uppercaseString] UTF8String];
    int i, len = [number length];
    char *u, *c, *utf8String = (char *)calloc(sizeof(char), len+1);
    c = (char *)nb; u = utf8String;
    for (i = 0; i < len; ++c, ++i)
    {
        if (*c == ' ' || *c == '(' || *c == ')' || *c == '/' || *c == '-' || *c == '.')
            continue;
        if (*c >= 'A' && *c <= 'Z')
        {
            *u = phoneDigits[*c - 'A'];
        }
        else
            *u = *c;
        u++;
    }
    NSString * norm = [[NSString alloc] initWithUTF8String:utf8String];
    free(utf8String);
    return norm;
}

- (void)processCallState:(NSNotification *)notification
{
#if 0
    NSNumber *value = [[ notification userInfo ] objectForKey: @"CallID"];
    pjsua_call_id callId = [value intValue];
#endif
    int state = [[[ notification userInfo ] objectForKey: @"State"] intValue];
    
    switch(state)
    {
        case PJSIP_INV_STATE_NULL: // Before INVITE is sent or received.
            return;
        case PJSIP_INV_STATE_CALLING: // After INVITE is sent.
        case PJSIP_INV_STATE_INCOMING: // After INVITE is received.
            if (pjsua_call_get_count() == 1)
            {
                [self.view addSubview:callViewController.view];
                [callViewController retain];
            }
        case PJSIP_INV_STATE_EARLY: // After response with To tag.
        case PJSIP_INV_STATE_CONNECTING: // After 2xx is sent/received.
            break;
        case PJSIP_INV_STATE_CONFIRMED: // After ACK is sent/received.
            break;
        case PJSIP_INV_STATE_DISCONNECTED:
#if 0
            self.idleTimerDisabled = NO;
            if (pjsua_call_get_count() <= 1)
                [self performSelector:@selector(disconnected:)
                           withObject:nil afterDelay:1.0];
#endif
            break;
    }
    [callViewController processCall: [ notification userInfo ]];
}

- (void)processRegState:(NSNotification *)notification
{
    int status = [[[ notification userInfo ] objectForKey: @"Status"] intValue];
    BOOL launchDefault = YES;
    switch(status)
    {
        case 200: // OK
            isConnected = TRUE;
            if (launchDefault == NO)
            {
                //pjsua_call_id call_id;
                /*
                 NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateOfCall"];
                 NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:@"callURL"];
                 if (date && [date timeIntervalSinceNow] < kDelayToCall)
                 {
                 sip_dial_with_uri(_sip_acc_id, [url UTF8String], &call_id);
                 }
                 [self outOfTimeToCall];
                 */
            }
            break;
        case 403: // registration failed
        case 404: // not found
            //sprintf(TheGlobalConfig.accountError, "SIP-AUTH-FAILED");
            //break;
        case 503:
        case PJSIP_ENOCREDENTIAL:
            // This error is caused by the realm specified in the credential doesn't match the realm challenged by the server
            //sprintf(TheGlobalConfig.accountError, "SIP-REGISTER-FAILED");
            //break;
        default:
            isConnected = FALSE;
            //      [self sipDisconnect];
    }
}


-(void)displayError:(NSString *)error withTitle:(NSString *)title
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:error
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

-(void)displayParameterError:(NSString *)msg
{
    NSString *message = msg;
    NSString *error = [message stringByAppendingString:@"\nTo correct this parameter, select \"Settings\" from your Home screen"];
    
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                                     message:error
#if defined(CYDIA) && (CYDIA == 1)
                                                    delegate:self
#else
                                                    delegate:nil
#endif
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Settings", nil ] autorelease];
    [alert show];
}
@end
