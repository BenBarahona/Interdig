/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008-2010 Samuel <samuelv0304@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#import "CallViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AddressBook/AddressBook.h>

//#include "call.h"
#include "dtmf.h"

#define HOLD_ON 1
#define kTransitionDuration	0.5

@interface CallViewController (private)

- (void)setSpeakerPhoneEnabled:(BOOL)enable;
- (void)setMute:(BOOL)enable;

@end

@implementation CallViewController

@synthesize dtmfCmd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
		// Initialization code
	}
	return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
	[view setBackgroundColor:[UIColor blackColor]];
    
    // create the container view which we will use for transition animation (centered horizontally)
	CGRect frame = CGRectMake(0.0f, 70.0f, 320.0f, 320.0f);
	_containerView = [[UIView alloc] initWithFrame:frame];
    
    // Phone Pad
    PhonePad *phonePad = [[PhonePad alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [phonePad setPlaysSounds: TRUE];
    [phonePad setDelegate: self];
    
    // Menu
    MenuCallView *menuView = [[MenuCallView alloc] initWithFrame: CGRectMake(18.0f, 52.0f, 285.0f, 216.0f)];
    [menuView setDelegate:self];
    [menuView setTitle:@"mute" image:[UIImage imageNamed:@"mute.png"] forPosition:0];
    [menuView setTitle:@"keypad" image:[UIImage imageNamed:@"dialer.png"] forPosition:1];
    [menuView setTitle:@"speaker" image:[UIImage imageNamed:@"speaker.png"] forPosition:2];
#if HOLD_ON
    [menuView setTitle:@"hold"
                 image:[UIImage imageNamed:@"hold.png"] forPosition:4];
#endif
    
    _switchViews[0] = phonePad;
    _switchViews[1] = menuView;
    _whichView = 0;
    
    // LCD
    _lcd = [[LCDView alloc] initWithDefaultSize];
    [_lcd setLabel:@""]; // name or number of callee
    [_lcd setText:@""];   // timer, call state for example
    [view addSubview: _lcd];
    
    
    _defaultBottomBar = [[BottomDualButtonBar alloc] initForEndCall];
    [[_defaultBottomBar button] addTarget:self action:@selector(endCallUpInside:)
                         forControlEvents:UIControlEventTouchUpInside];
    UIImage *buttonBackground = [UIImage imageNamed:@"bottombarblue.png"];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"bottombarblue_pressed.png"];
    _menuButton = [BottomButtonBar createButtonWithTitle:@"Hide Keypad"
                                                   image:nil
                                                   frame:CGRectZero
                                              background:buttonBackground
                                       backgroundPressed:buttonBackgroundPressed];
    [_menuButton addTarget:self action:@selector(flipKeypad)
          forControlEvents:UIControlEventTouchUpInside];
    
    self.view = view;
    [view release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _current_call = PJSUA_INVALID_ID;
    _new_call = PJSUA_INVALID_ID;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc
{
    [_menuButton release];
    [_defaultBottomBar release];
	[_dualBottomBar release];

    [_switchViews[0] release];
    [_switchViews[1] release];
    [_containerView release];
    
    [_buttonView release];
    
    [_lcd release];
    
	[super dealloc];
}

- (void)showKeypad:(BOOL)display animated:(BOOL)animated
{
    if ([_defaultBottomBar superview])
        [_defaultBottomBar setButton2:(display ? _menuButton : nil)];
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kTransitionDuration];
        
        [UIView setAnimationTransition:(display ?
                                        UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                               forView:_containerView cache:YES];
    }
	if (display)
	{
        [_switchViews[1] removeFromSuperview];
        [_containerView addSubview:_switchViews[0]];
        _whichView = 0;
	}
	else
	{
        [_switchViews[0] removeFromSuperview];
        [_containerView addSubview:_switchViews[1]];
        _whichView = 1;
	}
	
    if (animated)
        [UIView commitAnimations];
}

- (void)flipKeypad
{
    [self showKeypad:NO animated:YES];
}

- (void)showView:(UIView *)view display:(BOOL)display animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kTransitionDuration];
        
        [UIView setAnimationTransition:(display ?
                                        UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                               forView:_containerView cache:YES];
    }
    
    if (display)
    {
        [_switchViews[_whichView] removeFromSuperview];
        [_containerView addSubview:view];
    }
    else
    {
        [view removeFromSuperview];
        [_containerView addSubview:_switchViews[_whichView]];
    }
    
    if (animated)
        [UIView commitAnimations];
}

