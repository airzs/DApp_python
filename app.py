#! /usr/bin/env python
import json
import datetime
from compile_solidity_utils import w3
from flask import Flask, Response, request, jsonify
from flask import render_template

app = Flask(__name__)

# 设置默认账户
w3.eth.defaultAccount = w3.eth.accounts[0]
 # 读取保存的abi和合约地址
with open("Taccess.json", 'r') as f:
    datastore = json.load(f)
abi = datastore["abi"]
contract_address = datastore["contract_address"]

# 根据保存的abi和合约地址来实例化一个合约对象
Taccess = w3.eth.contract(
    address=contract_address, abi=abi,
)


@app.route("/")
def index():
    return render_template("index.html")


# api to set new user every api call
@app.route("/upload", methods=['POST'])
def transaction():
    # 获取url参数
    user_name = request.values.get("userName").encode('utf8')
    phone_number = request.values.get("phoneNumber").encode('utf8')
    birth_date = request.values.get("birthDate").encode('utf8')
    sex = request.values.get("sex").encode('utf8')

    # 设置默认账户
    w3.eth.defaultAccount = w3.eth.accounts[1]
    # 读取保存的abi和合约地址
    with open("data.json", 'r') as f:
        datastore = json.load(f)
    abi = datastore["abi"]
    contract_address = datastore["contract_address"]

    # 根据保存的abi和合约地址来实例化一个合约对象
    upload = w3.eth.contract(
        address=contract_address, abi=abi,
    )

    # 调用合约对象的方法，得到交易哈希
    tx_hash = upload.functions.upload(
        user_name, phone_number, birth_date, sex
    ).transact()
    # 等待交易被矿工记录
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    return_value = upload.events.CreateRecord().processReceipt(tx_receipt)
    print(return_value)
    print(return_value[0]['args'])
    now_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    # 只读方法的调用方式
    upload_data = upload.functions.getUpload().call()
    data = {
        "userName": upload_data[0],
        "birthDate": upload_data[2],
        "phoneNumber": upload_data[1],
        "sex": upload_data[3],
        "userID": upload_data[4],
        "time": now_time
    }
    print(jsonify(data))

    return jsonify(data), 200


@app.route("/createUser", methods=['GET'])
def create_user():
    name = request.values.get("name").encode('utf8')
    passwd = request.values.get("passwd").encode('utf8')
    date = request.values.get("date").encode('utf8')
    phone = request.values.get("phone").encode('utf8')
    sex = request.values.get("sex").encode('utf8')

    # 提交交易
    tx_hash = Taccess.functions.createUser(
        name, passwd, date, phone, sex
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # 通过event获取返回值
    result = Taccess.events.userID().processReceipt(tx_receipt)[0]['args']

    # 构造返回数据
    data = {
        "userID": result["usrID"],
    }

    return jsonify(data), 200


@app.route("/createCompany", methods=['GET'])
def create_company():
    name = request.values.get("name").encode('utf8')
    passwd = request.values.get("passwd").encode('utf8')

    # 提交交易
    tx_hash = Taccess.functions.createCompany(
        name, passwd
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # 通过event获取返回值
    result = Taccess.events.userID().processReceipt(tx_receipt)[0]['args']

    # 构造返回数据
    data = {
        "companyID": result["cpnID"],
    }

    return jsonify(data), 200


@app.route("/requireData", methods=['GET'])
def request_data():
    company_ID = int(request.values.get("companyID"))
    user_ID = int(request.values.get("userID").encode('utf8'))

    # 提交交易
    tx_hash = Taccess.functions.requireData(
        company_ID, user_ID
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # 通过event获取返回值
    result = Taccess.events.userData().processReceipt(tx_receipt)[0]['args']

    # 构造返回数据
    data = {
        "name": result["name"],
        "passwd": result["passwd"],
        "date": result["date"],
        "phone": result["phone"],
        "sex": result["sex"],
        "id": result["id"],
    }

    return jsonify(data), 200


@app.route("/requireAccess", methods=['GET'])
def require_access():
    company_ID = int(request.values.get("companyID").encode('utf8'))
    user_ID = int(request.values.get("userID").encode('utf8'))

    # 提交交易
    tx_hash = Taccess.functions.requireAccess(
        company_ID, user_ID
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    # 构造返回数据
    data = {
        "tx_receipt": tx_receipt,
    }

    return jsonify(data), 200


@app.route("/listWaitAuthorizeList", methods=['GET'])
def list_wait_authorize_list():
    user_ID = int(request.values.get("userID").encode('utf8'))

    # 提交交易
    waitAuthorizeList = Taccess.functions.listWaitAuthorizeList(
        user_ID
    ).call()

    # 构造返回数据
    data = {
        "list": waitAuthorizeList,
    }

    return jsonify(data), 200


@app.route("/listSetAuthorizeList", methods=['GET'])
def list_set_authorize_list():
    user_ID = int(request.values.get("userID").encode('utf8'))

    # 提交交易
    setAuthorizeList = Taccess.functions.listSetAuthorizeList(
        user_ID
    ).call()

    # 构造返回数据
    data = {
        "list": setAuthorizeList,
    }

    return jsonify(data), 200


@app.route("/addAccess", methods=['GET'])
def add_access():
    user_ID = int(request.values.get("userID").encode('utf8'))
    company_ID = int(request.values.get("companyID").encode('utf8'))

    # 提交交易
    tx_hash = Taccess.functions.addAccess(
        company_ID, user_ID
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    # 构造返回数据
    data = {
        "tx_receipt": tx_receipt,
    }

    return jsonify(data), 200


@app.route("/revokeAccess", methods=['GET'])
def revoke_access():
    user_ID = int(request.values.get("userID").encode('utf8'))
    company_ID = int(request.values.get("companyID").encode('utf8'))

    # 提交交易
    tx_hash = Taccess.functions.revokeAccess(
        company_ID, user_ID
    ).transact()
    # 等待交易被矿工记录，并得到交易收据
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    # 构造返回数据
    data = {
        "tx_receipt": tx_receipt,
    }

    return jsonify(data), 200


if __name__ == '__main__':
    app.run(debug=True)
