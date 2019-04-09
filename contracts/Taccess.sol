pragma solidity  ^0.4.24;


contract Taccess {
    // The number of users and companies.
    uint private usr_cnt = 0;
    uint private cpn_cnt = 0;

    // Mapping (uint => Info) users;
    mapping (uint => User) users; // id -> user
    mapping (uint => Company) companies; // id -> company
    mapping (uint => uint[]) setList; // 用户的地址和授权列表的映射关系
    mapping (uint => uint[]) revokeList; // 用户的地址和撤销列表的映射关系
    mapping (uint => uint[]) waitList; //用户的地址和待授权列表的映射关系
    mapping (uint => uint) balances; // id -> balance

    struct User {
        string name;
        string passwd;
        string date;
        string phone;
        string sex;
        uint id;
    }
    
    struct Company {
        string name;
        string passwd;
        uint id;
    }

    // Constructor of contract
    constructor() public {
        createUser("灿灿", "123456", "1206", "135xxxxxxxx", "F");
        createCompany("四川大学", "123456");
        requireAccess(cpn_cnt, usr_cnt);
        addAccess(cpn_cnt, usr_cnt);
    }

    event userID(uint usrID);
    event companyID(uint cpnID);
    event userData(string name, string passwd, string date, string phone, string sex, uint id);
    
    // Create a user account
    function createUser(string _name, string _pw, string _date,
        string _phone, string _sex) public returns (uint) {
        usr_cnt++;
        User memory user = User(_name, _pw, _date, _phone, _sex, usr_cnt);
        
        users[usr_cnt] = user;
        setList[usr_cnt] = new uint[](0);
        revokeList[usr_cnt] = new uint[](0);
        waitList[usr_cnt] = new uint[](0);
        balances[usr_cnt] = 0;
        
        userID(usr_cnt);
    }
    
    // Create a company account
    function createCompany(string _name, string _passwd) public returns (uint){
        cpn_cnt++;
        Company memory cpn = Company(_name, _passwd, cpn_cnt);
        companies[cpn_cnt] = cpn;
        
        balances[cpn_cnt] = 1000;
        
        companyID(cpn_cnt);
    }

    // 企业请求数据
    function requireData(uint companyID, uint userID) public 
        returns(string, string, string, string, string, uint) {
        uint[] memory revokeAuthorizeList = revokeList[userID]; // 获取用户地址的撤销列表
        int result = isAccess(companyID, userID);
        User memory user = User("", "", "", "", "", 0);

        if (result != -1) {
            uint count = 0;
            // 查看企业的地址是否曾经有过违规行为
            for (uint k=0; k < revokeAuthorizeList.length; k++) {
                if (companyID == revokeAuthorizeList[k]) {
                    count = count+1;
                }
            }
            
            if (balances[companyID] >= count) {
                balances[companyID] = balances[companyID] - count;
                balances[userID] = balances[userID] + count;
            }
            
            user = users[userID];
        }
        userData(user.name, user.passwd, user.date, user.phone, user.sex, user.id);// 如果没有成功请求到数据，data中的ID信息为0；
    }
    
    
    // 判断是否具有访问权限
    function isAccess( uint companyID, uint userID) public view returns (int) {
        uint[] storage setAuthorizeList = setList[userID]; //根据用户地址的映射关系，找到授权的列表
        
        return getIndex(companyID, setAuthorizeList);
    }

    // 企业请求授权
    function requireAccess(uint companyID, uint userID) public {
        uint[] storage waitAuthorizeList = waitList[userID];// 取出待授权的列表
        int index = getIndex(companyID, waitAuthorizeList);
        
        if (index == -1) {
            waitAuthorizeList[waitAuthorizeList.length++] = companyID;
        }
    }

    // 显示用户的授权列表
    function listSetAuthorizeList(uint userID) public view returns(uint[]) {
        uint[] storage setAuthorizeList = setList[userID];
        return setAuthorizeList;
    }

    // 显示用户的待授权列表
     function listWaitAuthorizeList(uint userID) public view returns(uint[]) {
        uint[] storage waitAuthorizeList = waitList[userID];
        return waitAuthorizeList;
    }

    // 用户向新的地址授权
    function addAccess(uint companyID, uint userID) public {
        uint[] storage setAuthorizeList = setList[userID]; //根据用户地址的映射关系，找到授权的列表
        uint[] storage waitAuthorizeList = waitList[userID]; //
        
        int wait_index = getIndex(companyID, waitAuthorizeList);
        if (wait_index != -1) {
            for (uint t=uint(wait_index); t < waitAuthorizeList.length-1; t++) {
                waitAuthorizeList[t] = waitAuthorizeList[t + 1];
            }
            waitAuthorizeList.length--;
            
            int set_index = getIndex(companyID, setAuthorizeList);
            if (set_index == -1){
                setAuthorizeList[setAuthorizeList.length++] = companyID;
            }
        }
    }

    // 用户对授权的地址撤销
    function revokeAccess(uint companyID, uint userID) public {
        uint[] storage setAuthorizeList = setList[userID]; //根据用户地址的映射关系，找到授权的列表
        uint[] storage revokeAuthorizeList = revokeList[userID]; //根据用户地址的映射关系，找到撤销授权的列表

        // 把地址从授权列表中剔除
        int index = getIndex(companyID, setAuthorizeList);
        if (index != -1) {
            for (uint t=uint(index); t < setAuthorizeList.length-1; t++){
                setAuthorizeList[t] = setAuthorizeList[t+1];
            }
            setAuthorizeList.length--;
            
            revokeAuthorizeList[revokeAuthorizeList.length++] = companyID;
        }
    }
    
    function getIndex(uint element, uint[] array) private returns (int) {
        for (uint i=0; i < array.length; i++) {
            if (array[i] == element) {
                return int(i);
            }
        }
        
        return -1;
    }
}
