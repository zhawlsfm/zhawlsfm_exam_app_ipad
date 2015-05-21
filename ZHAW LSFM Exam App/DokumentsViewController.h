//
//  SecondViewController.h
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 10.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DokumentsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *documents;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

