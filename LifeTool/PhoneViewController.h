//
//  ViewController.h
//  LifeTool
//
//  Created by Zzy on 9/2/14.
//  Copyright (c) 2014 Chihya Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

- (IBAction)onClickSendMessage:(id)sender;
- (IBAction)onClickCallNumber:(id)sender;

@end
