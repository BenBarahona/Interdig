//
//  VOIPCallViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 01/04/13.
//
//

#import "VOIPCallViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Util.h"
#define THIS_FILE "APP"

#define SIP_DOMAIN "8.6.240.214"
#define SIP_USER "1008"
#define SIP_PASSWD "8686"

// Ringtones
#define RINGBACK_FREQ1	    440
#define RINGBACK_FREQ2	    480
#define RINGBACK_ON         2000
#define RINGBACK_OFF        4000
#define RINGBACK_CNT        1
#define RINGBACK_INTERVAL   4000

#define RING_FREQ1	  800
#define RING_FREQ2	  640
#define RING_ON		    200
#define RING_OFF	    100
#define RING_CNT	    3
#define RING_INTERVAL	3000

@implementation VOIPCallViewController
@synthesize _app_config, domain, username, destinationNumber, password;


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
    timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(checkIfIsDisconnected:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processCallState:)
                                                 name:@"CallState" object:nil];
    
    callViewController = [[CallViewController alloc] initWithNibName:nil bundle:nil];
    [callViewController.view setFrame:CGRectMake(0, 0, 320, 460)];
    [callViewController.view setBounds:CGRectMake(0, 0, 320, 460)];
    [callViewController.view setClipsToBounds:YES];
    callViewController.delegate = self;
    
    isDisconnected = NO;
    didAnswerCall = NO;
    [self makeCall:self._app_config];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkIfIsDisconnected:(NSTimer *)_timer
{
    NSLog(@"CHECKING IF DISCONNECTED");
    if(isDisconnected)
    {
        if(!didAnswerCall)
            [Util showAlertWithTitle:@"Interdig" andMessage:@"El servicio de llamada se encuentra inactivo"];
        [_timer invalidate];
        [self disconnecting];
    }
}

