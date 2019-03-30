import json
from compile_solidity_utils import w3
from flask import Flask, Response, request, jsonify
from flask import render_template

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

# api to set new user every api call
@app.route("/upload", methods=['POST'])
def transaction():
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

    # 调用合约对象的方法
    tx_hash = upload.functions.upload(
        user_name, phone_number, birth_date, sex
    )
    # 获取合约方法中定义的事件对象
    event = tx_hash.transact()
    # 等待交易被矿工记录
    w3.eth.waitForTransactionReceipt(event)

    # 只读方法的调用方式
    upload_data = upload.functions.getUpload().call()
    data = {
        "userName": upload_data[0],
        "birthDate": upload_data[1],
        "phoneNumber": upload_data[2],
        "sex": upload_data[3]
    }

    return jsonify(data), 200


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")
