//
//  SecondViewController.m
//  XJHCLManager_Example
//
//  Created by xujunhao on 2018/9/4.
//  Copyright © 2018年 cocoadogs. All rights reserved.
//

#import "SecondViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "XJHCLManager.h"

@interface SecondViewController ()

@property (nonatomic, strong) UIButton *locationBtn;

@property (nonatomic, strong) XJHCLManager *manager;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Build Method

- (void)buildUI {
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.locationBtn];
	[self.locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self.view);
		make.size.mas_equalTo(CGSizeMake(100, 40));
	}];
}

#pragma mark - Lazy Load Methods

- (UIButton *)locationBtn {
	if (!_locationBtn) {
		_locationBtn = [[UIButton alloc] init];
		[_locationBtn setTitle:@"定位" forState:UIControlStateNormal];
		[_locationBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[_locationBtn setBackgroundColor:[UIColor whiteColor]];
		_locationBtn.layer.cornerRadius = 5.0f;
		_locationBtn.layer.borderWidth = 0.5f;
		_locationBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
		@weakify(self)
		[[_locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
			@strongify(self)
			[self.manager checkCoreLocationAuthorizationWithPriority:XJHCLPriorityDefault completion:^{
				
			} restriction:^(XJHCLManagerParamBuilder *builder) {
				builder.title = @"定位服务给我限制，要不要这样";
			} rejection:^(XJHCLManagerParamBuilder *builder) {
				builder.title = @"定位服务给我拒绝了，蛇精病";
			} shutdown:^(XJHCLManagerParamBuilder *builder) {
				builder.title = @"定位都不打开的人都有的";
			}];
		}];
	}
	return _locationBtn;
}

- (XJHCLManager *)manager {
	if (!_manager) {
		_manager = [[XJHCLManager alloc] init];
	}
	return _manager;
}

@end
