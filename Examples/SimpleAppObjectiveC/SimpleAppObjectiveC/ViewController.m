//
//  ViewController.m
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "ViewController.h"
#import "Constants.h"
#import "DiscountBannerView.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *predictButton;
@property (nonatomic, strong) UIButton *logEventButton;
@property (nonatomic, strong) UILabel *discountStatusLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) DiscountBannerView *discountBannerView;
@property (nonatomic, strong) NSTimer *statusCheckTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupMonetaiSDK];
    [self setupNotifications];
    
    // Log app launch event
    [[MonetaiSDK shared] logEventWithEventName:@"app_in" params:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.statusCheckTimer invalidate];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"MonetaiSDK Demo";
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    // Status Label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"SDK Status: Initializing...";
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    // Predict Button
    self.predictButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.predictButton setTitle:@"Predict Purchase" forState:UIControlStateNormal];
    self.predictButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.predictButton.backgroundColor = [UIColor systemBlueColor];
    [self.predictButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.predictButton.layer.cornerRadius = 10;
    self.predictButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.predictButton addTarget:self action:@selector(predictButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.predictButton];
    
    // Log Event Button
    self.logEventButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.logEventButton setTitle:@"Log Event" forState:UIControlStateNormal];
    self.logEventButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.logEventButton.backgroundColor = [UIColor systemGreenColor];
    [self.logEventButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logEventButton.layer.cornerRadius = 8;
    self.logEventButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logEventButton addTarget:self action:@selector(logEventButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logEventButton];
    
    // Discount Status Label
    self.discountStatusLabel = [[UILabel alloc] init];
    self.discountStatusLabel.text = @"Discount: None";
    self.discountStatusLabel.textColor = [UIColor secondaryLabelColor];
    self.discountStatusLabel.font = [UIFont systemFontOfSize:14];
    self.discountStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.discountStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.discountStatusLabel];
    
    // Result Label
    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.text = @"Tap buttons to test SDK functionality";
    self.resultLabel.textColor = [UIColor secondaryLabelColor];
    self.resultLabel.font = [UIFont systemFontOfSize:14];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Title Label
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        
        // Status Label
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20],
        
        // Predict Button
        [self.predictButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.predictButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-30],
        [self.predictButton.widthAnchor constraintEqualToConstant:200],
        [self.predictButton.heightAnchor constraintEqualToConstant:50],
        
        // Log Event Button
        [self.logEventButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.logEventButton.topAnchor constraintEqualToAnchor:self.predictButton.bottomAnchor constant:20],
        [self.logEventButton.widthAnchor constraintEqualToConstant:150],
        [self.logEventButton.heightAnchor constraintEqualToConstant:40],
        
        // Discount Status Label
        [self.discountStatusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.discountStatusLabel.topAnchor constraintEqualToAnchor:self.logEventButton.bottomAnchor constant:30],
        
        // Result Label
        [self.resultLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.resultLabel.topAnchor constraintEqualToAnchor:self.discountStatusLabel.bottomAnchor constant:20],
        [self.resultLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

#pragma mark - MonetaiSDK Setup

- (void)setupMonetaiSDK {
    // Set up discount info change callback
    __weak typeof(self) weakSelf = self;
    [MonetaiSDK shared].onDiscountInfoChangeCallback = ^(id _Nullable discountInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDiscountInfoChange:discountInfo];
        });
    };
    
    // Start checking SDK status periodically
    [self startSDKStatusCheck];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitialized)
                                                 name:kMonetaiSDKInitializedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitializationFailed:)
                                                 name:kMonetaiSDKInitializationFailedNotification
                                               object:nil];
}

- (void)sdkInitialized {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSDKStatus];
        self.resultLabel.text = @"✅ SDK initialized successfully!";
        self.resultLabel.textColor = [UIColor systemGreenColor];
    });
}

- (void)sdkInitializationFailed:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSDKStatus];
        NSError *error = notification.object;
        if (error) {
            self.resultLabel.text = [NSString stringWithFormat:@"❌ SDK initialization failed: %@", error.localizedDescription];
        } else {
            self.resultLabel.text = @"❌ SDK initialization failed";
        }
        self.resultLabel.textColor = [UIColor systemRedColor];
    });
}

- (void)startSDKStatusCheck {
    // Check status immediately
    [self updateSDKStatus];
    
    // Check status every 1 second until initialized
    self.statusCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkSDKStatus) userInfo:nil repeats:YES];
}

- (void)checkSDKStatus {
    BOOL isInitialized = [[MonetaiSDK shared] getInitialized];
    [self updateSDKStatus];
    
    // Stop timer when SDK is initialized
    if (isInitialized) {
        [self.statusCheckTimer invalidate];
        self.statusCheckTimer = nil;
    }
}

