//
//  MainMenuViewController.m
//  interdigApp
//
//  Created by Ruben Bermudez on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "GeneralTableViewCell.h"
#import "Util.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "WebViewController.h"
#import "InputDataViewController.h"
#import "MapLocationViewController.h"

#define DB_NAME @"expo"

@implementation MainMenuViewController
@synthesize thisObjectInfo, objectArray, objManager, searchResults, urlString, dataBase, request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *) objectArray
{
    if(!objectArray)
    {
        objectArray = [[NSMutableArray alloc] init];
    }
    return objectArray;
}

-(NSMutableArray *) searchResults
{
    if(!searchResults)
    {
        searchResults = [[NSMutableArray alloc] init];
    }
    return searchResults;
}

- (HJObjManager*) objManager
{
    if (!objManager) {
        //if you are using for full screen images, you'll need a smaller memory cache:
        objManager = [[HJObjManager alloc] initWithLoadingBufferSize:5 memCacheSize:5];
        
        NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/interdigApp/"] ;
        HJMOFileCache* fileCache = [[HJMOFileCache alloc] initWithRootPath:cacheDirectory];
        objManager.fileCache = fileCache;
        
        [fileCache release];
    }
    return objManager;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!self.urlString)
    {
        if(!self.dataBase)
        {
            self.dataBase = DB_NAME;
            self.title = DB_NAME;
            self.urlString = [NSString stringWithFormat:@"http://www.interdig.org/jce1.cfm?db=%@&cl=1000", self.dataBase];
            //self.urlString = @"http://www.interdig.org/jce1.cfm?db=rio&cl=3259";
        }
        else if(!self.thisObjectInfo)
        {
            self.title = self.dataBase;
            self.urlString = [NSString stringWithFormat:@"http://www.interdig.org/jce1.cfm?db=%@&cl=1000", self.dataBase];
        }
        else
        {
            /*
             UIImage *btnImage = [UIImage imageNamed:[self getBackButtonImageString]];
             UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
             [back setBackgroundImage:btnImage forState:UIControlStateNormal];
             [back addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
             [back setTitle:@"Atras" forState:UIControlStateNormal];
             [back.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
             
             UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:back];
             //UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Atras" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
             //[backBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
             self.navigationItem.leftBarButtonItem = backBtn;
             
             [back release];
             [backBtn release];
             */
            self.urlString = [NSString stringWithFormat:@"http://www.interdig.org/jce1.cfm?db=%@&cl=%@", self.dataBase, self.thisObjectInfo.claveSig];
        }
    }
    
    [self getInfoFromURL:self.urlString];
    
    if (_refreshHeaderView == nil)
    {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - mainTableView.bounds.size.height, self.view.frame.size.width, mainTableView.bounds.size.height)];
		view.delegate = self;
		[mainTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if(self.thisObjectInfo != nil)
    {
        if([self.thisObjectInfo.dataBase isEqualToString:@""])
            dbSearch.text = self.dataBase;
        else
            dbSearch.text = self.thisObjectInfo.dataBase;
    }
    else if(self.dataBase != nil)
    {
        dbSearch.text = self.dataBase;
    }
    else
    {
        NSLog(@"%@", self.dataBase);
        dbSearch.text = @"interdig";
    }
}

-(IBAction)retryConection:(id)sender
{
    [self getInfoFromURL:self.urlString];
}