- (void)endingCallWithId:(UInt32)call_id
{
    NSLog(@"CALLING DISMISS VIEW");
    [self dismissView];
    
    dtmfCmd = nil;
    [self setSpeakerPhoneEnabled:NO];
    //[self setMute:NO];
    
    [_lcd setLabel:@"Llamada terminada... Porfavor espere"];
    
    _new_call = PJSUA_INVALID_ID;
    [_dualBottomBar removeFromSuperview];
    [_defaultBottomBar removeFromSuperview];
    [_containerView removeFromSuperview];
    
    // FIXME not here
    MenuCallView *_menuView = (MenuCallView *)_switchViews[1];
    [[_menuView buttonAtPosition:0] setSelected:NO];
    [[_menuView buttonAtPosition:2] setSelected:NO];
#if HOLD_ON
    [[_menuView buttonAtPosition:4] setSelected:NO];
#endif
}

-(void)dismissView
{
    NSLog(@"CALLING DELEGATE");
    [self.delegate callDisconnected:nil];
}

- (void)endCallUpInside:(id)fp8
{
    [self.delegate userEndedCall];
    [self endingCallWithId:_current_call];
    sip_hangup();
}

static void sip_hangup()
{
    pjsua_call_hangup_all();
}

- (void)timeout:(id)unused
{
    pjsua_call_info ci;
    if (_current_call == PJSUA_INVALID_ID)
        return;
    
    pjsua_call_get_info(_current_call, &ci);
    
    if (ci.connect_duration.sec >= 3600)
    {
        long sec = ci.connect_duration.sec % 3600;
        [_lcd setLabel:[NSString stringWithFormat:@"%ld:%02ld:%02ld",
                        ci.connect_duration.sec / 3600,
                        sec/60, sec%60]];
    }
    else
    {
        [_lcd setLabel:[NSString stringWithFormat:@"%02ld:%02ld",
                        (ci.connect_duration.sec)/60,
                        (ci.connect_duration.sec)%60]];
    }
}

#if 0
- (void)displayUserInfo:(pjsua_call_id)call_id
{
    pjsua_call_info ci;
    pjsip_name_addr *url;
    pjsip_sip_uri *sip_uri;
    pj_str_t tmp, dst;
    pj_pool_t     *pool;
    
    pool = pjsua_pool_create("call", 128, 128);
    
    if (pool)
    {
        pjsua_call_get_info(call_id, &ci);
        pj_strdup_with_null(pool, &tmp, &ci.remote_info);
        
        url = (pjsip_name_addr*)pjsip_parse_uri(pool, tmp.ptr, tmp.slen,
                                                PJSIP_PARSE_URI_AS_NAMEADDR);
        if (url != NULL)
        {
            NSString *phoneNumber = NULL;
            sip_uri = (pjsip_sip_uri*) pjsip_uri_get_uri(url->uri);
            pj_strdup_with_null(pool, &dst, &sip_uri->user);
            
            
            if (!phoneNumber)
            {
                if (url->display.slen)
                {
                    pj_strdup_with_null(pool, &dst, &url->display);
                }
                phoneNumber = [NSString stringWithUTF8String: pj_strbuf(&dst)];
            }
            [_lcd setText: phoneNumber];
            UIImage *image = [self findImage: record];
            [_lcd setSubImage: image];
        }
        else
        {
            [_lcd setText: @""];
            [_lcd setSubImage: nil];
        }
        
        pj_pool_release(pool);
    }
}
#endif

- (void)phonePad:(id)phonepad keyDown:(char)car
{
    // DTMF
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dtmfWithInfo"])
        sip_call_play_info_digit(_current_call, car);
    else
        sip_call_play_digit(_current_call, car);
}

- (void)composeDTMF
{
    pj_str_t dtmf = pj_str((char *)[dtmfCmd UTF8String]);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dtmfWithInfo"])
        sip_call_play_info_digits(_current_call, &dtmf);
    else
        sip_call_play_digits(_current_call, &dtmf);
}

//Find next call when current call is disconnected
- (BOOL)findNextCall
{
    int i, max;
    
    max = pjsua_call_get_max_count();
    for (i=_current_call+1; i<max; ++i)
    {
        if (pjsua_call_is_active(i))
        {
            _current_call = i;
            return TRUE;
        }
    }
    
    for (i=0; i<_current_call; ++i)
    {
        if (pjsua_call_is_active(i))
        {
            _current_call = i;
            return TRUE;
        }
    }
    
    _current_call = PJSUA_INVALID_ID;
    return FALSE;
}

