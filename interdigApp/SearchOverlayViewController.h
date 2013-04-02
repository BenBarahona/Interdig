//
//  SearchOverlayViewController.h
//  interdigApp
//
//  Created by Merci Hernandez on 30/09/12.
//
//

#import <UIKit/UIKit.h>

@interface SearchOverlayViewController : UIView
{
    IBOutlet UIView *mainView;
}


@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) UISearchBar *searchBar;

@end
