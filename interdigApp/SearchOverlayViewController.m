//
//  SearchOverlayViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 30/09/12.
//
//

#import "SearchOverlayViewController.h"

@interface SearchOverlayViewController ()

@end

@implementation SearchOverlayViewController
@synthesize parentViewController, searchBar;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([parentViewController respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [parentViewController performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchBar];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"SearchOverlayViewController" owner:self options:nil];
        [self addSubview:[screens objectAtIndex:0]];
        [mainView setFrame:frame];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

/*
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
@end
