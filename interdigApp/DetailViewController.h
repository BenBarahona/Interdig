//
//  DetailViewController.h
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ObjectInfo.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"
#import "UIAlertPrompt.h"
#import "MasInfoViewController.h"

@protocol newDataBaseDelegate <NSObject>
-(void)createNewMainMenuWithDB:(NSString *)db;
@end

enum alertPromptType{
    CHAT = 1,
    MESSAGE = 2,
};

@interface DetailViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, UIWebViewDelegate, masInfoDelegate>
{
    IBOutlet UILabel *titulo;
    IBOutlet UILabel *descripcion;
    IBOutlet UILabel *telefono;
    IBOutlet UILabel *address1;
    IBOutlet UIButton *videoBtn;
    IBOutlet UIButton *telefonoBtn;
    IBOutlet UIButton *smsBtn;
    IBOutlet UIButton *mapsBtn;
    IBOutlet UIButton *webSiteBtn;
    IBOutlet UIButton *masInfo;
    IBOutlet HJManagedImageV *imageView;
    IBOutlet UIScrollView *scrollView;
    
    enum alertPromptType alertType;
}

@property (nonatomic, retain) NSString *dataBase;
@property (nonatomic, retain) ObjectInfo *thisObjectInfo;
@property (nonatomic, readonly) HJObjManager *objManager;
@property (nonatomic, assign) id<newDataBaseDelegate>delegate;

@end
