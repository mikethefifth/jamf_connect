#  Jamf Connect Actions Menu Read Me

The Actions Menu is single menu item within Jamf Connect’s menu bar application that administrators can customize for their needs. The Actions Menu is composed of "actions" which are defined by preferences in the "com.jamf.connect.actions" domain. In this domain Actions are listed as an array of dictionaries with each dictionary comprising one action. Each dictionary is used to determine the visual state of the menu item - name, style, color, order.

The Actions Menu is aware of updates to the preference file and does not require Connect to be re-launched in order to load the new actions. When the preferences are changed, Connect rebuilds the entire menu from scratch and runs all tests and other housekeeping items.

Actions are run lazilly in the background, so don't expect immediate satisfaction when testing things. Since the commands are checked every time Connect does an update cycle (on launch, every 15 minutes, on network change, or when the menu is clicked), but run in the background, the first time the UI is shown it may have the old status/text/data. The actions will update in the background and the UI will update accordingly.

## Global Options

Within the `com.jamf.connect.actions` there are a few global pref keys that can determine the behavior of the menu.

| Attribute | Definition | Type | Required |
|-----------|------------|------|----------|
| Version | The numeric version of the preference file. Currently only "1" is suppored | Integer | yes |
| MenuIcon | Determines if the Actions menu itself will have a red/yellow/green light next to it. | Bool | no |
| MenuText| Determines if the text of the main Action menu be the result of a command | Bool | no |

* MenuIcon will display a red/yellow/green icon next to the main Action menu based upon "worst" of the visible items in the submenu. In other words, if you have any visible submenu actions that have a red icon next to them, the main menu will have a red icon. If any visible submenu actions are yellow, and none are red, the main menu item will have a yellow icon.
* MenuText requires a command to return a result of `<<menu>>` followed by the text you'd like in order to create the menu. The last command to return a result containing `<<menu>>` will determine what the menu title is.

## Anatomy of an action

An action is comprised of some meta data and then four phases. Each phase has a collection of Commands in them. These Commands have the Command itself and then a CommandOptions that can modify the command. Commands can execute external scripts or use the built in functions included with Actions. The only required part of the Action is the name of the action, all the other parts are optional. To break out a sample Action

| Attribute | Definition | Type | Required |
|-----------|------------|------|----------|
| Name | Plaintext name of the Action. The displayed menu item name can be overridden by the result of `Title`, if configured. | String | yes |
| Title | Command Set that determines the name of the menu item | Dictionary | no |
| Show | Command Set that determine if the item should be shown in the menu | Array | no |
| Action | Command Set that make up the actual Action itself | Array | no
| Post | Command Set that will happen after the Action commands are run | Array | no |
| GUID | Unique ID for the Action | String | no |
| Connected | If the action set should only be run when connected to the AD domain | Bool | no |
| Timer | Length in minutes between firing the Action | Integer | no |
| ToolTip | Text that is visible when the cursor hovers over the menu item | String | no |


* Note that the Title Command set can only have one command
* If the Title command returns "false" or "true" the text of the title won't be updated. Instead a red, in the case of "false", or green dot will be next to the menu item and the title will be the Name of the action set. If the Title command returns "yellow", a yellow dot will be shown next to the item.
* An Action with the Name of "Seperator" will become a separator bar in the menu.
* An Action with no Action command set will be greyed out in the menu bar. If you'd like to have a menu item enabeld but with no action, add the "true" command to the Action command set.

## Commands

Jamf Connect has a number of built-in commands to make things easy, however, since one command is to execute a script, you'll quickly be able to make any unique commands that you want.

Each command has a CommandOptions value that determines what the command does. All options are strings. All commands can return results. A result of "false" is used by the Show action to prevent the menu item from being shown.

| Command | Function | Options |
|---------|----------|---------|
| path | Excute a binary at a specific file path | The path to execute |
| app | Launch an app at a specific file path | The path to the application |
| url | Launch a URL in the user's default browser | The URL to launch |
| ping | Ping a host, will return false if the host is unpingable | The host to ping|
| adgroup | Determine if the current user is a member of an AD group | The group to test with |
| alert | Display a modal dialog to the user | Text of the dialog |
| notify | Display a notification in the notification center | Text of the notification |
| false | A command that always returns false | Anything |
| true | A command that always returns true | Anything |

* The result of any command can be passed on to the next one. Using `<<result>>` in your command options will cause it to be replaced with the result of the previous command. Note that "true" or "false" results will not be conveyed to the next command.
* When using the "alert" and "notify" commands, if the command options are blank or are either "true" or "false", no alert or notification will be displayed. You can use this to only show errors.
* Adding "True" or "False" at the end of the command will only trigger that command if the previously run command returns "true" or "false". For example, using "alertTrue" as the command name will only run that command if the previously run command returned "true". Keep in mind that the result state is persistant, so you can have one "path" command, for example, return "true" and then multiple commands following it with "False" in the command name. None of the "False" commands would run. Also note that capitalization is important here.
* The "true" and "false" commands, note the capitalization, can be used to clear any previous results in the command set.
* Results do not persist between command sets.
* Command options support the standard Jamf Connect variable swaps such as `<<domain>>`, `<<user>>`, and `<<email>>`.

## Workflow

* On launch, Jamf Connect looks at the `com.jamf.connect.actions` preference domain and reads in any Actions.
* For each Action, Connect will run the Show command set to determine if the menu item should be shown. Note that all commands in the Show command set have to return positive for the menu item to be shown.
* For items that pass the Show test, Connect will then run the Title command set to get the text of the menu item. If no command set has been configured, the Action name will be used instead.
* An item that is clicked on will cause the item's Action command set to be run.
* Following the Action set running, the Post set will then be run acting on the result of the Action set.
* Every time Connect updates (every 15 minutes, network change or Connect menu interaction) the Actions items will be updated with the same process.

## URIs

Actions will respond to `jamfconnect://action/ActionName` URIs so you can run them from the command line via `open jamfconnect://action/DoSomething`. For actions with a space in the name, or other upper ascii characters, use standard percent encoding when listing them in the URI. Note: when running actions in this way, the Title or Show command sets will not be executed.

Using `jamfconnect://actionsilent/ActionName` will run the specified Action command set, but not the corresponding Post command set.
