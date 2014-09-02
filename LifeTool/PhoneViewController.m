//
//  ViewController.m
//  LifeTool
//
//  Created by Zzy on 9/2/14.
//  Copyright (c) 2014 Chihya Tsang. All rights reserved.
//

#import "PhoneViewController.h"

@interface PhoneViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation PhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"拨号";
    [self.inputTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

@end
