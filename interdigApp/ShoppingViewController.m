//
//  ShoppingViewController.m
//  interdigApp
//
//  Created by Merci Hernandez on 10/07/14.
//
//

#import "ShoppingViewController.h"
#import "ObjectInfo.h"
#import "UIImageView+AFNetworking.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController
@synthesize list;

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
    [self updateTotal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueClicked:(id)sender
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 114;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    shoppingViewCell *cell = (shoppingViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[shoppingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    ObjectInfo *item = [self.list objectAtIndex:indexPath.row];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.name.text = item.titulo;
    cell.price.text = [NSString stringWithFormat:@"Precio x unidad: %d", item.precio];
    cell.quantity.text = [NSString stringWithFormat:@"%d", item.cantidad];
    cell.mainImage.image = nil;
    [cell.mainImage setImageWithURL:[NSURL URLWithString:item.photoURL]];
    
    return cell;
}

- (void) increaseQuantityOfItemWithIndexPath:(NSIndexPath *)indexPath
{
    ObjectInfo *item = [self.list objectAtIndex:indexPath.row];
    item.cantidad++;
    
    [_tableView reloadData];
    [self updateTotal];
}

- (void) decreaseQuantityOfItemWithIndexPath:(NSIndexPath *)indexPath
{
    ObjectInfo *item = [self.list objectAtIndex:indexPath.row];
    if(item.cantidad > 0)
    {
        item.cantidad--;
    }
    [_tableView reloadData];
    [self updateTotal];
}

- (void) updateTotal
{
    total = 0;
    for(ObjectInfo *item in self.list)
    {
        NSInteger amount = item.precio * item.cantidad;
        total+= amount;
    }
    
    totalLabel.text = [NSString stringWithFormat:@"%d", total];
}

@end
