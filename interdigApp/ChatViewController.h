//
//  ChatViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 14/10/12.
//
//

#import <UIKit/UIKit.h>
//#import "SSMessagesViewController.h"
#import "ASINetworkQueue.h"
#import "MasInfoViewController.h"

@interface ChatViewController : UIViewController <masInfoDelegate>
{
    NSTimer *mainTimer;
    BOOL forceRefresh;
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *dataBase;
@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) NSString *randomNumber;
@property (nonatomic, retain) NSMutableArray *chatArray;
@property (nonatomic, retain) ASINetworkQueue *requestQueue;
@end
