pragma solidity  ^0.4.24;


contract Upload {

    // the information of the person
    string userName;
    string phoneNumber;
    string birthDate;
    string sex;

    event CreateRecord(address indexed _address, string userName, string birthDate, string phoneNumber, string sex);

    function upload(string _userName, string _birthDate, string _phoneNumber, string _sex)  public {
        userName = _userName;
        phoneNumber = _phoneNumber;
        birthDate = _birthDate;
        sex = _sex;

        CreateRecord(msg.sender, userName, phoneNumber, birthDate, sex);
    }

    function getUpload() public returns(string, string, string, string) {
        return (
            userName, birthDate, phoneNumber, sex
        );
    }

}
