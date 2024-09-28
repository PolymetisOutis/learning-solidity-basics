// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/** 
 * @title 数学的なファンクション、ハッシュ化ファンクションを学ぼう
 */

contract MathematicalCryptographicFunction {
    // (x + y) % k
    function addMod(uint x_, uint y_, uint k_) external pure returns (uint) {
        return addmod(x_, y_, k_);
    } 

    // (x * y) % k
    function mulMod(uint x_, uint y_, uint k_) external pure returns (uint) {
        return mulmod(x_, y_, k_);
    }

    /**
     * @dev Solidityでは、ハッシュ関数はまずデータの入力がエンコードされている必要がある
     * hash化するinput dataはハッシュ後の衝突を避けるためにabi.encodeを使った方が良い。
     */
    // Keccak-256ハッシュ
    function keccak256Hash(string memory s1_, string memory s2_)
        external 
        pure 
        returns (bytes32, bytes memory) {
            return (keccak256(abi.encode(s1_, s2_)), abi.encode(s1_, s2_));
        }

    function keccak256Hash2(string memory s1_, string memory s2_)
        external 
        pure 
        returns (bytes32, bytes memory) {
            return (keccak256(abi.encodePacked(s1_, s2_)), abi.encodePacked(s1_, s2_));
        }
        /*
0x9442fc109939c1323c53a3cb213beb6cdfb43a710c6de6098270610f6b9e15d9
0x02f379c9d6d924b205efaa7e888b0cb4e1c0dcaf9d7ccc7688981022cc450884

0x5840157b56d7f5dcd237891d847bd255f3764fde7180351c2c3546b4c7e381f8
0x5840157b56d7f5dcd237891d847bd255f3764fde7180351c2c3546b4c7e381f8

0x6b6a25b22c999fef40e9d824fcda720ced1a3391000000000000000000000000
0xd150c50d5a0e3ab683e71ac505a748838b7ef7fa29bce70313247cc00a1eba55
        */
    // SHA-256ハッシュ
    function sha256Hash(string memory s1_, string memory s2_)
        external 
        pure 
        returns (bytes32, bytes memory) {
            return (sha256(abi.encode(s1_, s2_)), abi.encode(s1_, s2_));
        }

    // RIPEMD-160ハッシュ
    function ripemd160Hash(string memory s1_, string memory s2_)
        external 
        pure 
        returns (bytes32, bytes memory) {
            return (ripemd160(abi.encode(s1_, s2_)), abi.encode(s1_, s2_));
        }
}
