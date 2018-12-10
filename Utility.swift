import UIKit
import Foundation

class Utility
{
    static func suidToInt(suid:String)->Int
    {
        var returnVal:Int = -1
        if suid.characters.count>33{
            let firstHexChar:String = Utility.getSubStr(suid, startIndex: 0, endIndex: 1)
            let remainingString:String = Utility.getSubStr(suid, startIndex: 1, endIndex: suid.characters.count)
            let intSplitRange:Int = Utility.hexToInt(firstHexChar)
            let remFirstPart:String = Utility.getSubStr(remainingString, startIndex: 0, endIndex: (remainingString.characters.count-intSplitRange))
            let remEndPart:String = Utility.getSubStr(remainingString, startIndex: (remainingString.characters.count-intSplitRange), endIndex: remainingString.characters.count)
            let rotateString:String = remEndPart+remFirstPart
            let Char18:String = Utility.getSubStr(rotateString, startIndex: 18, endIndex: 19)
            let strAfter33 = Utility.getSubStr(rotateString, startIndex: 33, endIndex: rotateString.characters.count)
            let hexStr:String=Char18+strAfter33
            returnVal = Utility.hexToInt(hexStr)
        }
        return returnVal
    }
    
    static func intToSuid(id:Int)->String
    {
        var hexStr:String = NSString(format:"%2X", id) as String
        hexStr = hexStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let hexFirstChar:String = getSubStr(hexStr, startIndex:0, endIndex:1)
        let hexLastStr:String = getSubStr(hexStr, startIndex:1, endIndex:hexStr.characters.count)
        var rndStr:String = NSUUID().UUIDString as String
        rndStr = rndStr.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let rndPart1:String = getSubStr(rndStr, startIndex:0, endIndex:18)
        let rndPart2:String = getSubStr(rndStr, startIndex:18, endIndex:rndStr.characters.count)
        let rotateStr:String = rndPart1+hexFirstChar+rndPart2+hexLastStr
        let rndNum:Int = Int(arc4random_uniform(16))
        var hexRndNum:String = NSString(format:"%2X", rndNum) as String
        hexRndNum = hexRndNum.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let rotateStrOne:String = getSubStr(rotateStr, startIndex:0, endIndex:rndNum)
        let rotateStrTwo:String = getSubStr(rotateStr, startIndex:rndNum, endIndex:rotateStr.characters.count)
        let suid:String = (hexRndNum+rotateStrTwo+rotateStrOne).lowercaseString
        let trimStr:String = suid.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimStr.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    static func hexToInt(hex:String)->Int{
        var returnVal = -1
        let scanner = NSScanner(string: hex)
        var result : UInt32 = 0
        if scanner.scanHexInt(&result) {
            returnVal = Int(result)
        }
        return returnVal
    }
    
    static func getSubStr(str:String, startIndex:Int, endIndex:Int)->String
    {
        var returnVal:String = ""
        returnVal = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(startIndex), end: str.startIndex.advancedBy(endIndex)))
        return returnVal
    }
    
    static func resetPublicVars()
    {
        let params:[String] = [publicSuidSession]
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("suidSession")
        userDefaults.removeObjectForKey("suidUser")
        userDefaults.removeObjectForKey("suidConcert")
        userDefaults.removeObjectForKey("fbDetails")
        userDefaults.removeObjectForKey("userType")
//        userDefaults.removeObjectForKey("firstUse")
        publicSuidSession       = ""
        publicSuidUser          = ""
        publicUserType          = Const.GUEST_USER
        userName                = ""
        fbAccessToken           = ""
        fbID                    = ""
        fbEmail                 = ""
        fbFirstName             = ""
        fbLastName              = ""
        fbLink                  = ""
        fbProfilePictureURL     = ""
        selectedConcert         = ""
//        flagToCheckFirstUse     = 1
//        userDefaults.setValue(flagToCheckFirstUse, forKey: "firstUse")
        DBChats.truncateChatData()
        
        var soapObject:LogOut!
        soapObject = LogOut()
        soapObject.request(params)
        let soapConnector:WSSoapConnector = WSSoapConnector()
        soapConnector.callAPI(soapObject)
    }
    
