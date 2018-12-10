
import Foundation

class SendNoteToCommuniqueBox: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    var methodName: String = "SendNoteToCommuniqueBox"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var strctMsg:structChatMsg  = structChatMsg()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><SendNoteToCommuniqueBox xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidComminiqueBox>\(params[1])</suidComminiqueBox><sContent>\(params[2])</sContent></SendNoteToCommuniqueBox></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            if respCode == 0 {
                let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_suidNote"]
                strctMsg.id = Utility.suidToInt(dictData.value!)
                DBChats.addMessages([strctMsg])
                DBChats.updateGroupSequence(strctMsg.groupID)
                publicChatUpdates = true
            }
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
    
}