- (void)processCall:(NSDictionary *)userInfo
{
    int state, call_id;
    int account_id;
    
    account_id = [[userInfo objectForKey: @"AccountID"] intValue];    
    call_id = [[userInfo objectForKey: @"CallID"] intValue];
    state = [[userInfo objectForKey: @"State"] intValue];
    
    switch(state)
    {
        case PJSIP_INV_STATE_CALLING: // After INVITE is sent.
            [_defaultBottomBar setButton2:nil];
            [self.view addSubview: _defaultBottomBar];
            [self showKeypad:NO animated:NO];
            [self.view addSubview:_containerView];
            
            [_lcd setLabel:@"calling..."];
            
            if (_current_call == PJSUA_INVALID_ID || _current_call == call_id)
                _current_call = call_id;
            else
                _new_call = call_id;
            break;
            
        case PJSIP_INV_STATE_INCOMING: // After INVITE is received.
            [_defaultBottomBar removeFromSuperview];
            if (pjsua_call_get_count() == 1)
            {
                [self.view addSubview: _dualBottomBar];
                [self showKeypad:NO animated:NO];
            }
            else
            {
                [self.view addSubview: _bottomBar]; // TODO displayed Ignore and hold+answer
                [self showView:_buttonView display:YES animated:YES];
            }
            
            [_lcd setLabel: @""];

            if (_current_call == PJSUA_INVALID_ID || _current_call == call_id)
                _current_call = call_id;
            else
                _new_call = call_id;
            break;
        case PJSIP_INV_STATE_EARLY: // After response with To tag.
            //[self.view addSubview: _phonePad];
            //[self showKeypad:YES animated:NO];
            //[self.view addSubview:_containerView];
        case PJSIP_INV_STATE_CONNECTING: // After 2xx is sent/received.
            break;
        case PJSIP_INV_STATE_CONFIRMED: // After ACK is sent/received.
            [_dualBottomBar removeFromSuperview];
            [_bottomBar removeFromSuperview];
            _current_call = call_id;
            _new_call = PJSUA_INVALID_ID;

            [self.view addSubview:_defaultBottomBar];
            [self.view addSubview:_containerView];
            if ([dtmfCmd length] > 0)
                [self performSelector:@selector(composeDTMF)
                           withObject:nil afterDelay:0.];
            _timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(timeout:)
                                                     userInfo:nil
                                                      repeats:YES] retain];
            [_timer fire];
            break;
        case PJSIP_INV_STATE_DISCONNECTED:
            sip_hangup();
            [self endingCallWithId:_current_call];
            break;
    }
}

- (void)setSpeakerPhoneEnabled:(BOOL)enable
{
    UInt32 route;
    route = enable ? kAudioSessionOverrideAudioRoute_Speaker :
    kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof(route), &route);
}

- (void)setMute:(BOOL)enable
{
    @try {
    if (enable)
        pjsua_conf_adjust_rx_level(0 , 0.0f);
    else
        pjsua_conf_adjust_rx_level(0 , 1.0f);
        
    }
    @catch(NSException *e)
    {
        NSLog(@"Exception: %@", e);
    }
}

- (void)setHoldEnabled: (BOOL)enable
{
    if (enable)
    {
        if (_current_call != PJSUA_INVALID_ID)
            pjsua_call_set_hold(_current_call, NULL);
    }
    else
    {
        if (_current_call != PJSUA_INVALID_ID)
            pjsua_call_reinvite(_current_call, PJ_TRUE, NULL);
    }
}

#pragma mark MenuCallView
- (void)menuButtonClicked:(NSInteger)num
{
    UIButton *button;
    MenuCallView *menuView = (MenuCallView *)_switchViews[1];
    
    button = [menuView buttonAtPosition:num];
    switch (num)
    {
        case 0: // Mute
            //button = [_menuView buttonAtPosition:num];
            [self setMute:!button.selected];
            [button setSelected:!button.selected];
            break;
        case 1: // Keypad
            [self showKeypad:YES animated:YES];
            break;
        case 2: // Speaker
            //button = [_menuView buttonAtPosition:num];
            [self setSpeakerPhoneEnabled:!button.selected];
            [button setSelected:!button.selected];
            break;
        case 3: // Add call
            break;
        case 4: // Hold
#if HOLD_ON
            //button = [_menuView buttonAtPosition:num];
            [self setHoldEnabled:!button.selected];
            [button setSelected:!button.selected];
#endif
            break;
        case 5: // Contacts
            break;
        default:
            break;
    }
}
 

#if 0
void audioSessionPropertyListener(void *inClientData, AudioSessionPropertyID inID,
                                  UInt32  inDataSize, const void  *inData)
{
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef dictionary = (CFDictionaryRef)inData;
		CFNumberRef reason = CFDictionaryGetValue (dictionary,kAudioSession_AudioRouteChangeKey_Reason);
        
		CFStringRef oldRoute = CFDictionaryGetValue (dictionary,kAudioSession_AudioRouteChangeKey_OldRoute);
	}
}

AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                audioSessionPropertyListener, NULL);
#endif

- (void)buttonClicked:(NSInteger)button
{
    NSLog(@"BTN CLICKED");
}

@end
