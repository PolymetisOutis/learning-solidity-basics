// SPDX-License-Identifier: MIT

/**
 * @dev pragma定義
 * 特定のコンパイラ機能またはチェックを有効にするために使用する
 */
pragma solidity ^0.8.17;
// 1行コメント
import "hardhat/console.sol";

/**
 * @dev contract定義
 * 1ファイルに複数定義することも可能
 */
contract Layout {
    /// @dev デバッグプリントする為だけのファンクション
    function logging() external view {
        /* 複数行コメント 
           msg.senderはグローバル変数で、Callまたは
           Transaction発行元のアカウントアドレス
        */
        console.log(msg.sender);
    }
}

contract A {}