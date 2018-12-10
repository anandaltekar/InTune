
import Foundation

class SetAcceptRejectMatchesFound: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "SetAcceptRejectMatchesFound"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var selectedVal: String = ""
    var chatGroup:structChatMsgGroup = structChatMsgGroup()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><SetAcceptRejectMatchesFound xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidCommuniqueBox>\(params[1])</suidCommuniqueBox><nFlag>\(params[2])</nFlag></SetAcceptRejectMatchesFound></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
        let xmlDoc = try AEXMLDocument(xmlData: responseData)
        
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            print("######Method \(methodName) Received with Response Code--\(respCode)")
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]
            selectedVal = dictData["_nFlagSet"].value!
            let item:AEXMLElement = dictData["_CommuniqueBoxInfo"]
            let userList:AEXMLElement = item["aCommuniqueBoxUsers"]
            if userList.children.count > 0
            {
                chatGroup.id = Utility.suidToInt(item["suidCommuniqueBox"].value!)
                chatGroup.name = item["sCommuniqueBoxName"].value!
                if (item["sDateTime"].value != nil)
                {
                    chatGroup.date = item["sDateTime"].value!
                }
                chatGroup.badgeCount = Int(item["nUpdatedNoteCount"].value!)!
                chatGroup.type = Int(item["nCommuniqueBoxType"].value!)!
                
                for var t:Int = 0; t<userList.children.count; t++
                {
                    let usrXml:AEXMLElement =  userList.children[t]
                    var user:structChatMsgUser = structChatMsgUser()
                    user.id = Utility.suidToInt(usrXml["suidUser"].value!)
                    user.name = usrXml["sUserName"].value!
//                    if usrXml["sfbUserProfilePicLink"].value != nil
//                    {
//                        user.imgPath = usrXml["sfbUserProfilePicLink"].value!
//                    }
                    if usrXml["sfbUserId"].value != nil
                    {
                        user.fbProfUrl = usrXml["sfbUserId"].value!
                    }
                    chatGroup.userList.append(user)
                }
                
            }
            pageTarget?.serviceResponse(self)
        }
            
            catch _ {
            }
            
    }
    
}