- (void)processCallState:(NSNotification *)notification
{
    NSLog(@"NOTIFICATION INFO:%@", [notification userInfo]);
    
    [callViewController processCall: [ notification userInfo ]];
    
    int state = [[[ notification userInfo ] objectForKey: @"State"] intValue];
    
    switch(state)
    {
        case PJSIP_INV_STATE_NULL: // Before INVITE is sent or received.
        case PJSIP_INV_STATE_CALLING: // After INVITE is sent.
        case PJSIP_INV_STATE_INCOMING: // After INVITE is received.
            if (pjsua_call_get_count() == 1)
            {
                [self.view addSubview:callViewController.view];
            }
            
        case PJSIP_INV_STATE_EARLY: // After response with To tag.
        case PJSIP_INV_STATE_CONNECTING: // After 2xx is sent/received.
            break;
        case PJSIP_INV_STATE_CONFIRMED: // After ACK is sent/received.
            didAnswerCall = YES;
            break;
        case PJSIP_INV_STATE_DISCONNECTED:
            //[self callDisconnected:nil];
            //[self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

-(void)disconnecting
{
    NSLog(@"CLOSE VIEW AND PJSIP");
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    
    pjsua_destroy();
}

-(void)callDisconnected:(id)sender
{
    NSLog(@"DISMISS");
    isDisconnected = YES;
    [self performSelector:@selector(disconnecting) withObject:nil afterDelay:1.0];
}

-(void)userEndedCall
{
    didAnswerCall = YES;
}

// Display error and exit application
static void error_exit(const char *title, pj_status_t status)
{
    NSLog(@"ERROR: %s STATUS:%d", title, status);
    pjsua_perror(THIS_FILE, title, status);
    pjsua_destroy();
}

-(void)makeCall:(app_config_struct)this_config
{
    pjsua_acc_id acc_id;
    pj_status_t status;
    
    // Create pjsua first!
    status = pjsua_create();
    if (status != PJ_SUCCESS)
        error_exit("Error in pjsua_create()", status);
    
    // Create pool for application
    this_config.pool = pjsua_pool_create("pjsua", 1000, 1000);
    
    // Init pjsua
    pjsua_config cfg = this_config.cfg;
    pjsua_logging_config log_cfg = this_config.log_cfg;
    pjsua_acc_config acc_cfg = this_config.acc_cfg;
    pjsua_transport_config cfg2 = this_config.udp_cfg;
    
    
    pjsua_config_default(&cfg);
    cfg.cb.on_incoming_call = &on_incoming_call;
    cfg.cb.on_call_media_state = &on_call_media_state;
    cfg.cb.on_call_state = &on_call_state;
    
    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = 4;
    
    status = pjsua_init(&cfg, &log_cfg, NULL);
    if (status != PJ_SUCCESS)
        error_exit("Error in pjsua_init()", status);
    
    
    
    pjsua_media_config_default(&this_config.media_cfg);
    // Create ringback tones
    unsigned i, samples_per_frame;
    pjmedia_tone_desc tone[RING_CNT+RINGBACK_CNT];
    pj_str_t name;
    
    samples_per_frame = this_config.media_cfg.audio_frame_ptime *
    this_config.media_cfg.clock_rate *
    this_config.media_cfg.channel_count / 1000;
    
    // Ringback tone (call is ringing) 
    name = pj_str("ringback");
    
    status = pjmedia_tonegen_create2(this_config.pool, &name,
                                     this_config.media_cfg.clock_rate,
                                     this_config.media_cfg.channel_count,
                                     samples_per_frame,
                                     16, PJMEDIA_TONEGEN_LOOP,
                                     &this_config.ringback_port);
     
    if (status != PJ_SUCCESS)
        error_exit("Error creating ringback", status);
    
    
    pj_bzero(&tone, sizeof(tone));
    for (i=0; i<RINGBACK_CNT; ++i) {
        tone[i].freq1 = RINGBACK_FREQ1;
        tone[i].freq2 = RINGBACK_FREQ2;
        tone[i].on_msec = RINGBACK_ON;
        tone[i].off_msec = RINGBACK_OFF;
    }
    tone[RINGBACK_CNT-1].off_msec = RINGBACK_INTERVAL;
    
    pjmedia_tonegen_play(this_config.ringback_port, RINGBACK_CNT, tone,
                         PJMEDIA_TONEGEN_LOOP);
    
    
    status = pjsua_conf_add_port(this_config.pool, this_config.ringback_port,
                                 &this_config.ringback_slot);
    if (status != PJ_SUCCESS)
        error_exit("Error creating ringback", status);
    
    
    // Add UDP transport. 
    pjsua_transport_config_default(&cfg2);
    cfg2.port = 5060;
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg2, NULL);
    if (status != PJ_SUCCESS)
        error_exit("Error creating transport", status);
        
    
    // Initialization is done, now start pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS)
        error_exit("Error starting pjsua", status);

    // Register to SIP server by creating SIP account.
    NSString *sipUser = [NSString stringWithFormat:@"sip:%@@%@", self.username, self.domain];
    NSString *sipDomain = [NSString stringWithFormat:@"sip:%@", self.domain];
    NSString *sipPassword = self.password;
    NSString *sipNumber = [NSString stringWithFormat:@"sip:%@@%@", self.destinationNumber, self.domain];
    
    pjsua_acc_config_default(&acc_cfg);
    acc_cfg.id = pj_str((char *)[sipUser UTF8String]);
    acc_cfg.reg_uri = pj_str((char *)[sipDomain UTF8String]);
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].realm = pj_str("*");
    acc_cfg.cred_info[0].scheme = pj_str("digest");
    acc_cfg.cred_info[0].username = pj_str((char *)[self.username UTF8String]);
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str((char *)[sipPassword UTF8String]);
    
    status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &acc_id);
    if (status != PJ_SUCCESS)
        error_exit("Error adding account", status);
    
    

    // If URL is specified, make call to the URL.
    char *c = (char *)[sipNumber UTF8String];
    NSLog(@"NUMBER: %s", c);
    pj_str_t uri = pj_str(c);
    
    status = pjsua_call_make_call(acc_id, &uri, 0, NULL, NULL, NULL);
    if (status != PJ_SUCCESS)
        error_exit("Error making call", status);
    
    self._app_config = this_config;
}

static void postCallStateNotification(pjsua_call_id call_id, const pjsua_call_info *ci)
{
    NSString *remoteInfo = @"", *remoteContact = @"";
    NSAutoreleasePool *autoreleasePool = [[ NSAutoreleasePool alloc ] init];
    
    if (ci->remote_info.slen)
        remoteInfo = [NSString stringWithUTF8String:ci->remote_info.ptr];
    if (ci->remote_contact.slen)
        remoteContact = [NSString stringWithUTF8String:ci->remote_contact.ptr];
    // FIXME: create an Object, InCall for example ?
    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt: call_id], @"CallID",
                              [NSNumber numberWithInt: ci->role], @"Role",
                              [NSNumber numberWithInt: ci->acc_id], @"AccountID",
                              remoteInfo, @"RemoteInfo",
                              remoteContact, @"RemoteContact",
                              [NSNumber numberWithInt: ci->state], @"State",
                              [NSNumber numberWithInt:ci->last_status], @"LastStatus",
                              [NSNumber numberWithInt:ci->media_status], @"MediaStatus",
                              [NSNumber numberWithInt:ci->conf_slot], @"ConfSlot",
                              [NSNumber  numberWithLong:ci->connect_duration.sec], @"ConnectDuration",
                              [NSNumber  numberWithLong:ci->total_duration.sec], @"TotalDuration",
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallState" object:nil userInfo:userinfo];

    [autoreleasePool release ];
}

