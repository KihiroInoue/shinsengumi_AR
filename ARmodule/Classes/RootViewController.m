//
//  RootViewController.m
//  Nearby
//
//  Created by Yos Hashimoto.
//  Copyright Newton Japan Inc. 2009. All rights reserved.
//

#import "NearbyAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "Article.h"
#import "AppData.h"
#import "CustomCell.h"
#import	"CustomImagePicker.h"


@implementation RootViewController

#pragma mark -
#pragma mark Object lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (CustomImagePicker *)[[UIApplication sharedApplication] delegate];
	self.title = @"リスト";
	appData = appDelegate.appData;

	// AR追加部分
    UIBarButtonItem *mapAllButton = [[UIBarButtonItem alloc] initWithTitle:@"AR表示" style:UIBarButtonItemStylePlain target:self action:@selector(showMapAllView)];
    self.navigationItem.rightBarButtonItem = mapAllButton;
    [mapAllButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[detailViewController release];
	[appDelegate release];
    [super dealloc];
}


#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appDelegate.appData.articles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ReuseCellID";

	// セルを取得する
    CustomCell* cell;
    cell = (CustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    
	Article *anArticle = [appDelegate.appData.articles objectAtIndex:indexPath.row];
	[cell setNameOfPlace:anArticle.title];
	[cell setDistanceToPlace:anArticle.distance];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(detailViewController == nil) {
		detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:[NSBundle mainBundle]];
		detailViewController.appData = appData;
	}
		
	Article *anArticle = [appDelegate.appData.articles objectAtIndex:indexPath.row];
	detailViewController.anArticle = anArticle;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark Open AR

-(void) showMapAllView {
	if(appData.picker==nil) {
		appData.picker = [[CustomImagePicker alloc] init];  
	}
	//	appData.picker.delegate = self;  
	appData.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	appData.picker.showsCameraControls = NO;
	appData.picker.cameraOverlayView.userInteractionEnabled = NO;
	appData.picker.appData = appData;

	
	[self presentModalViewController:appData.picker animated:YES];
}


@end

