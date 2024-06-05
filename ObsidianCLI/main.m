//
//  main.m
//  ObsidianCLI
//
//  Created by Daniele De Marco on 05/06/24.
//

#import <Foundation/Foundation.h>

bool checkIfVaultNameIsSpecified(int argc, NSArray<NSString *> *arguments);

NSString* getUserInput(void);
NSString* getDefaultVaultName(void);
void setDefaultVaultName(NSString *vaultName);

void openDefaultVault(void);
void openVault(NSString *vaultName);

void searchVault(NSString *vaultName, NSString *query);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray<NSString *> *arguments = [[NSProcessInfo processInfo] arguments];
        
        if (argc > 1) {
            // NSArray *words = [NSArray arrayWithObjects: @"-h", @"--help", @"help", @"--set-default-vault", @"open", @"search", @"create", @"delete", nil]; // array of possible commands
            
            NSString *action = arguments[1]; // second argument gets put inside the command obj
            if ([[NSSet setWithObjects: @"-h", @"--help", @"help", nil] containsObject:action]) { // help
                NSLog(@"HELP: This is the help message");
            }else if([action isEqualToString:@"--set-default-vault"]){ // set default vault
                NSString *vaultName = [NSString alloc];
                if (argc > 2) { // if already specified in the command
                    vaultName = arguments[2];
                }else{ // if not specified, take from input
                    NSLog(@"Enter the name of the vault you want to set as default: ");
                    vaultName = getUserInput();    
                }
                setDefaultVaultName(vaultName);
                NSLog(@"Default vault set to: %@", vaultName);
            }else if ([action isEqualToString:@"search"]) { // ./ObsidianCLI search -v vaultName -q searchQuery
                if (argc > 3) {
                    int queryIndex = 4;
                    NSString *vaultName = [NSString alloc];
                    if(checkIfVaultNameIsSpecified(argc, arguments))
                        vaultName = arguments[3];
                    else{
                        vaultName = getDefaultVaultName();
                        queryIndex = 2;
                    }

                    if ([arguments[queryIndex] isEqualToString:@"-q"]) {
                        NSString *query = arguments[queryIndex + 1];
                        searchVault(vaultName, query);
                    }else{
                        NSLog(@"Enter the query you want to search for: ");
                        NSString *query = getUserInput();
                        searchVault(vaultName, query);
                    }
                }else {
                    NSLog(@"Enter the query you want to search for: ");
                    NSString *query = getUserInput();
                    searchVault(getDefaultVaultName(), query);
                }


            }else if([action isEqualToString:@"open"] || argc == 2) { // open
                if (argc > 2) {
                    NSString *vaultName = checkIfVaultNameIsSpecified(argc, arguments) ? arguments[3] : arguments[2];
                    openVault(vaultName);
                }else { openDefaultVault(); }
            }else if (argc == 1) { openDefaultVault(); }
        }
        return 0;
    }
}

NSString* getUserInput(void){
    NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
    NSData *inputData = [input availableData]; // gets the input from the user
    NSString *inputString = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding]; // inputString will contain inputData as string. If the data can't be decoded as a UTF-8 string, inputString will be nil.
    inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; // removes newline character from inputString]

    return inputString;
}
    
bool checkIfVaultNameIsSpecified(int argc, NSArray<NSString *> *arguments){
    if (argc > 2) {
        return [arguments[2] isEqualToString:@"-v"];
    }
    return false;
}

void setDefaultVaultName(NSString *vaultName){
    if (vaultName) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:vaultName forKey:@"defaultVault"];
        [defaults synchronize];
    }
}

void launchTerminalTask(NSString *command){
    // prepping the command to open the vault
    NSArray *arguments = [NSArray arrayWithObjects:@"-c", command, nil];

    // initiating the task 
    NSTask *task = [[NSTask alloc] init];
    // setting the launch path and arguments
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:arguments];
    // launching the task
    [task launch];
}

void openVault(NSString *vaultName){
    // prepping the command to open the vault
    NSString *openObsidian = [NSString stringWithFormat:@"open \"obsidian://open?vault=%@\"", vaultName];
    // launching the task
    launchTerminalTask(openObsidian);
}

NSString* getDefaultVaultName(void){
    // gather defaultVault name from user defaults and check if it is nil, exit with an error if so
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultVault = [defaults objectForKey:@"defaultVault"];
    if (!defaultVault) {
        NSLog(@"No default vault set. Use 'obsidian --set-default-vault <vault-name>' to set a default vault.");
        exit(1);
    }
    return defaultVault;
}

void openDefaultVault(void){
    openVault(getDefaultVaultName());
}

void searchVault(NSString *vaultName, NSString *query){
    // prepping the command to search the vault
    NSString *searchObsidian = [NSString stringWithFormat:@"open \"obsidian://search?vault=%@&query=%@\"", vaultName, query];
    // launching the task
    launchTerminalTask(searchObsidian);
}
