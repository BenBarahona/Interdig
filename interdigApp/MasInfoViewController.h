//
//  MasInfoViewController.h
//  interdigApp
//
//  Created by Ruben Bermudez on 03/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol masInfoDelegate <NSObject>
@optional -(void)showWebViewWithInfo:(NSDictionary *)info;
@optional -(void)showWebViewWithURL:(NSDictionary *)url;
-(void)showNewMenuViewWithDB:(NSString *)db;
@end

@interface MasInfoViewController : UITableViewController

@property (nonatomic, assign) id<masInfoDelegate>delegate;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSString *contentType;
@end