-(void)backButtonClicked:(id)button
{
    if(self.request)
    {
        self.request.delegate = nil;
        [self.request cancel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil
    self.request = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)getInfoFromURL:(NSString *)url
{
    if([Util internetConnectionAvailable])
    {
        NSLog(@"URL :%@", url);
        NSURL *mainURL = [NSURL URLWithString:url];
        
        self.request = [ASIHTTPRequest requestWithURL:mainURL];
        self.request.delegate = self;
        self.request.timeOutSeconds = 30;
        [self.request setDidFinishSelector:@selector(didFinishRequest:)];
        [self.request setDidFailSelector:@selector(didFailRequest:)];
        
        [self.request startAsynchronous];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Obteniendo datos...";
        
        wifi.hidden = noSearchResults.hidden = retryBtn.hidden = YES;
    }
    else
    {
        retryBtn.hidden = wifi.hidden = noSearchResults.hidden = NO;
        noSearchResults.text = @"Conexion de internet es necesaria para obtener datos";
        [self.objectArray removeAllObjects];
        [mainTableView reloadData];
    }
}

-(void)didFinishRequest:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([_request responseStatusCode] == 200)
    {
        NSString *response = [_request responseString];
        NSArray *dict = [response JSONValue];
        //NSLog(@"%@", response);
        [self.objectArray removeAllObjects];
        for(NSDictionary *item in dict)
        {
            ObjectInfo *newItem = [[ObjectInfo alloc] initWithDictionary:item];
            [self.objectArray addObject:newItem];
            [newItem release];
        }
        [mainTableView reloadData];
    }
    else if([_request responseStatusCode] >= 500)
    {
        //[Util showAlertWithTitle:@"Error de Servidor" andMessage:[NSString stringWithFormat:@"El servidor no responde, espere unos minutos e intente de nuevo\n Codigo: %d", [_request responseStatusCode]]];
        [self.objectArray removeAllObjects];
        [mainTableView reloadData];
        retryBtn.hidden = wifi.hidden = noSearchResults.hidden = NO;
        noSearchResults.text = @"El servidor no responde, espere unos minutos e intente de nuevo";
    }
    else
    {
        retryBtn.hidden = wifi.hidden = noSearchResults.hidden = NO;
        [self.objectArray removeAllObjects];
        [mainTableView reloadData];
        noSearchResults.text = @"Error de Conexion; Asegure su conexion de internet e intente de nuevo";
        //[Util showAlertWithTitle:@"Error de Conexion" andMessage:[NSString stringWithFormat:@"Asegure su conexion de internet e intente de neuvo\n Codigo: %d", [_request responseStatusCode]]];
    }
}

-(void)didFailRequest:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    retryBtn.hidden = wifi.hidden = noSearchResults.hidden = NO;
    [self.objectArray removeAllObjects];
    [mainTableView reloadData];
    noSearchResults.text = @"Error de Conexion; Asegure su conexion de internet e intente de nuevo";
    if([_request responseStatusCode] >= 500)
    {
        noSearchResults.text = @"El servidor no responde, espere unos minutos e intente de nuevo";
        //[Util showAlertWithTitle:@"Error de Servidor" andMessage:[NSString stringWithFormat:@"El servidor no responde, espere unos minutos e intente de nuevo\n Codigo: %d", [_request responseStatusCode]]];
    }
    else
    {
        noSearchResults.text = @"Error de Conexion; Asegure su conexion de internet e intente de nuevo";
        //[Util showAlertWithTitle:@"Error de Conexion" andMessage:[NSString stringWithFormat:@"Asegure su conexion de internet e intente de neuvo\n Codigo: %d", [_request responseStatusCode]]];
    }
}

