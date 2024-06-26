public with sharing class te_profilePhotoController {
    
    @AuraEnabled
    public static ConnectApi.Photo setProfilePhoto(String base64Image) {
        System.debug(base64Image);
        Blob imageBlob = EncodingUtil.base64Decode(base64Image);

        String userId = UserInfo.getUserId();
        ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(null, userId, new ConnectApi.BinaryInput(imageBlob, 'image/jpg', 'userImage.jpg'));
        return photo;
    }
}