- (void)updateSDKStatus {
    BOOL isInitialized = [[MonetaiSDK shared] getInitialized];
    self.statusLabel.text = isInitialized ? @"SDK Status: ✅ Ready" : @"SDK Status: ⏳ Initializing...";
    self.statusLabel.textColor = isInitialized ? [UIColor systemGreenColor] : [UIColor systemOrangeColor];
    
    // Enable/disable buttons based on initialization status
    self.predictButton.enabled = isInitialized;
    self.logEventButton.enabled = isInitialized;
    
    if (isInitialized) {
        self.predictButton.alpha = 1.0;
        self.logEventButton.alpha = 1.0;
    } else {
        self.predictButton.alpha = 0.5;
        self.logEventButton.alpha = 0.5;
    }
}

- (void)handleDiscountInfoChange:(AppUserDiscount *)discountInfo {
    if (discountInfo) {
        NSDate *now = [NSDate date];
        NSDate *endTime = discountInfo.endedAt;
        
        if ([now compare:endTime] == NSOrderedAscending) {
            // Discount is valid - show banner
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
            NSString *formattedDate = [formatter stringFromDate:endTime];
            
            self.discountStatusLabel.text = [NSString stringWithFormat:@"Discount: ✅ Active (Expires: %@)", formattedDate];
            self.discountStatusLabel.textColor = [UIColor systemGreenColor];
            [self showDiscountBanner:discountInfo];
        } else {
            // Discount expired
            self.discountStatusLabel.text = @"Discount: ❌ Expired";
            self.discountStatusLabel.textColor = [UIColor systemRedColor];
            [self hideDiscountBanner];
        }
    } else {
        // No discount
        self.discountStatusLabel.text = @"Discount: None";
        self.discountStatusLabel.textColor = [UIColor secondaryLabelColor];
        [self hideDiscountBanner];
    }
}

- (void)showDiscountBanner:(AppUserDiscount *)discount {
    // Remove existing banner if any
    [self hideDiscountBanner];
    
    // Create and add new banner
    DiscountBannerView *bannerView = [[DiscountBannerView alloc] init];
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    
    // Position banner at the bottom
    [NSLayoutConstraint activateConstraints:@[
        [bannerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bannerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bannerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [bannerView.heightAnchor constraintEqualToConstant:100]
    ]];
    
    // Show discount
    [bannerView showDiscount:discount];
    self.discountBannerView = bannerView;
    
    // Update result label
    self.resultLabel.text = @"🎉 Discount banner displayed!\nSpecial offer is now active.";
    self.resultLabel.textColor = [UIColor systemGreenColor];
}

- (void)hideDiscountBanner {
    [self.discountBannerView hideDiscount];
    self.discountBannerView = nil;
}

#pragma mark - Button Actions

- (void)predictButtonTapped {
    [[MonetaiSDK shared] predictWithCompletion:^(PredictResponse * _Nullable result, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = [NSString stringWithFormat:@"❌ Prediction failed: %@", error.localizedDescription];
                self.resultLabel.textColor = [UIColor systemRedColor];
            });
            NSLog(@"Prediction failed: %@", error.localizedDescription);
        } else {
            NSLog(@"Prediction result: %@", result.predictionString ?: @"None");
            NSLog(@"Test group: %@", result.testGroupString ?: @"None");

            if ([result.predictionString isEqualToString:@"non-purchaser"]) {
                // When predicted as non-purchaser, offer discount
                NSLog(@"Predicted as non-purchaser - discount can be applied");
            } else if ([result.predictionString isEqualToString:@"purchaser"]) {
                // When predicted as purchaser
                NSLog(@"Predicted as purchaser - discount not needed");
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = @"✅ Prediction completed - check console for details";
                self.resultLabel.textColor = [UIColor systemGreenColor];
                
                // Show alert with prediction result
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Prediction"
                                                                               message:[NSString stringWithFormat:@"Prediction: %@\nTest Group: %@",
                                                                                        result.predictionString ?: @"None",
                                                                                        result.testGroupString ?: @"None"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

- (void)logEventButtonTapped {
    // Log a sample event with parameters
    NSDictionary *params = @{
        @"button": @"test_button",
        @"screen": @"main"
    };
    
    [[MonetaiSDK shared] logEventWithEventName:@"button_click" params:params];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultLabel.text = @"✅ Event logged: button_click\nParameters: button=test_button, screen=main";
        self.resultLabel.textColor = [UIColor systemGreenColor];
    });
    
    NSLog(@"Event logged: button_click");
}

@end