-(void)didSelectOptionsButton
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Opciones" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Enviar SMS a Todos",@"Enviar E-Mail a Todos", nil];
    action.tag = 3000;
    
    
    if(self.tabBarController.tabBar)
        [action showFromTabBar:self.tabBarController.tabBar];
    else
        [action showInView:self.view];
    [action release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(searching)
        return [self.searchResults count];
    else
        return [self.objectArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GeneralTableViewCell";
    GeneralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[[GeneralTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    ObjectInfo *thisItem = nil;
    thisItem = searching ? [self.searchResults objectAtIndex:indexPath.row] : [self.objectArray objectAtIndex:indexPath.row];
    
    //Either SMS, Web Site, Video, or Email
    if( ((thisItem.sms != nil && ![thisItem.sms isEqualToString:@""]) ||
         (thisItem.video != nil && ![thisItem.video isEqualToString:@""]) ||
         (thisItem.email != nil && ![thisItem.email isEqualToString:@""] && ![thisItem.email isEqualToString:@" "]) ||
         (thisItem.siteURL != nil && ![thisItem.siteURL isEqualToString:@""]))
       /*&& [thisItem.dataBase isEqualToString:@""]*/)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        more.tag = indexPath.row;
        [more setImage:[UIImage imageNamed:[self getIconImageString]] forState:UIControlStateNormal];
        [more addTarget:self action:@selector(didSelectAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = more;
        [more release];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.labelText.text = thisItem.titulo;
    cell.imageURL = thisItem.photoURL;
    [cell.cellImage setImage:[UIImage imageNamed:@""]];
    
    if(![thisItem.photoURL isEqualToString:@""])
    {
        cell.cellImage.url = [NSURL URLWithString:thisItem.photoURL];
        [cell.cellImage showLoadingWheel];
        [self.objManager manage:cell.cellImage];
    }
    if([thisItem.claveActual intValue] > 3000)
    {
        cell.chatLabel.hidden = cell.chatImage.hidden = NO;
        if(thisItem.chatOn)
        {
            cell.chatImage.image = [UIImage imageNamed:@"greenButton"];
        }
        else
        {
            cell.chatImage.image = [UIImage imageNamed:@"redButton"];
        }
    }
    else
    {
        cell.chatLabel.hidden = cell.chatImage.hidden = YES;
    }
    
    if(searching || [thisItem.claveActual intValue] > 3000)
    {
        UIImage *btnImage = [UIImage imageNamed:@"replyall"];
        UIButton *barBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
        [barBtn addTarget:self action:@selector(didSelectOptionsButton) forControlEvents:UIControlEventTouchUpInside];
        [barBtn setImage:btnImage forState:UIControlStateNormal];
        UIBarButtonItem *options = [[UIBarButtonItem alloc] initWithCustomView:barBtn];
        self.navigationItem.rightBarButtonItem = options;
        [barBtn release];
        [options release];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    
    if(self.dataBase == nil || [self.dataBase isEqualToString:@"interdig"])
    {
        switch (indexPath.row) {
            case 0:
                cell.bgImage.image = [UIImage imageNamed:@"cell_alba"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_alba_down"];
                break;
            case 1:
                cell.bgImage.image = [UIImage imageNamed:@"cell_brasil"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_brasil_down"];
                break;
            case 2:
                cell.bgImage.image = [UIImage imageNamed:@"cell_fecamco"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_fecamco_down"];
                break;
            case 3:
                cell.bgImage.image = [UIImage imageNamed:@"cell_honduras"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_honduras_down"];
                break;
            case 4:
                cell.bgImage.image = [UIImage imageNamed:@"cell_intur"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_intur_down"];
                break;
            case 5:
                cell.bgImage.image = [UIImage imageNamed:@"cell_orion"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_orion_down"];
                break;
            case 6:
                cell.bgImage.image = [UIImage imageNamed:@"cell_koica"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_koica_down"];
                break;
            case 7:
                cell.bgImage.image = [UIImage imageNamed:@"cell_news"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_news_down"];
                break;
            case 8:
                cell.bgImage.image = [UIImage imageNamed:@"cell_apparel"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_apparel_down"];
                break;
            case 9:
                cell.bgImage.image = [UIImage imageNamed:@"cell_turismo"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_turismo_down"];
                break;
            case 10:
                cell.bgImage.image = [UIImage imageNamed:@"cell_villeda"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_villeda_down"];
                break;
            case 11:
                cell.bgImage.image = [UIImage imageNamed:@"cell_workersHonduras"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_workersHonduras_down"];
                break;
            default:
                cell.bgImage.image = [UIImage imageNamed:@"cell_fecamco"];
                cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_fecamco_down"];
                break;
        }
    }
    else if([self.dataBase isEqualToString:@"alba"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_alba"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_alba_down"];
    }
    else if([self.dataBase isEqualToString:@"fecamco"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_fecamco"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_fecamco_down"];
    }
    else if([self.dataBase isEqualToString:@"egob"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_honduras"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_honduras_down"];
    }
    else if([self.dataBase isEqualToString:@"intur"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_intur"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_intur_down"];
    }
    else if([self.dataBase isEqualToString:@"orion"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_orion"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_orion_down"];
    }
    else if([self.dataBase isEqualToString:@"kepco"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_koica"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_koica_down"];
    }
    else if([self.dataBase isEqualToString:@"news"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_news"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_news_down"];
    }
    else if([self.dataBase isEqualToString:@"offprice"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_apparel"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_apparel_down"];
    }
    else if([self.dataBase isEqualToString:@"turismo1"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_turismo"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_turismo_down"];
    }
    else if([self.dataBase isEqualToString:@"comision"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_villeda"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_villeda_down"];
    }
    else if([self.dataBase isEqualToString:@"canada1"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_workersHonduras"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_workersHonduras_down"];
    }
    else if([self.dataBase isEqualToString:@"brazil"] || [self.dataBase isEqualToString:@"saopaulo"]
            || [self.dataBase isEqualToString:@"rio"] || [self.dataBase isEqualToString:@"belohorizonte"]
            || [self.dataBase isEqualToString:@"cuiaba"] || [self.dataBase isEqualToString:@"brasilia"]
            || [self.dataBase isEqualToString:@"curitiba"] || [self.dataBase isEqualToString:@"fortaleza"]
            || [self.dataBase isEqualToString:@"manaus"] || [self.dataBase isEqualToString:@"natal"]
            || [self.dataBase isEqualToString:@"portoalegre"] || [self.dataBase isEqualToString:@"recife"]
            || [self.dataBase isEqualToString:@"bahia"])
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_brasil"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_brasil_down"];
    }
    else
    {
        cell.bgImage.image = [UIImage imageNamed:@"cell_fecamco"];
        cell.bgImage.highlightedImage = [UIImage imageNamed:@"cell_fecamco_down"];
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ObjectInfo *selected = nil;
    selected = searching ? [self.searchResults objectAtIndex:indexPath.row] : [self.objectArray objectAtIndex:indexPath.row];
    
    if(!searching && [selected.claveActual intValue] < 3000)
    {
        if(selected.tipo > 2)
        {
            MapLocationViewController *map = [[MapLocationViewController alloc] initWithNibName:@"MapLocationViewController" bundle:nil];
            map.title = selected.titulo;
            map.database = self.dataBase;
            map.tipoURL = selected.tipo;
            
            [self.navigationController pushViewController:map animated:YES];
            [map release];
            
            return;
        }
        
        if([selected.claveActual isEqualToString:@"1000"] || ![selected.claveSig isEqualToString:selected.claveActual])
        {
            MainMenuViewController *detailViewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
            detailViewController.thisObjectInfo = selected;
            if([selected.dataBase isEqualToString:@""])
            {
                detailViewController.dataBase = self.dataBase;
            }
            else
            {
                detailViewController.dataBase = selected.dataBase;
            }
            detailViewController.title = selected.titulo;
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
        }
        else if(selected.inpid != 0)
        {
            NSLog(@"SELECTED: %@", selected.dataInput);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if(selected.security && [defaults objectForKey:@"cta_user"] == nil && [defaults objectForKey:@"cta_password"] == nil)
            {
                LoginViewController *login = [[LoginViewController alloc] init];
                login.database = self.dataBase;
                login.objectId = selected.objectID;
                login.delegate = self;
                login.selectedObject = selected;
                [self.navigationController presentViewController:login animated:YES completion:nil];
                [login release];
            }
            else
            {
                InputDataViewController *input = [[InputDataViewController alloc] init];
                input.items = selected.dataInput;
                input.title = selected.titulo;
                input.database = self.dataBase;
                input.objectId = selected.objectID;
                [self.navigationController pushViewController:input animated:YES];
                [input release];
            }
        }
        else
        {
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
        }
    }
    else
    {
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        detailViewController.delegate = self;
        detailViewController.dataBase = self.dataBase;
        detailViewController.thisObjectInfo = selected;
        detailViewController.title = selected.titulo;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

-(void)loginDidFinish:(NSDictionary *)response WithObject:(ObjectInfo *)info
{
    InputDataViewController *input = [[InputDataViewController alloc] init];
    input.items = info.dataInput;
    input.title = info.titulo;
    input.database = self.dataBase;
    input.objectId = info.objectID;
    [self.navigationController pushViewController:input animated:YES];
    
    [input release];
}

-(void)createNewMainMenuWithDB:(NSString *)db
{
    MainMenuViewController *detailViewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
    detailViewController.title = db;
    detailViewController.dataBase = db;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void)didSelectAccessoryButton:(UIButton *)button
{
    [self tableView:mainTableView accessoryButtonTappedForRowWithIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ObjectInfo *selected = nil;
    selected = searching ? [self.searchResults objectAtIndex:indexPath.row] : [self.objectArray objectAtIndex:indexPath.row];
    
    NSMutableArray *opciones = [[NSMutableArray alloc] init];
    if(![selected.video isEqualToString:@""] && ![selected.video isEqualToString:@" "])
        [opciones addObject:@"Ver Video"];
    if(![selected.sms isEqualToString:@""] && ![selected.sms isEqualToString:@" "])
        [opciones addObject:@"Enviar SMS"];
    if(![selected.email isEqualToString:@""] && ![selected.email isEqualToString:@" "])
        [opciones addObject:@"Enviar E-Mail"];
    if(![selected.siteURL isEqualToString:@""] && ![selected.siteURL isEqualToString:@" "])
        [opciones addObject:@"Pagina Web"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Opciones" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [opciones count]; i++)
    {
        [actionSheet addButtonWithTitle:[opciones objectAtIndex:i]];
    }
    [actionSheet addButtonWithTitle:@"Cancelar"];
    actionSheet.cancelButtonIndex = opciones.count;
    actionSheet.tag = indexPath.row;
    
    if(self.tabBarController.tabBar)
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    else
        [actionSheet showInView:self.view];
    [actionSheet release];
    [opciones release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if(actionSheet.tag == 3000)
    {
        if([title isEqualToString:@"Enviar SMS a Todos"])
        {
            [self openAlertViewWithTitle:title andPlaceHolderMessage:@"Escriba Mensajito" andButtontitle:@"Enviar" andTag:0];
        }
        else if([title isEqualToString:@"Enviar E-Mail a Todos"])
        {
            [self openAlertViewWithTitle:title andPlaceHolderMessage:@"Escriba texto" andButtontitle:@"Enviar" andTag:0];
        }
    }
    else
    {
        ObjectInfo *selected = nil;
        selected = searching ? [self.searchResults objectAtIndex:actionSheet.tag] : [self.objectArray objectAtIndex:actionSheet.tag];
        
        if([title isEqualToString:@"Ver Video"])
        {
            [self showVideo:selected.video];
        }
        else if([title isEqualToString:@"Enviar SMS"])
        {
            [self openAlertViewWithTitle:@"Enviar SMS" andPlaceHolderMessage:@"Escriba Mensajito" andButtontitle:@"Enviar" andTag:actionSheet.tag];
        }
        else if([title isEqualToString:@"Enviar E-Mail"])
        {
            [self openAlertViewWithTitle:@"Enviar E-Mail" andPlaceHolderMessage:@"Escriba texto" andButtontitle:@"Enviar" andTag:actionSheet.tag];
        }
        else if([title isEqualToString:@"Pagina Web"])
        {
            WebViewController *web = [[WebViewController alloc] init];
            web.webURL = selected.siteURL;
            [self.navigationController pushViewController:web animated:YES];
            [web release];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *entered = @"";
        if([alertView isKindOfClass:[UIAlertPrompt class]])
        {
            entered = [(UIAlertPrompt *)alertView enteredText];
        }
        else{
            UITextField *textField = [alertView textFieldAtIndex:0];
            entered = textField.text;
        }
        
        if([entered isEqualToString:@""])
        {
            [Util showAlertWithTitle:@"Error" andMessage:@"No puede enviar un mensaje vacío"];
            return;
        }
        entered = [entered stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        ObjectInfo *selected = nil;
        selected = searching ? [self.searchResults objectAtIndex:alertView.tag] : [self.objectArray objectAtIndex:alertView.tag];
        
        if([[alertView title] isEqualToString:@"Enviar SMS"])
        {
            NSString *_urlString = @"";
            
            /*
             if([selected.claveSig intValue] < 3000)
             {
             _urlString = [NSString stringWithFormat:@"http://www.interdig.org/jsmsa.cfm?db=%@&cl=%@&men=%@", self.dataBase, selected.claveSig, entered];
             }
             else
             {
             */
            _urlString = [NSString stringWithFormat:@"http://www.interdig.org/jsms.cfm?db=%@&id=%@&men=%@", self.dataBase, selected.objectID, entered];
            //}
            
            NSURL *url = [NSURL URLWithString:_urlString];
            
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setDidFailSelector:@selector(enviarMensajitoFailed:)];
            [self.request setDidFinishSelector:@selector(enviarMensajitoFinished:)];
            [self.request setDelegate:self];
            [self.request setTimeOutSeconds:30];
            [self.request startAsynchronous];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Enviando SMS";
            
        }
        else if([[alertView title] isEqualToString:@"Enviar E-Mail"])
        {
            NSString *_urlString = @"";
            /*
             if([selected.claveSig intValue] < 3000)
             {
             _urlString = [NSString stringWithFormat:@"http://www.interdig.org/jemaila.cfm?db=%@&cl=%@&men=%@", self.dataBase, selected.claveSig, entered];
             }
             else
             {
             */
            _urlString = [NSString stringWithFormat:@"http://www.interdig.org/jemail.cfm?db=%@&id=%@&men=%@", self.dataBase, selected.objectID, entered];
            //}
            
            NSURL *url = [NSURL URLWithString:_urlString];
            
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setDidFailSelector:@selector(enviarEmailFailed:)];
            [self.request setDidFinishSelector:@selector(enviarEmailFinished:)];
            [self.request setDelegate:self];
            [self.request setTimeOutSeconds:30];
            [self.request startAsynchronous];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Enviando E-Mail";
        }
        else if([alertView.title isEqualToString:@"Enviar SMS a Todos"])
        {
            NSLog(@"Enviar SMS a Todos");
            NSString *_urlString = @"";
            
            _urlString = searching ? [NSString stringWithFormat:@"http://www.interdig.org/jsmsab.cfm?db=%@&inp=%@&men=%@", self.dataBase, mySearchBar.text, entered] : [NSString stringWithFormat:@"http://www.interdig.org/jsmsa.cfm?db=%@&cl=%@&men=%@", self.dataBase, self.thisObjectInfo.claveSig, entered];
            
            NSURL *url = [NSURL URLWithString:_urlString];
            
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setDidFailSelector:@selector(enviarMensajitoFailed:)];
            [self.request setDidFinishSelector:@selector(enviarMensajitoFinished:)];
            [self.request setDelegate:self];
            [self.request setTimeOutSeconds:30];
            [self.request startAsynchronous];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Enviando SMS";
        }
        else if([alertView.title isEqualToString:@"Enviar E-Mail a Todos"])
        {
            NSLog(@"Enviar EMAIL a Todos");
            NSString *_urlString;
            _urlString = searching ? [NSString stringWithFormat:@"http://www.interdig.org/jemailab.cfm?db=%@&inp=%@&men=%@", self.dataBase, mySearchBar.text, entered] : [NSString stringWithFormat:@"http://www.interdig.org/jemaila.cfm?db=%@&cl=%@&men=%@", self.dataBase, self.thisObjectInfo.claveSig, entered];
            
            NSURL *url = [NSURL URLWithString:_urlString];
            
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setDidFailSelector:@selector(enviarEmailFailed:)];
            [self.request setDidFinishSelector:@selector(enviarEmailFinished:)];
            [self.request setDelegate:self];
            [self.request setTimeOutSeconds:30];
            [self.request startAsynchronous];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Enviando E-Mail";
        }
    }
}

-(void)enviarMensajitoFinished:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Mensaje Enviado!" andMessage:@"Se ha enviado exitosamente su SMS!"];
}

-(void) enviarMensajitoFailed:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Error al mandar mensaje - %@", [_request error]]];
}

-(void)enviarEmailFinished:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Correo Enviado!" andMessage:@"Se ha enviado exitosamente su E-Mail!"];
}

-(void) enviarEmailFailed:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Error al mandar correo - %@", [_request error]]];
}

-(void)showVideo:(NSString *)videoURL
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if(!ok)
    {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
    
    WebViewController *webvc = [[WebViewController alloc] init];
    webvc.webURL = videoURL;
    
    [self.navigationController pushViewController:webvc animated:YES];
    [webvc release];
    /*
     NSURL *url = [NSURL URLWithString:videoURL];
     if([[UIApplication sharedApplication] canOpenURL:url])
     {
     [[UIApplication sharedApplication] openURL:url];
     }
     else
     {
     [Util showAlertWithTitle:@"Interdig" andMessage:@"Youtube app no disponible"];
     }
     */
}

-(void)openAlertViewWithTitle:(NSString *)title andPlaceHolderMessage:(NSString *)placeholder andButtontitle:(NSString *)btnTitle andTag:(NSInteger)tag
{
    if([Util isIOS7])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:btnTitle, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else {
        alertPrompt = [[UIAlertPrompt alloc] initWithTitle:title message:@"\n" delegate:self cancelButtonTitle:@"Cancelar" okButtonTitle:btnTitle];
        alertPrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertPrompt show];
        [alertPrompt release];
    }
}

/********************
 ********************
 SEARCH BAR DELEGATE
 ********************
 ********************/

- (void) searchTableView {
    
    [self.searchResults removeAllObjects];
    NSString *searchText = mySearchBar.text;
    
    /*
     for (ObjectInfo *sTemp in self.objectArray)
     {
     NSRange titleResultsRange = [sTemp.titulo rangeOfString:searchText options:NSCaseInsensitiveSearch];
     
     if (titleResultsRange.length > 0)
     [self.searchResults addObject:sTemp];
     }
     */
    searchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *dbName = dbSearch.text;
    if([dbName isEqualToString:@""])
        dbName = self.dataBase;
    
    dbName = [dbName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *mainURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.interdig.org/jbus1.cfm?db=%@&inp=%@", dbName, searchText]];
    
    self.request = [ASIHTTPRequest requestWithURL:mainURL];
    self.request.delegate = self;
    self.request.timeOutSeconds = 30;
    [self.request setDidFinishSelector:@selector(searchFinished:)];
    [self.request setDidFailSelector:@selector(searchFailed:)];
    [self.request startAsynchronous];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando...";
}

-(void)searchFinished:(ASIHTTPRequest *)_request
{
    NSString *responseString = [_request responseString];
    //responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //NSLog(@"SEARCH: %@", responseString);
    if([_request responseStatusCode] == 200)
    {
        NSArray *response = [responseString JSONValue];
        if([response count] >= 1)
        {
            for(NSDictionary *item in response)
            {
                ObjectInfo *newItem = [[ObjectInfo alloc] initWithDictionary:item];
                [self.searchResults addObject:newItem];
                [newItem release];
            }
        }
        else
        {
            noSearchResults.hidden = NO;
            noSearchResults.text = @"No se encontraron resultados";
        }
    }
    else
    {
        [self.objectArray removeAllObjects];
        [mainTableView reloadData];
        retryBtn.hidden = noSearchResults.hidden = wifi.hidden = NO;
        noSearchResults.text = @"Error de Conexion; Asegure su conexion de internet e intente de nuevo";
        //[Util showAlertWithTitle:@"Error de Conexion" andMessage:[NSString stringWithFormat:@"Asegure su conexion de internet e intente de neuvo\n Codigo: %d", [_request responseStatusCode]]];
    }
    
    [mainTableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)searchFailed:(ASIHTTPRequest *)_request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.objectArray removeAllObjects];
    [mainTableView reloadData];
    
    [Util showAlertWithTitle:@"Error de Conexion" andMessage:[NSString stringWithFormat:@"Asegure su conexion de internet e intente de neuvo\n Codigo: %d", [_request responseStatusCode]]];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    retryBtn.hidden = wifi.hidden = noSearchResults.hidden = YES;
    if(overlay == nil)
    {
        int height;
        height = searching ? [self.searchResults count] * 130 : [self.objectArray count] * 130;
        if(height < self.view.frame.size.height)
            height = self.view.frame.size.height;
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        overlay = [[SearchOverlayViewController alloc] initWithFrame:frame];
        
        overlay.parentViewController = self;
        overlay.searchBar = mySearchBar;
        
        [mainTableView addSubview:overlay];
        [overlay release];
    }
    searching = YES;
    [theSearchBar setShowsCancelButton:YES animated:YES];
    letUserSelectRow = NO;
    mainTableView.scrollEnabled = NO;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    //Remove all objects first.
    searching = [searchText length] > 0 ? YES : NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self searchTableView];
    
    [overlay removeFromSuperview];
    overlay = nil;
    
    [theSearchBar resignFirstResponder];
    [theSearchBar setShowsCancelButton:NO animated:YES];
    
    letUserSelectRow = YES;
    searching = [theSearchBar.text isEqualToString:@""] ? NO : YES;
    mainTableView.scrollEnabled = YES;
    
    [mainTableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [overlay removeFromSuperview];
    //[overlay release];
    overlay = nil;
    searchBar.text = @"";
    [dbSearch resignFirstResponder];
    [searchBar resignFirstResponder];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
    letUserSelectRow = YES;
    searching = NO;
    mainTableView.scrollEnabled = YES;
    
    [mainTableView reloadData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    retryBtn.hidden = wifi.hidden = noSearchResults.hidden = YES;
    if(overlay == nil)
    {
        int height;
        height = searching ? [self.searchResults count] * 130 : [self.objectArray count] * 130;
        if(height < self.view.frame.size.height)
            height = self.view.frame.size.height;
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        overlay = [[SearchOverlayViewController alloc] initWithFrame:frame];
        overlay.parentViewController = self;
        overlay.searchBar = mySearchBar;
        
        [mainTableView addSubview:overlay];
        [overlay release];
    }
    
    searching = YES;
    [mySearchBar setShowsCancelButton:YES animated:YES];
    letUserSelectRow = NO;
    mainTableView.scrollEnabled = NO;
}

/*******************************
 *******************************
 PULL DOWN TO REFRESH METHODS
 *******************************
 *******************************/

#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    if(!searching)
        [self getInfoFromURL:self.urlString];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mainTableView];
	
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

-(NSString *) getCategory:(NSString *)category IconImageFromDB:(NSString *)db
{
    NSString *answer = [NSString stringWithFormat:@"%@_", category];
    
    if(db != nil || [db isEqualToString:@"interdig"])
    {
        if([db isEqualToString:@"fecamco"])
        {
            answer = [answer stringByAppendingString:@"fecamco"];
        }
        else if([db isEqualToString:@"egob"])
        {
            answer = [answer stringByAppendingString:@"honduras"];
        }
        else if([db isEqualToString:@"intur"])
        {
            answer = [answer stringByAppendingString:@"intur"];
        }
        else if([db isEqualToString:@"orion"])
        {
            answer = [answer stringByAppendingString:@"orion"];
        }
        else if([db isEqualToString:@"kepco"])
        {
            answer = [answer stringByAppendingString:@"koica"];
        }
        else if([db isEqualToString:@"news"])
        {
            answer = [answer stringByAppendingString:@"news"];
        }
        else if([db isEqualToString:@"comision"])
        {
            answer = [answer stringByAppendingString:@"villeda"];
        }
        else if([db isEqualToString:@"brazil"] || [db isEqualToString:@"saopaulo"]
                || [db isEqualToString:@"rio"] || [db isEqualToString:@"belohorizonte"]
                || [db isEqualToString:@"cuiaba"] || [db isEqualToString:@"brasilia"]
                || [db isEqualToString:@"curitiba"] || [db isEqualToString:@"fortaleza"]
                || [db isEqualToString:@"manaus"] || [db isEqualToString:@"natal"]
                || [db isEqualToString:@"portoalegre"] || [db isEqualToString:@"recife"]
                || [db isEqualToString:@"bahia"])
        {
            answer = [answer stringByAppendingString:@"brasil"];
        }
        else
        {
            answer = [answer stringByAppendingString:@"green"];
        }
    }
    else
    {
        return @"None";
    }
    return answer;
}

-(NSString *)getIconImageString
{
    if(self.dataBase != nil || ![self.dataBase isEqualToString:@"interdig"])
    {
        if([self.dataBase isEqualToString:@"alba"] || [self.dataBase isEqualToString:@"egob"] || [self.dataBase isEqualToString:@"turismo1"])
        {
            //Azul
            return @"video3";
        }
        else if([self.dataBase isEqualToString:@"news"] || [self.dataBase isEqualToString:@"villeda"])
        {
            //Rojo
            return @"video5";
        }
        else if([self.dataBase isEqualToString:@"brazil"] || [self.dataBase isEqualToString:@"saopaulo"]
                || [self.dataBase isEqualToString:@"rio"] || [self.dataBase isEqualToString:@"belohorizonte"]
                || [self.dataBase isEqualToString:@"cuiaba"] || [self.dataBase isEqualToString:@"brasilia"]
                || [self.dataBase isEqualToString:@"curitiba"] || [self.dataBase isEqualToString:@"fortaleza"]
                || [self.dataBase isEqualToString:@"manaus"] || [self.dataBase isEqualToString:@"natal"]
                || [self.dataBase isEqualToString:@"portoalegre"] || [self.dataBase isEqualToString:@"recife"]
                || [self.dataBase isEqualToString:@"bahia"] || [self.dataBase isEqualToString:@"canada1"])
        {
            //Verde
            return @"video11";
        }
        else
        {
            //Negro
            return @"video";
        }
    }
    else
    {
        //Negro
        return @"video";
    }
}


-(void)dealloc
{
    [objManager cancelLoadingObjects];
    [objManager release];
    [objectArray release];
    [super dealloc];
}

@end
