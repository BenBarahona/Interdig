//
//  VOIPCallViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 01/04/13.
//
//

#import <UIKit/UIKit.h>
#include <pjsua-lib/pjsua.h>
#import "CallViewController.h"

typedef struct app_config
{
    pj_pool_t             *pool;
    
    pjsua_config           cfg;
    pjsua_logging_config   log_cfg;
    pjsua_media_config     media_cfg;
    pjsua_acc_config acc_cfg;
    
    pjsua_transport_config udp_cfg;
    pjsua_transport_config rtp_cfg;
    
    pj_bool_t		    ringback_on;
    pj_bool_t		    ring_on;
    
    int           ringback_slot;
    int           ringback_cnt;
    pjmedia_port *ringback_port;
} app_config_struct;

@interface VOIPCallViewController : UIViewController <callViewDelegate>
{
    CallViewController    *callViewController;
}

@property app_config_struct _app_config;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *destinationNumber;
@end
