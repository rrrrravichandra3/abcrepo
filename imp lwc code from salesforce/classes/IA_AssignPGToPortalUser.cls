public class IA_AssignPGToPortalUser implements Queueable{
public List<User> newUserList;
    
    public IA_AssignPGToPortalUser(List<User> userList){
        newUserList = userList;
    }
    public void execute(QueueableContext context){
        //IA_AssignPGToPortalUserHandler.assignPG(newUserList);
    }
}