//    static func downloadProfilePicture(strURL:String, imgView:UIImageView)
//    {
//        let imgURL: NSURL = NSURL(string: strURL)!
//        let request: NSURLRequest = NSURLRequest(URL: imgURL)
//        NSURLConnection.sendAsynchronousRequest(
//            request, queue: NSOperationQueue.mainQueue(),
//            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
//                if error == nil
//                {
//                    let image:UIImage! = UIImage(data: data!)
//                    let fileManager = NSFileManager.defaultManager()
//                    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
//                    let pathWithImg = NSURL(fileURLWithPath: path).URLByAppendingPathComponent("profilePicture.jpg")
//                    let imageData: NSData = UIImagePNGRepresentation(image)!
//                    fileManager.createFileAtPath(pathWithImg.path!, contents: imageData, attributes: nil)
//                    let localImg:UIImage = UIImage(contentsOfFile: pathWithImg.path!)!
//                    
//                    dispatch_async(dispatch_get_main_queue(),
//                        {
//                            imgView.image = localImg
//                    })
//                }
//        })
//    }
    
    static func downloadFBPP(fbPPID:String, imgView:UIImageView, isLargePic:Bool)
    {
        var largeImgOption:String="/picture?width=100&height=100"
        var nameOpt:String = "_small"
        if isLargePic {
            largeImgOption = "/picture?width=400&height=400"
            nameOpt = "_large"
        }
        let fileManager = NSFileManager.defaultManager()
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let pathWithImg = NSURL(fileURLWithPath: path).URLByAppendingPathComponent("\(fbPPID+nameOpt).jpg")
        if fileManager.fileExistsAtPath(pathWithImg.path!) {
            let localImg:UIImage = UIImage(contentsOfFile: pathWithImg.path!)!
            imgView.image = localImg
        }
        else {
            imgView.image = UIImage(named: "default_user3.jpg")
            let strURL:String = Const.FB_PIC_URL+fbPPID+largeImgOption
            let imgURL: NSURL = NSURL(string: strURL)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
//            NSURLConnection.sendAsynchronousRequest(
//                request, queue: NSOperationQueue.mainQueue(),
//                completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
//                    
//            })
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if error == nil
                {
                    let image:UIImage! = UIImage(data: data!)
                    let imageData: NSData = UIImagePNGRepresentation(image)!
                    fileManager.createFileAtPath(pathWithImg.path!, contents: imageData, attributes: nil)
                    let localImg:UIImage = UIImage(contentsOfFile: pathWithImg.path!)!
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            imgView.image = localImg
                    })
                }
            })
            
            task.resume()
        }
    }
    
    static func pageGredient(view:UIView){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(netHex: 0xe01e36).CGColor, UIColor(netHex: 0xee631c).CGColor, UIColor(netHex: 0xfeae00).CGColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    static func userNamesExceptYou(userList:[structChatMsgUser])->String{
        var userNames:String = ""
        for user in userList {
            if user.id != Utility.suidToInt(publicSuidUser){
                userNames += " " + user.name + ","
            }
        }
        if userNames != "" {
            userNames = userNames.substringToIndex(userNames.endIndex.predecessor())
        }
        return userNames
    }
    
    static func notificationToGroup(notif:structNotification)->structChatMsgGroup
    {
        var strGroup:structChatMsgGroup = structChatMsgGroup()
        strGroup.id = notif.groupId
        strGroup.name = notif.message
        strGroup.status = Const.INACTIVE
        let userInfoArr:[String] = notif.other.componentsSeparatedByString(Const.NOTIF_JOIN_LVL2)
        strGroup.userCount = userInfoArr.count
        for item in userInfoArr {
            var userDetailsArr:[String] = item.componentsSeparatedByString(Const.NOTIF_JOIN_LVL3)
            if Utility.suidToInt(publicSuidUser) != Int(userDetailsArr[0])! {
                var userStrct:structChatMsgUser = structChatMsgUser()
                userStrct.id = Int(userDetailsArr[0])!
                userStrct.name = userDetailsArr[1]
                userStrct.fbProfUrl = userDetailsArr[2]
                strGroup.userList.append(userStrct)
                
            }
        }
        return strGroup
    }
    
    static func removeAllDocumentFiles(){
//        var error: NSErrorPointer = nil
//        var fileMgr: NSFileManager = NSFileManager()
//        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        var directoryContents: NSArray = fileMgr.contentsOfDirectoryAtPath(dirPath)
//        
//        if error == nil {
//            for path in directoryContents {
//                let fullPath = dirPath.stringByAppendingPathComponent(path as! String)
//                let removeSuccess = fileMgr.removeItemAtPath(fullPath, error: nil)
//            }
//        }
    }
    
    static func mergeUsers(baseUsers:[structChatMsgUser], newUsers:[structChatMsgUser])->[structChatMsgUser]{
        var returnUserList:[structChatMsgUser] = baseUsers
        for item in newUsers {
            for var i:Int=0; i<returnUserList.count; i++ {
                if item.id == returnUserList[i].id {
                    returnUserList[i].status = Const.ACTIVE
                    break
                }
            }
        }
        return returnUserList
    }
    
    static func getTimeStamp()->String{
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(date)
    }
    
    func formatDate(dateStr:String, dateFormat:String)->String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let date = formatter.dateFromString(dateStr)
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(date!)
    }
    
    func compareDate(dateStr:String){
        //Ref date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd YYYY hh:mm:ss"
        let someDate = dateFormatter.dateFromString(dateStr)
        
        //Get calendar
        let calendar = NSCalendar.currentCalendar()
        
        //Get just MM/dd/yyyy from current date
        let flags: NSCalendarUnit = [NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year]
        let components = calendar.components(flags, fromDate: NSDate())
        
        //Convert to NSDate
        let today = calendar.dateFromComponents(components)
        let interval = someDate!.timeIntervalSinceDate(today!)
        print(interval)
        //        if someDate!.timeIntervalSinceDate(today!).isSignMinus {
        //            println("someDate is berofe than today")
        //        } else {
        //            println("someDate is equal or after than today")
        //        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

// Anand: We want to discuss some points with you. Please let us know your availibility for call ASAP. There are two major things which we need to complete before going to run a pilot.

//
//

// 
