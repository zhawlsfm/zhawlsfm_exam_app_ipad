//
//  FirstViewController.m
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 10.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import "LoginViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
//#import <AVFoundation/AVFoundation.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "Reachability.h"
#import "ios-ntp.h"
#import "DokumentsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

static BOOL guidedProtectedAccessOn;

int memMin = 100;  // MB
float volMin = 0.0;  // %
float batMin = 0.5;  // %
int codeLenghtMin = 4;
float timeDiffMax = 120;  //sekunden

@synthesize levelLabel;
@synthesize stateLabel;
@synthesize localTimeLabel;
@synthesize serverTimeLabel;
//@synthesize volumeLevelLabel;
@synthesize networkStateLabel;
@synthesize hostStateLabel;
@synthesize memoryLevelLabel;
//@synthesize checkResultLabel;
@synthesize codeTextField;
@synthesize nameTextField;
@synthesize statusLabel;
@synthesize guidedAccessOn;

+(BOOL)guidedProtectedAccessOn {
    return guidedProtectedAccessOn;
}


#pragma mark -
#pragma mark Notification

-(void)receivedApplicationWillResignActiveNotification {
    self.firstTimeGuidedAccessChange = YES;
}

-(void)receivedApplicationDidEnterBackgroundNotification {
    self.firstTimeGuidedAccessChange = YES;
    codeTextField.text = @"";
}

-(void)receivedApplicationWillEnterForegroundNotification {
    //[self setVolumeLevel];
    if (!guidedAccessOn) [self updateAll];
}

- (void)batteryLevelChanged:(NSNotification *)notification {
    if (!guidedAccessOn) [self updateAll];
}


- (void)batteryStateChanged:(NSNotification *)notification {
    if (!guidedAccessOn) [self updateAll];
}


#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstTimeGuidedAccessChange = YES;
    guidedProtectedAccessOn = NO;
    
    [self setVolumeLevel];
    
    ///UITabBarItem *tabBarItem = [[self.tabBarController.tabBar items] objectAtIndex:1];
    ///[tabBarItem setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guidedAccessChanged) name:UIAccessibilityGuidedAccessStatusDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedApplicationWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedApplicationDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedApplicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    NSString *studentName = [[NSUserDefaults standardUserDefaults] stringForKey:@"studentName"];
    if (studentName!=nil && [studentName length]>0) {
        nameTextField.text = studentName;
    }
    
    float labelStartPosY = 250.0f;
    float labelStartPosX = 200.0f;
    float labelHeight = 25.0f;
    float labelWidth = 600.0f;
    
    CGRect levelLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    levelLabel = [[UILabel alloc] initWithFrame:levelLabelFrame];
    [self.view addSubview:levelLabel];
    levelLabel.text = @"bat: level unbekannt";
    labelStartPosY = labelStartPosY + 30.0f;
    CGRect stateLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    stateLabel = [[UILabel alloc] initWithFrame:stateLabelFrame];
    [self.view addSubview:stateLabel];
    stateLabel.text = @"bat: state unbekannt";
    labelStartPosY = labelStartPosY + 50.0f;
    CGRect localTimeLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    localTimeLabel = [[UILabel alloc] initWithFrame:localTimeLabelFrame];
    [self.view addSubview:localTimeLabel];
    localTimeLabel.text = @"lokale Zeit: unbekannt";
    labelStartPosY = labelStartPosY + 30.0f;
    CGRect serverTimeLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    serverTimeLabel = [[UILabel alloc] initWithFrame:serverTimeLabelFrame];
    [self.view addSubview:serverTimeLabel];
    serverTimeLabel.text = @"server Zeit: unbekannt";
    labelStartPosY = labelStartPosY + 50.0f;
    /*CGRect volumeLevelLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    volumeLevelLabel = [[UILabel alloc] initWithFrame:volumeLevelLabelFrame];
    [self.view addSubview:volumeLevelLabel];
    volumeLevelLabel.text = @"lautstärke: unbekannt";
    labelStartPosY = labelStartPosY + 50.0f;*/
    CGRect networkStateLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    networkStateLabel = [[UILabel alloc] initWithFrame:networkStateLabelFrame];
    [self.view addSubview:networkStateLabel];
    networkStateLabel.text = @"netzwerkstatus: unbekannt";
    labelStartPosY = labelStartPosY + 30.0f;
    CGRect hostStateLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    hostStateLabel = [[UILabel alloc] initWithFrame:hostStateLabelFrame];
    [self.view addSubview:hostStateLabel];
    hostStateLabel.text = @"hoststatus: unbekannt";
    labelStartPosY = labelStartPosY + 50.0f;
    CGRect memoryLevelLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    memoryLevelLabel = [[UILabel alloc] initWithFrame:memoryLevelLabelFrame];
    [self.view addSubview:memoryLevelLabel];
    memoryLevelLabel.text = @"speicher: unbekannt";
    //labelStartPosY = labelStartPosY + 100.0f;
    /*CGRect checkResultLabelFrame = CGRectMake(labelStartPosX, labelStartPosY, labelWidth, labelHeight);
    checkResultLabel = [[UILabel alloc] initWithFrame:checkResultLabelFrame];
    [self.view addSubview:checkResultLabel];
    checkResultLabel.text = @"status: unbekannt";
    checkResultLabel.textColor = [UIColor darkTextColor];*/
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self setVolumeLevel];  //zu aufdringlich
    if (!guidedAccessOn) [self updateAll]; // if (!guidedAccessOn) ??
    
}