static void ring_init(app_config_struct app_config)
{
    // Create ringback tones
    unsigned i, samples_per_frame;
    pjmedia_tone_desc tone[RING_CNT+RINGBACK_CNT];
    pj_str_t name;
    pj_status_t status;
    
    samples_per_frame = app_config.media_cfg.audio_frame_ptime *
    app_config.media_cfg.clock_rate *
    app_config.media_cfg.channel_count / 1000;
    
    // Ringback tone (call is ringing)
    name = pj_str("ringback");
    status = pjmedia_tonegen_create2(app_config.pool, &name,
                                     app_config.media_cfg.clock_rate,
                                     app_config.media_cfg.channel_count,
                                     samples_per_frame,
                                     16, PJMEDIA_TONEGEN_LOOP,
                                     &app_config.ringback_port);
    if (status != PJ_SUCCESS)
        error_exit("Error creating ringback", status);
    
    
    pj_bzero(&tone, sizeof(tone));
    for (i=0; i<RINGBACK_CNT; ++i) {
        tone[i].freq1 = RINGBACK_FREQ1;
        tone[i].freq2 = RINGBACK_FREQ2;
        tone[i].on_msec = RINGBACK_ON;
        tone[i].off_msec = RINGBACK_OFF;
    }
    tone[RINGBACK_CNT-1].off_msec = RINGBACK_INTERVAL;
    
    pjmedia_tonegen_play(app_config.ringback_port, RINGBACK_CNT, tone,
                         PJMEDIA_TONEGEN_LOOP);
    
    
    status = pjsua_conf_add_port(app_config.pool, app_config.ringback_port,
                                 &app_config.ringback_slot);
    if (status != PJ_SUCCESS)
        error_exit("Error creating ringback", status);
}

static void ring_stop(app_config_struct *app_config)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    VOIPCallViewController *thisVC = app.voipVC;
    NSLog(@"DELEGATE VOIP: %@", thisVC);
    if (app_config->ringback_on)
    {
        app_config->ringback_on = PJ_FALSE;
        
        pj_assert(app_config->ringback_cnt > 0);
        if (--app_config->ringback_cnt == 0 &&
            app_config->ringback_slot != PJSUA_INVALID_ID)
        {
            //pjsua_conf_disconnect(app_config->ringback_slot, 0);
            pjmedia_tonegen_rewind(app_config->ringback_port);
        }
    }
    
    thisVC._app_config = *(app_config);
}

static void ringback_start(app_config_struct *app_config)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    VOIPCallViewController *thisVC = app.voipVC;
    
    if (app_config->ringback_on)
        return;
    
    app_config->ringback_on = PJ_TRUE;
    
    if (++app_config->ringback_cnt == 1 &&
        app_config->ringback_slot!=PJSUA_INVALID_ID)
    {
        pjsua_conf_connect(app_config->ringback_slot, 0);
    }
    
    thisVC._app_config = *(app_config);
}

// Callback called by the library upon receiving incoming call
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    NSLog(@"Incoming call!");
}

// Callback called by the library when call's state has changed
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    VOIPCallViewController *thisVC = app.voipVC;
    app_config_struct config = thisVC._app_config;
    
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) // Session is terminated.
    {
        NSLog(@"DISCONNECTED!");
        ring_stop(&config);
    }
    else if (ci.state == PJSIP_INV_STATE_EARLY)
    {
        ringback_start(&config);
	}
    
    
    NSString *remoteInfo = @"", *remoteContact = @"";
    if (ci.remote_info.slen)
        remoteInfo = [NSString stringWithUTF8String:ci.remote_info.ptr];
    if (ci.remote_contact.slen)
        remoteContact = [NSString stringWithUTF8String:ci.remote_contact.ptr];
    
    if (ci.state != PJSIP_INV_STATE_NULL)
    {
        postCallStateNotification(call_id, &ci);
    }
    
    PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id,
              (int)ci.state_text.slen,
              ci.state_text.ptr));
}

// Callback called by the library when call's media state has changed
static void on_call_media_state(pjsua_call_id call_id)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    VOIPCallViewController *thisVC = app.voipVC;
    app_config_struct config = thisVC._app_config;
    
    pjsua_call_info ci;
    ring_stop(&config);
    
    pjsua_call_get_info (call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

@end
