//
//  XJHCLManager.m
//  XJHCLManager
//
//  Created by xujunhao on 2018/9/4.
//

#import "XJHCLManager.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface XJHCLManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, assign) XJHCLPriority priority;
@property (nonatomic, copy) XJHCLManagerAuthorizedCompletion completion;
@property (nonatomic, copy) XJHCLManagerAuthorizedRestriction restriction;
@property (nonatomic, copy) XJHCLManagerAuthorizedRejection rejection;
@property (nonatomic, copy) XJHCLManagerServiceShutdown shutdown;
@property (nonatomic, strong) XJHCLManagerParamBuilder *restrictionBuilder;
@property (nonatomic, strong) XJHCLManagerParamBuilder *rejectionBuilder;
@property (nonatomic, strong) XJHCLManagerParamBuilder *shutdownBuilder;
@property (nonatomic, assign) CLAuthorizationStatus curStatus;

@end

@implementation XJHCLManager

#pragma mark - Init Method

- (instancetype)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	return self;
}

#pragma mark - Life Cycle Method

- (void)dealloc {
	NSLog(@"---dealloc---XJHCLManager---");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Public Method

- (void)checkCoreLocationAuthorizationWithPriority:(XJHCLPriority)priority
										completion:(XJHCLManagerAuthorizedCompletion)completion
									   restriction:(XJHCLManagerAuthorizedRestriction)restriction
										 rejection:(XJHCLManagerAuthorizedRejection)rejection
										  shutdown:(XJHCLManagerServiceShutdown)shutdown {
	_priority = priority;
	_completion = completion;
	_restriction = restriction;
	_rejection = rejection;
	_shutdown = shutdown;
	
	if (![CLLocationManager locationServicesEnabled]) {
		!shutdown?:shutdown(self.shutdownBuilder);
		[self showShutdownAlert];
	} else {
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		_curStatus = status;
		switch (status) {
			case kCLAuthorizationStatusNotDetermined:
			{
				switch (priority) {
					case XJHCLPriorityAlways:
					{
						[self.manager requestAlwaysAuthorization];
					}
						break;
					default:
					{
						[self.manager requestWhenInUseAuthorization];
					}
						break;
				}
			}
				break;
			case kCLAuthorizationStatusRestricted:
			{
				!restriction?:restriction(self.restrictionBuilder);
				
				UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.restrictionBuilder.title?:@"使用定位功能受限" message:self.restrictionBuilder.message?:@"请在iOS\"设置\"-\"隐私\"-\"定位服务\"中打开" preferredStyle:UIAlertControllerStyleAlert];
				[alertController addAction:[UIAlertAction actionWithTitle:self.restrictionBuilder.cancel?:@"取消" style:UIAlertActionStyleCancel handler:nil]];
				[alertController addAction:[UIAlertAction actionWithTitle:self.restrictionBuilder.setting?:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
				}]];
				[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
			}
				break;
			case kCLAuthorizationStatusDenied:
			{
				!rejection?:rejection(self.rejectionBuilder);
				
				UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.rejectionBuilder.title?:@"未获得授权使用定位功能" message:self.rejectionBuilder.message?:@"请在iOS\"设置\"-\"隐私\"-\"定位服务\"中打开" preferredStyle:UIAlertControllerStyleAlert];
				[alertController addAction:[UIAlertAction actionWithTitle:self.rejectionBuilder.cancel?:@"取消" style:UIAlertActionStyleCancel handler:nil]];
				[alertController addAction:[UIAlertAction actionWithTitle:self.rejectionBuilder.setting?:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
				}]];
				[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
			}
				break;
			default:
				break;
		}
	}
}

#pragma mark - Private Method

- (void)receiveBecomeActiveNotification {
	if (![CLLocationManager locationServicesEnabled]) {
		[self showShutdownAlert];
	}
}

- (void)showShutdownAlert {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.shutdownBuilder.title?:@"打开定位功能" message:self.shutdownBuilder.message?:@"请在iOS\"设置\"-\"隐私\"-\"定位服务\"中打开" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:self.shutdownBuilder.cancel?:@"取消" style:UIAlertActionStyleCancel handler:nil]];
	[alertController addAction:[UIAlertAction actionWithTitle:self.shutdownBuilder.setting?:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}]];
	[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate Method

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (_curStatus != status) {
		NSLog(@"定位服务授权状态发生改变---XJHCLManager");
		[self checkCoreLocationAuthorizationWithPriority:self.priority completion:self.completion restriction:self.restriction rejection:self.rejection shutdown:self.shutdown];
	}
}

#pragma mark - Lazy Load Method

- (CLLocationManager *)manager {
	if (!_manager) {
		_manager = [[CLLocationManager alloc] init];
		_manager.delegate = self;
	}
	return _manager;
}

- (XJHCLManagerParamBuilder *)restrictionBuilder {
	if (!_restrictionBuilder) {
		_restrictionBuilder = [[XJHCLManagerParamBuilder alloc] init];
	}
	return _restrictionBuilder;
}

- (XJHCLManagerParamBuilder *)rejectionBuilder {
	if (!_rejectionBuilder) {
		_rejectionBuilder = [[XJHCLManagerParamBuilder alloc] init];
	}
	return _rejectionBuilder;
}

- (XJHCLManagerParamBuilder *)shutdownBuilder {
	if (!_shutdownBuilder) {
		_shutdownBuilder = [[XJHCLManagerParamBuilder alloc] init];
	}
	return _shutdownBuilder;
}

@end