#pragma mark -
#pragma mark Update All

- (IBAction)updateButtonClicked:(id)sender {
    [self updateAll];
}

-(BOOL)updateAll {

    BOOL allOke = YES;
    
    //[UIDevice currentDevice].batteryMonitoringEnabled = YES;
    BOOL batStateOke = [self updateBatteryState];
    BOOL batLevelOke = [self updateBatteryLevel];
    BOOL batOke = batLevelOke || batStateOke;
    //[UIDevice currentDevice].batteryMonitoringEnabled = NO;
    BOOL timeOke = [self updateTime];
    //BOOL volumeOke = [self updateVolumeLevel];
    BOOL connectionOke = [self updateConnectionState];
    BOOL hostOke = [self updateHostConnectionState];
    BOOL memoryOke = [self updateMemory];
    [self resignAllResponders];
    BOOL textOke = [self updateTextEntries];
    
    //todo: check ob code oke
    //todo: check ob nicht schon mal eingeloggt
    //todo: check ob pruefungsstart vorbei, falls ja sagen dass prueflich lehrer rufen soll
    
    allOke = batOke && timeOke /*&& volumeOke*/ && connectionOke && hostOke && memoryOke && textOke;
    
    if ([LoginViewController isJailbroken] && !guidedAccessOn) {
        statusLabel.text = @"Dieses Gerät kann nicht verwendet werden. Es ist 'Jailbroken'.";
        return NO;
    }
    
    if (!guidedAccessOn) {
        
        if (allOke) {
            //checkResultLabel.text = @"Alles OK";
            //checkResultLabel.textColor = [UIColor greenColor];
            statusLabel.text = @"Alles OK. Sie können in den abgesicherten Modus wechseln (3 mal Home drücken).";
        } else {
            //checkResultLabel.text = @"Nicht OK";
            //checkResultLabel.textColor = [UIColor redColor];
            statusLabel.text = @"Bitte beachten sie die roten Angaben und treffen sie bitte entsprechende Massnahmen.";
        }
    }
    
    return allOke;
}


#pragma mark -
#pragma mark Guided Acccess Change

-(void)hideLabels:(BOOL)pos {
    levelLabel.hidden=pos;
    stateLabel.hidden=pos;
    localTimeLabel.hidden=pos;
    //volumeLevelLabel.hidden=pos;
    networkStateLabel.hidden=pos;
    serverTimeLabel.hidden=pos;
    hostStateLabel.hidden=pos;
    memoryLevelLabel.hidden=pos;
    //checkResultLabel.hidden=pos;
    codeTextField.enabled=!pos;
    nameTextField.enabled=!pos;
}


