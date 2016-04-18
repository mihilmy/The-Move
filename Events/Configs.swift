import Foundation
import UIKit
import Parse

// Constants
let APP_NAME = "The Move"
let parseAppKey = "zo1suyGv5bcIg2iQLXsywyX4waWyW342XPffM7xu"
let parseClientKey = "il4dTyMAm8G1haZ0thp21XG8BrC1i51HqxHMYhjI"

// For knowing which object was selected.
var SelectedEvent: PFObject!
// List of all current events
var EventsStrings = [String]()
// Checks if the user is new
var isNewUser = true
// Max Query Limit
let QueryLimit = 20
// HUD VIEW (customizable by editing the code below)
var hudView = UIView()
var animImage = UIImageView(frame: CGRectMake(0, 0, 80, 80))

// EVENTS CLASS
var EVENTS_CLASS_NAME = "Events"
var EVENTS_TITLE = "title"
var EVENTS_DESCRIPTION = "description"
var EVENTS_WEBSITE = "website"
var EVENTS_LOCATION = "location"
var EVENTS_START_DATE = "startDate"
var EVENTS_END_DATE = "endDate"
var EVENTS_COST = "cost"
var EVENTS_IMAGE = "image"
var EVENTS_IS_PENDING = "isPending"
var EVENTS_KEYWORDS = "keywords"
var EVENTS_UPLOADING_USER = "uploadingUser"

// EVENT GALLERY CLASS
var GALLERY_CLASS_NAME = "Gallery"
var GALLERY_EVENT_ID = "eventID"
var GALLERY_IMAGE = "image"


//USER CLASS
var USER_CLASS_NAME = "_User"
var USER_OBJECT_ID = "objectId"
var USER_NAME = "username"
var firstName = "first_name"
var lastName = "last_name"
var PRO_PIC = "profile_picture"
var IS_VENUE = "isVenue"

//CURRENT USER PROFILE
//var CURRENT_USER_OBJECT_ID = PFUser.currentUser()?.objectId
var CURRENT_FIRST_NAME = "first"
var CURRENT_LAST_NAME = "last"
var CURRENT_PRO_PIC = NSData()

// Moves Query
func queryMovesWithin(hours: Double) -> [PFObject]{
    // Return value
    var moves: [PFObject] = []
    // Get the current date.
    let currentDate = NSDate()
    // Add the number of
    let cutOff = currentDate.dateByAddingTimeInterval(hours)
    
    let query = PFQuery(className:"Moves")
    query.whereKey("endDate", greaterThanOrEqualTo: currentDate)
    query.whereKey("startDate", lessThanOrEqualTo: cutOff)
    
    query.findObjectsInBackgroundWithBlock {
        (objects: [PFObject]?, error: NSError?) -> Void in
        // If there is no error then
        if(error != nil){
            print(error)
        }else {
            moves = objects!
        }
    }
    
    return moves
    
}

//
func displayErrorMessage(error: NSError) -> UIAlertController{
    let alert = UIAlertController(title: "Alert:", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(action)
    
    return alert
}

// Extensions for the loading hud
extension UIView {
    func showHUD(inView: UIView) {
        hudView.frame = CGRectMake(0, 0, inView.frame.size.width, inView.frame.size.height)
        hudView.backgroundColor = UIColor.whiteColor()
        hudView.alpha = 0.9
        
        let imagesArr = ["h0", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9"]
        var images : [UIImage] = []
        for var i = 0;   i < imagesArr.count;   i++ {
            images.append(UIImage(named: imagesArr[i])!)
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.7
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        
        inView.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
}

// Extensions for removing white space from phone numbers
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
}

// Extenstions to allow date comparisons
extension NSDate {
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }

    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func isSameAsDate(dateToCompare : NSDate) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        return isEqualTo
        }
}

// COLOR CONTANTS
let mainColor = UIColor(red: 43.0/255.0, green: 48.0/255.0, blue: 52.0/255.0, alpha: 1.0)
let red = UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let orange = UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0)
let yellow = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 85.0/255.0, alpha: 1.0)
let lightGreen = UIColor(red: 160.0/255.0, green: 212.0/255.0, blue: 104.0/255.0, alpha: 1.0)
let mint = UIColor(red: 72.0/255.0, green: 207.0/255.0, blue: 174.0/255.0, alpha: 1.0)
let aqua = UIColor(red: 79.0/255.0, green: 192.0/255.0, blue: 232.0/255.0, alpha: 1.0)
let blueJeans = UIColor(red: 93.0/255.0, green: 155.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let lavander = UIColor(red: 172.0/255.0, green: 146.0/255.0, blue: 237.0/255.0, alpha: 1.0)
let darkPurple = UIColor(red: 150.0/255.0, green: 123.0/255.0, blue: 220.0/255.0, alpha: 1.0)
let pink = UIColor(red: 236.0/255.0, green: 136.0/255.0, blue: 192.0/255.0, alpha: 1.0)
let darkRed = UIColor(red: 218.0/255.0, green: 69.0/255.0, blue: 83.0/255.0, alpha: 1.0)
let paleWhite = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 251.0/255.0, alpha: 1.0)
let lightGray = UIColor(red: 230.0/255.0, green: 233.0/255.0, blue: 238.0/255.0, alpha: 1.0)
let mediumGray = UIColor(red: 204.0/255.0, green: 208.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let darkGray = UIColor(red: 67.0/255.0, green: 74.0/255.0, blue: 84.0/255.0, alpha: 1.0)
let brownLight = UIColor(red: 198.0/255.0, green: 156.0/255.0, blue: 109.0/255.0, alpha: 1.0)





