//
//  MainMenuViewController.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GeneralTableViewCell.h"
//#import "ASIHTTPRequest.h"
#import "AFNetworking.h"
#import "ObjectInfo.h"
#import "HJObjManager.h"
#import "SearchOverlayViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "UIAlertPrompt.h"
#import "DetailViewController.h"
#import "LoginViewController.h"

@interface MainMenuViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, UIActionSheetDelegate, EGORefreshTableHeaderDelegate, UIAlertViewDelegate, UITextFieldDelegate, newDataBaseDelegate, loginDelegate>
{
    IBOutlet UISearchBar *mySearchBar;
    IBOutlet UITableView *mainTableView;
    IBOutlet UITextField *dbSearch;
    IBOutlet UIImageView *wifi;
    IBOutlet UIButton *retryBtn;
    
    BOOL searching;
    BOOL letUserSelectRow;
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    SearchOverlayViewController *overlay;
    
    UIAlertPrompt *alertPrompt;
    
    IBOutlet UILabel *noSearchResults;
    HJObjManager *objManager;
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSString *dataBase;
@property (nonatomic, retain) ObjectInfo *thisObjectInfo;
@property (nonatomic, retain) NSMutableArray *objectArray;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, readonly) HJObjManager* objManager;
@property (nonatomic, retain) NSString *urlString;

-(void)openAlertViewWithTitle:(NSString *)title andPlaceHolderMessage:(NSString *)placeholder andButtontitle:(NSString *)btnTitle andTag:(NSInteger)tag;
-(void)showVideo:(NSString *)videoURL;
-(void)getInfoFromURL:(NSString *)url;
@end
