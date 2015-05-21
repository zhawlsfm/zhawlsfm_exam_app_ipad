//
//  SecondViewController.m
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 10.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import "DokumentsViewController.h"
#import "ReaderViewController.h"
#import "LoginViewController.h"

@interface DokumentsViewController ()

@end

@implementation DokumentsViewController

@synthesize myTableView;
@synthesize documents;
@synthesize refreshControl;

#pragma mark - Notifications


-(void)receivedApplicationWillEnterForegroundNotification {
    [self loadDocumentsArray];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    documents = [[NSMutableArray alloc] init];
    
    /*refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    //refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(loadDocumentsArray) forControlEvents:UIControlEventValueChanged];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedApplicationWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDocumentsArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Data

- (void)loadDocumentsArray {
    [DokumentsViewController makeDir:INBOX_FOLDER];
    [DokumentsViewController moveAllFilesInDir:INBOX_FOLDER toPath:nil withEnding:@"PDF"];
    
    [documents removeAllObjects];
    //NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:PDF_FOLDER];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    //[documents addObjectsFromArray:files];
    for (NSString *filename in files) {
        //if ([[filename uppercaseString] rangeOfString:@".PDF"].location != NSNotFound) {
        if ([[filename.pathExtension uppercaseString] isEqualToString:@"PDF"]) {
            [documents addObject:filename];
        }
    }
    [myTableView reloadData];
    //[refreshControl endRefreshing];
    
}

#pragma mark - Filesystem Methods

+(void)moveAllFilesInDir:(NSString*)path toPath:(NSString*)topath withEnding:(NSString*)ending {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path2;
    if (path==nil) {
        path2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    } else {
        path2 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    }
    
    NSString *path3;
    if (topath==nil) {
        path3 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    } else {
        path3 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:topath];
    }
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path2 error:&error]) {
        if (ending==nil || [[file.pathExtension uppercaseString] isEqualToString:ending]) {
            BOOL success = [fm moveItemAtPath:[NSString stringWithFormat:@"%@/%@", path2, file] toPath:[NSString stringWithFormat:@"%@/%@", path3, file] error:&error];
            if (!success || error) {
                NSLog(@"Move file error: %@", error);
            }
        }
    }
    
}

+(void)makeDir:(NSString*)path {
    NSError *error;
    path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Create directory error: %@", error);
        }		
    }
}

+(void)deleteFile:(NSString*)path {
    if (path !=nil && path.length>0) {
        NSError *error;
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])	{
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                NSLog(@"Delete file error: %@", error);
            }
        }	
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [documents count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
  //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.textLabel.font = [Util mainTitleFont];
    //cell.textLabel.textColor = [Util mainTitleColor];
    //cell.detailTextLabel.font = [Util subTitleFont];
    //cell.detailTextLabel.textColor = [Util subTitleColor];
    //cell.detailTextLabel.numberOfLines = 2;
    //cell.textLabel.minimumFontSize = 14;
    //cell.textLabel.adjustsFontSizeToFitWidth = YES;
  }
  
  //hide pdfs
  /*if ([LoginViewController guidedProtectedAccessOn]) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }*/
  cell.textLabel.text = [documents objectAtIndex:indexPath.row];
  cell.detailTextLabel.text = @"TextDetail";
 
  return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
   [DokumentsViewController deleteFile:[documents objectAtIndex:indexPath.row]];
   [documents removeObjectAtIndex:indexPath.row];
   [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Table view delegate

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     //if ([LoginViewController guidedProtectedAccessOn]) {
         //ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
         ReaderViewController *readerViewController = [[ReaderViewController alloc] init];
         readerViewController.documentName = [documents objectAtIndex:indexPath.row];
         [self presentViewController:readerViewController animated:YES  completion:nil];
     //}
 }

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}






@end
