// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/** 
 * @title Contract Typeを学ぼう
 * 全Contractはそれ自身の型を定義する
 * Address型に明示的に変換できる
 * Contract型のローカル変数を宣言できる（MyContract c）
 * Contractをインスタンス化することができる(new)
 */
contract Contract {
    /// @dev constructorやfunctionにpayableを付与、宣言すると、コントラクトはETHを受け取れるようになる
    constructor() payable {}

    /// @dev Addressコントラクトの型情報(type)から名前を取得
    function getAddressName() public pure returns (string memory) {
        return type(Address).name;
    }

    /** 
     * @dev Addressコントラクトの型情報(type)から作成コードを取得
     * creationCodeはスマートコントラクトのコンストラクタロジックとコンストラクタパラメータを含む
     */
     function getAddressCreationCode() public pure returns (bytes memory) {
        return type(Address).creationCode;
    }   

    /** 
     * @dev Addressコントラクトの型情報(type)からランタイムコードを取得
     * runtimeCodeはオンチェーンに保存されるコード
     * このコードには、コントラクトのコンストラクタ・ロジックやコンストラクタ・パラメータは含まれない
     */
     function getAddressRuntimeCode() public pure returns (bytes memory) {
        return type(Address).runtimeCode;
    }   

    /// @dev thisは現コントラクト(Contract)を意味する
    function getContractAddress() public view returns (address) {
        return address(this);
    }

    /// @dev 現コントラクトを破棄し、その資金を与えられたアドレスに送る。本当に削除されるのはトランザクション終了時。
    function destruct() public {
        selfdestruct(payable(msg.sender));
    }

    /// @dev コントラクト型（MyContract c）のローカル変数を定義し、Addressコントラクトのファンクションを実行
    function callAddressFunction(address _addr) public view returns (uint256) {
        Address addrContract = Address(_addr);
        return addrContract.getBalance();
    }

    /// @dev コントラクトのインスタンス化
    // 別途改めて扱う
    function callIAddressFunction(string memory _ownerName) public returns (uint256) {
        Address addrContract = new Address(_ownerName);
        return addrContract.getBalance();
    }
 
}

/** 
 * @title Address Typeを学ぼう
 */
contract Address {
    string public ownerName;

    constructor(string memory ownerName_) {
        ownerName = ownerName_;
    }

    /// @dev msg.senderはクエリ/トランザクション元アカウントアドレスが入っているグローバル変数
    address public fromAddr = msg.sender;

    /// @dev アカウントアドレス(EOA)の所有ETHを取得
    function getBalance() public view returns (uint256) {
        uint256 balance = fromAddr.balance;
        return balance;
    }
    /// @dev コントラクトのバイトコードを取得
    function getByteCode() public view returns (bytes memory) {
        return address(this).code;
    }

    /** 
     * @dev ETH送金 transfer/send/callの違い
     * `address payable`型のメンバーメソッド:transfer/send/call
     * 前提:EOAだけでなく、コントラクトアドレスにもETHを送金することができる
     *      ここではEOAに対するETH送金を学ぶ。
     *      コントラクトへの送金については別途Receive Ether FunctionやFallback Functionの箇所で解説
     *
     * transfer:ガス欠になったり、何等かの形で失敗した場合、
     * Ether転送は元に戻り、現在のコントラクトは例外を発生させて停止する
     * ガス量:2300固定
     *
     * transfer:宛先がコントラクトのアドレスである場合、
     * そのコード (Receive Ether Functionまたは Fallback Functionが存在すれば実行される
     * この実行がガス欠になったり、何らかの形で失敗した場合、
     * Ether転送は元に戻り、現在のコントラクトは例外を発生させて停止する
     *
     * send:transferの低レベルファンクション。実行に失敗した場合、例外で停止しないが、sendはfalseを返すので、
     * 安全なEther転送を行うには、常にsendの戻り値をrequire(別途解説)などで確認すること、もしくはsendではなくtransferを使用する。
     * ガス量:2300固定
     *
     * send:transferの低レベルファンクション。実行に失敗した場合、現在のコントラクトは例外で停止しないが、sendはfalseを返す
     * 安全なEther転送を行うには、常にsendの戻り値を確認し、transferを使用するか、
     * より良い方法として受信者がお金を引き出すwithdrawパターンを使用する
     *
     * call:他のコントラクトを呼び出すためのものだが、
     * 型チェック、関数の存在チェック、引数のパッキングをバイパスするため、この目的のために.call()を使うのは非推奨だが、
     * ETHを送金する利用に限り推奨されている。
     * 戻り値としては、成功失敗の結果(bool)とcallで戻ってきたデータ(bytes memory)の2つ
     * ガス量:固定なし
     *
     * call:ABIに準拠しないコントラクトとのインタフェースや、エンコーディングをより直接的に制御するために用意されている。
     * これらはすべて1バイトのメモリパラメータを取り、成功条件（bool）と返されたデータ（バイトメモリ）を返す
     * (※1) ABI(アプリケーションバイナリインターフェース）は、ブロックチェーンの外からとコントラクト間の相互作用の両方において、
     *      Ethereum内のコントラクトと対話するための標準的な方法
     *
     * さらに良い方法として送金せず、受信者がお金を引き出すwithdrawパターンを使用するのが安全。
     */    

    // ETH送金のためにはState Mutabilityの1つである payable の指定が必要。
    // State Mutability
    /**
     * @dev 何も指定しない/view/pure/payableを宣言することができる
     * 何も指定しない : 状態変数を変更したりする時使う( = トランザクション発行)
     * pure : 状態変数やグローバル変数にアクセスしない場合に指定。
     * view : 状態変数やグローバル変数を参照する場合に指定。状態を変更しないことが約束される。
     * payable : ETH送金などのときにはpayableの指定が上記に追加で必要
     */

    /// @dev 宛先アドレスにtransferでETHを移転(移転の場合send/callよりもtransferを使おう)
    function transfer(address payable to) public payable {
        to.transfer(msg.value);
    }

    /// @dev 宛先アドレスにsendでETHを移転
    function send(address payable to) public payable returns (bool) {
        return to.send(msg.value);
    }

    /// @dev 宛先アドレスにcallでETHを移転
    function call(address payable to) public payable returns (bool, bytes memory) {
        return to.call{value: msg.value}("");
    }
}
