
import UIKit

class hostGroupsCell: UITableViewCell
{
    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupLocation: UILabel!
    @IBOutlet var groupImage: UIImageView!
    
    @IBOutlet var groupContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero
        groupContainer.layer.cornerRadius = 4.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(groupDetails: structChatMsgGroup)
    {
        groupName.text = Utility.userNamesExceptYou(groupDetails.userList)
        groupLocation.text = groupDetails.name
    }
}
