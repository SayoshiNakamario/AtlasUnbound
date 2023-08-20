// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../contracts/math/SafeMath.sol";

contract GameManagerStorage {
    using SafeMath for uint256;

    address public FOGManager; 
    address public FOGNFT;         
    address public FOGHero;       

////// User NFT tracking
    struct UserInfo {
        uint256 nftBoostID;     //player weapon ID
        uint256 nftLockID;      //player armor ID
        uint256 heroID;         //companion hero ID
        uint256 heroBoostID;    //companion weapon ID
        uint256 heroLockID;     //companion armor ID    
        uint256 amount;         //amount of coins player has remaining
    }
        // user address => userInfo
    mapping (address => UserInfo) public userInfo;

////// User Atlas tracking
    struct AtlasInfo {
        uint256 mapsCompleted;  //number of maps completed this round
        uint256 mapsClaimed;    //number of maps claimed in total
    }
        // user address => atlasInfo
    mapping (address => AtlasInfo) public atlasInfo;

////// User state tracking
    struct StateInfo {
        uint256 playerState;
        uint256 worldState;
        uint256 hirelingState;
    }
        // user address => atlasInfo
    mapping (address => StateInfo) public stateInfo;
}
