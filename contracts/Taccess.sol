pragma solidity  ^0.4.24;
import "./upload.sol";


contract Taccess {
    // the authorize of the Info provider

    address[] setAuthorizelist;//  用户授权的地址列表
    address[] waitAuthorizelist; // 待授权的地址列表
    address[] revokeAuthorizelist;// 撤销授权的地址列表

    mapping (address => address[]) setList; // 用户的地址和授权列表的映射关系
    mapping (address => address[]) revokeList; // 用户的地址和撤销列表的映射关系
    mapping (address => address[]) waitList; //用户的地址和待授权列表的映射关系
    mapping (address => uint) walletMap;

    struct Info {
        string name;
        string date;
        string phone;
        string sex;
        uint id;
    }

    function Taccess( uint userID ) public {
        address tempaddr = Upload.MappingID[userID];
        // 初始化和用户地址相关的所有列表信息
        setList[userID] = setAuthorizelist;
        revokeList[userID] = revokeAuthorizelist;
        waitList[userID] = waitAuthorizelist;
    }

// 企业请求数据
    function Requiredata(uint userID) public returns( Info ) {
        address addr=msg.sender;
        address tempaddr = Upload.MappingID[userID]; // 根据用户的ID找到用户的地址
        revokeAuthorizelist = revokeList[tempaddr]; // 获取用户地址的撤销列表
        bool result = Isaccess(userID);
        uint count = 0;
        uint wallet;
        wallet = walletMap[userID];
        Info memory data = Info("", "", "", "", 0);

        if (result == true) {
            // 查看企业的地址是否曾经有过违规行为
            for (uint k=0; k < revokeAuthorizelist.length; k++) {
                if (addr == revokeAuthorizelist[k]) {
                    count = count+1;
                }
            }
            if (wallet >= count) {
                wallet = wallet-count;
                data = Upload.getUpload();
            }
        }
          return data;// 如果没有成功请求到数据，data中的ID信息为0；
    }
    function Isaccess( uint userID) public returns (bool) {

        address addr = msg.sender;
        address tempaddr = Upload.MappingID[userID]; // 根据用户的ID找到用户的地址
        setAuthorizelist = setList[tempaddr]; //根据用户地址的映射关系，找到授权的列表
        for (uint i=0;i < setAuthorizelist.length;i++) {
            if (addr == setAuthorizelist[i]) {

                return true;
            }
        }
        return false;
    }

// 企业请求授权
    function Requireaccess(address addr,uint userID) public returns(address[]) {
        address tempaddr = Upload.MappingID[UserID]; // 根据用户的ID找到用户的地址
        waitAuthorizelist = waitList[tempaddr];// 取出待授权的列表
        uint i = waitAuthorizelist.length;
        waitAuthorizelist[i] = addr;
        return waitAuthorizelist;

    }
 // 显示用户的授权列表
    function ListsetAuthorizelist(address addr) public returns(address[]) {
        setAuthorizelist = setList[addr];
        return setAuthorizelist;
    }


 // 显示用户的待授权列表
     function ListwaitAuthorizelist(address addr) public returns(address[]) {
        waitAuthorizelist = waitList[addr];
        return waitAuthorizelist;
    }

// 用户向新的地址授权
    function addaccess(address addr, uint UserID) private returns(address[]) {
        address tempaddr = Upload.MappingID[UserID]; // 根据用户的ID找到用户的地址
        setAuthorizelist = setList[tempaddr]; //根据用户地址的映射关系，找到授权的列表
        uint i=setAuthorizelist.length;
        setAuthorizelist[i] = addr;
        return setAuthorizelist;
    }

// 用户对授权的地址撤销
    function revokeaccess(address addr,uint UserID) private returns(address[], address[]) {
        address tempaddr = Upload.MappingID[UserID]; // 根据用户的ID找到用户的地址
        setAuthorizelist = setList[tempaddr]; //根据用户地址的映射关系，找到授权的列表
        revokeAuthorizelist = revokeList[tempaddr]; //根据用户地址的映射关系，找到撤销授权的列表
        uint i=revokeAuthorizelist.length;// 把地址放入撤销列表当中
        revokeAuthorizelist[i] = addr;
        // 把地址从授权列表中剔除
        address[] templist;
        templist = setAuthorizelist;
        for (uint k = 0; k < setAuthorizelist.length; i++){
            if (setAuthorizelist[k] == addr){
                for (uint t = k;t < setAuthorizelist.length-1;t++){
                    setAuthorizelist[t] = templist[t+1];
                    return (setAuthorizelist, revokeAuthorizelist);
                }
            }
        }
    }

}