-(void)guidedAccessChanged {
    if (!self.firstTimeGuidedAccessChange) {
        self.guidedAccessOn = UIAccessibilityIsGuidedAccessEnabled();
        NSLog(@"guided Access Change: %i",self.guidedAccessOn);
        
        UINavigationController *secondNavigatorController;
        DokumentsViewController *secondViewController;
        NSMutableArray *tabBarControllers =  [[NSMutableArray alloc] initWithArray:[self.tabBarController viewControllers]];
        for (UIViewController *controller in tabBarControllers) {
            if ([controller.tabBarItem.title isEqualToString:@"Dokumente"]) {
                secondNavigatorController = (UINavigationController*) controller;
                secondViewController = (DokumentsViewController*) [secondNavigatorController.viewControllers objectAtIndex:0];
                //secondViewController.navigationController.navigationBar.backgroundColor = [UIColor redColor];
                //secondViewController.navigationController.navigationBar.tintColor = [UIColor redColor];
            }
        }

        
        if (self.guidedAccessOn) {
            [self setVolumeLevel];
            if ([self updateAll]) {
                //UITabBarItem *tabBarItem = [[self.tabBarController.tabBar items] objectAtIndex:1];
                //[tabBarItem setEnabled:YES];
                guidedProtectedAccessOn = YES;
                //signalisieren dass wir im richtige modus sind, auch fuer secondviewcontroller
                //todo: check ob einloggen geht sonst nicht oke meldung
                [secondViewController.navigationController.navigationBar setBarTintColor:[UIColor greenColor]];
                [self.navigationController.navigationBar setBarTintColor:[UIColor greenColor]];
                //[self.view setBackgroundColor:[UIColor greenColor]];
                statusLabel.text = @"Sie sind erfolgreich eingeloggt. Sie können nun auf die Dokumente zugreifen. Bitte 'Guided Access' erst verlassen wenn die Prüfungszeit abgelaufen ist.";
                //toto: sagen ab wann man ausloggen darf
            } else {
                guidedProtectedAccessOn = NO;
                //user signalisieren dass er im falschen modus ist und zurück muss
                [secondViewController.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
                [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
                //[self.view setBackgroundColor:[UIColor redColor]];
                statusLabel.text = @"FEHLER. Bitte verlassen Sie den abgesicherten Modus wieder.";
            }
            [self hideLabels:YES];
        } else {
            [secondViewController.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            //[self.view setBackgroundColor:[UIColor whiteColor]];
            //UITabBarItem *tabBarItem = [[self.tabBarController.tabBar items] objectAtIndex:1];
            //[tabBarItem setEnabled:NO];
            
            if (guidedProtectedAccessOn) {
                //signalisieren zurück aus richtigem modus
                //todo: alles zurüchschreiben
                //todo: nur wenn zeit noch nicht abgelaufen, ja nach dem oke oder sagen dass jetzt gar nicht oke oder gratulieren
                
                //warnton
                /*SystemSoundID soundID;
                NSString *path = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
                AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: path]), &soundID);
                AudioServicesPlaySystemSound(soundID);*/
                statusLabel.text = @"Sie sind zu früh ausgeloggt. Bitte melden sie sich beim Prüfungspersonal, ansonsten ist die Prüfung ungültig.";
                //todo: dieser text sollte bleiben
            } else {
                //signalisieren zurück aus falschen modus ist nicht noetig
                [self updateAll];
            }
            guidedProtectedAccessOn = NO;
            [self hideLabels:NO];
        }
        [secondViewController.myTableView reloadData];
    }
    self.firstTimeGuidedAccessChange = NO;
}

#pragma mark -
#pragma mark Set Routines

-(void) setVolumeLevel {
    MPVolumeView* volumeView = [[MPVolumeView alloc] init];
    //find the volumeSlider
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    [volumeViewSlider setValue:volMin animated:YES];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark Update Routines

-(BOOL)updateTextEntries {
    
    BOOL isOke = NO;
    if (codeTextField.text.length>=codeLenghtMin && nameTextField.text.length > 0) {
        isOke = YES;
    }
    if (codeTextField.text.length<codeLenghtMin) {
        codeTextField.backgroundColor = [UIColor redColor];
    } else {
        codeTextField.backgroundColor = [UIColor whiteColor];
    }
    if (nameTextField.text.length==0) {
        nameTextField.backgroundColor = [UIColor redColor];
    } else {
        nameTextField.backgroundColor = [UIColor whiteColor];
    }
    return isOke;
    
}

- (BOOL)updateMemory {
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (int)pagesize;
    natural_t mem_free = vm_stat.free_count * (int)pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSString *levelText = [NSString stringWithFormat:@"used: %u MB free: %u MB total: %u MB", mem_used/1024/1024, mem_free/1024/1024, mem_total/1024/1024];
    memoryLevelLabel.text = [NSString stringWithFormat:@"speicher: %@",levelText];
    //NSLog(@"used: %u MB free: %u MB total: %u MB", mem_used/1024/1024, mem_free/1024/1024, mem_total/1024/1024);
    
    //memoryLevelLabel.text = [NSString stringWithFormat:@"speicher: %llu",[NSProcessInfo processInfo].physicalMemory/1024/1024];
    BOOL isOke = NO;
    if (mem_free/1024/1024>=memMin) {
        isOke = YES;
        memoryLevelLabel.textColor = [UIColor darkTextColor];
    } else {
        memoryLevelLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}

- (BOOL)updateHostConnectionState {
    
    NSString *remoteHostName = @"www.apple.com";
    //NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
    //self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    Reachability *hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [hostReachability startNotifier];
    NetworkStatus status = [hostReachability currentReachabilityStatus];
    
    NSString *statusText = @"";
    if(status == NotReachable) {
        //No internet
        statusText = @"nicht erreichbar";
    } else if (status == ReachableViaWiFi) {
        //WiFi
        statusText = @"erreichbar, WLAN";
    } else if (status == ReachableViaWWAN) {
        statusText = @"erreichbar, Mobiles Netz";
    }
    hostStateLabel.text = [NSString stringWithFormat:@"hoststatus: %@",statusText];
    [hostReachability stopNotifier];
    
    BOOL isOke = NO;
    if (status == ReachableViaWiFi) {
        isOke = YES;
        hostStateLabel.textColor = [UIColor darkTextColor];
    } else {
        hostStateLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}

- (BOOL)updateConnectionState {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    NSString *statusText = @"";
    if(status == NotReachable) {
        //No internet
        statusText = @"kein Netzwerk";
    } else if (status == ReachableViaWiFi) {
        //WiFi
        statusText = @"WLAN";
    } else if (status == ReachableViaWWAN) {
        statusText = @"Mobiles Netz";
        
    }
    networkStateLabel.text = [NSString stringWithFormat:@"netzwerkstatus: %@",statusText];
    [reachability stopNotifier];
    
    BOOL isOke = NO;
    if (status == ReachableViaWiFi) {
        isOke = YES;
        networkStateLabel.textColor = [UIColor darkTextColor];
    } else {
        networkStateLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}

/*- (BOOL)updateVolumeLevel {
    MPMusicPlayerController *iPod = [MPMusicPlayerController iPodMusicPlayer];
    float volumeLevel = iPod.volume;
    volumeLevelLabel.text = [NSString stringWithFormat:@"lautstärke: %f", volumeLevel];
    //NSLog(@"output volume: %f", volumeLevel);
    
    //float vol = [[AVAudioSession sharedInstance] outputVolume];
    //NSLog(@"output volume: %f", vol);
    //NSLog(@"output volume: %1.2f dB", 20.f*log10f(vol+FLT_MIN));
    
    BOOL isOke = NO;
    if (volumeLevel >= volMin) {
        isOke = YES;
        volumeLevelLabel.textColor = [UIColor darkTextColor];
    } else {
        volumeLevelLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}*/

- (BOOL)updateTime {
    NSDate *todayLocal = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *localTime = [dateFormatter stringFromDate:todayLocal];
    localTimeLabel.text = [NSString stringWithFormat:@"lokale Zeit: %@", localTime];
    //NSLog(@"User's current time in their preference format:%@",currentTime);
    
    NSDate *todayServer = [NSDate networkDate];
    NSString *serverTime = [dateFormatter stringFromDate:todayServer];
    serverTimeLabel.text = [NSString stringWithFormat:@"server Zeit: %@", serverTime];
    
    NSTimeInterval secs = [todayLocal timeIntervalSinceDate:todayServer];
    //NSLog(@"Seconds --------> %f", secs);
    
    BOOL isOke = NO;
    if (fabs(secs)<timeDiffMax) {
        isOke = YES;
        localTimeLabel.textColor = [UIColor darkTextColor];
    } else {
        localTimeLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}

- (BOOL)updateBatteryLevel {
    
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.levelLabel.text = NSLocalizedString(@"bat: level unbekannt", @"");
    } else {
        
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
            
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        self.levelLabel.text = [numberFormatter stringFromNumber:levelObj];
        
    }
    
    BOOL isOke = NO;
    if (batteryLevel>=batMin) {
        isOke = YES;
        levelLabel.textColor = [UIColor darkTextColor];
        stateLabel.textColor = [UIColor darkTextColor];
    } else {
        if (stateLabel.textColor == [UIColor redColor]) {
            levelLabel.textColor = [UIColor redColor];
        } else {
            levelLabel.textColor = [UIColor darkTextColor];
        }
        
    }
    
    return isOke;
}


- (BOOL)updateBatteryState {

    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    if (currentState==0) {
        stateLabel.text = @"bat: status unbekannt";
    } else if (currentState==1) {
        stateLabel.text = @"bat: Batteriebetrieb";
    } else if (currentState==2) {
        stateLabel.text = @"bat: am Strom, Zelle laded";
    } else if (currentState==2) {
        stateLabel.text = @"bat: am Strom, Zelle voll";
    }
    //stateLabel.text =  [NSString stringWithFormat:@"%ld",currentState-UIDeviceBatteryStateUnknown];
    
    BOOL isOke = NO;
    if (currentState!=1) {
        isOke = YES;
        stateLabel.textColor = [UIColor darkTextColor];
    } else {
        stateLabel.textColor = [UIColor redColor];
    }
    
    return isOke;
}

#pragma mark -
#pragma mark Jailbreaktest

/*+(BOOL)isJailbroken {
 
 #if TARGET_IPHONE_SIMULATOR
 return NO;
 #else
 BOOL isJB = NO;
 NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
 isJB = [[UIApplication sharedApplication] canOpenURL:url];
 
 NSString *filePath = @"/Applications/Cydia.app";
 if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) isJB = YES;
 
 FILE *f = fopen("/bin/bash", "r");
 if (errno != ENOENT) isJB = YES;
 fclose(f);
 
 return isJB;
 #endif
 }*/

+(BOOL)isJailbroken {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]){
        return YES;
    }
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        //Device is jailbroken
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        //Device is jailbroken
        return YES;
    }
    
    FILE *f = fopen("/bin/bash", "r");
    BOOL isJB = NO;
    if (f != NULL){
        //Device is jailbroken
        isJB = YES;
    }
    fclose(f);
    f = fopen("/Applications/Cydia.app", "r");
    if (f != NULL){
        //Device is jailbroken
        isJB = YES;
    }
    fclose(f);
    f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r");
    if (f != NULL){
        //Device is jailbroken
        isJB = YES;
    }
    fclose(f);
    f = fopen("/usr/sbin/sshd", "r");
    if (f != NULL){
        //Device is jailbroken
        isJB = YES;
    }
    fclose(f);
    f = fopen("/etc/apt", "r");
    if (f != NULL){
        //Device is jailbroken
        isJB = YES;
    }
    fclose(f);
    
    if(isJB) return YES;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:@"/private/var/lib/apt/"]){
        //Device is jailbroken
        return YES;
    }
#endif
    
    //All checks have failed. Most probably, the device is not jailbroken
    return NO;
}


#pragma mark -
#pragma mark MemoryManagement

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
}

#pragma mark -
#pragma mark Text Field

-(void)textFieldDidEndEditing:(UITextField *)sender {
    [self updateAll];
    [[NSUserDefaults standardUserDefaults] setObject:nameTextField.text forKey:@"studentName"];
}

- (void)closeKeyboard:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)resignAllResponders {
    [codeTextField resignFirstResponder];
    [nameTextField resignFirstResponder];
}




@end
