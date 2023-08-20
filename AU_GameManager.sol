// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../contracts/math/SafeMath.sol";
import "../contracts/token/ERC20/IERC20.sol";
import "../contracts/token/ERC20/SafeERC20.sol";
import "../contracts/token/ERC721/IERC721.sol";
import "../contracts/access/AccessControl.sol";
import "../contracts/proxy/Initializable.sol";
import "../contracts/token/ERC721/ERC721Holder.sol";
import "./AU_GameManagerStorage.sol";
import "./FOGXP.sol";

interface IFOGHero {
    function addFXP(uint FXP, uint heroId) external;
    function getFXP(uint _heroId) external view returns (uint256);
    function getPower(uint _heroId) external view returns (uint256);
    function getLevel(uint _heroId) external view returns (uint256);
    function setCoordinates(uint _heroID, int x, int y) external;
}          

contract GameManagerDelegate is Initializable, AccessControl, ERC721Holder, GameManagerStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //address constant SEP206Contract = address(bytes20(uint160(0x2711)));  smartBCH nativeTransfer
    address private oracle;
    FOGXP public FXP;

    function initialize(address admin, address _FOGHero, address _FOGNFT, FOGXP _FXP, address _oracle) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        FOGHero = _FOGHero;
        FOGNFT = _FOGNFT;
        FXP = _FXP;
        oracle = _oracle;
    }

////// Sets
    function setAllAddresses(address _FOGManager, address _FOGHero, address _FOGNFT, FOGXP _FXP, address _oracle) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        FOGManager = _FOGManager;
        FOGHero = _FOGHero;
        FOGNFT = _FOGNFT;
        FXP = _FXP;
        oracle = _oracle;
    }
    function setFOGManager(address _FOGManager) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        FOGManager = _FOGManager;
    }
    function setOracle(address _oracle) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        oracle = _oracle;
    }
    function setFOGHero(address _FOGHero) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        FOGHero = _FOGHero;
    }
    function setFOGNFT(address _FOGNFT) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        FOGNFT = _FOGNFT;
    }

    function deposit() payable external {
        UserInfo storage user = userInfo[msg.sender];
        
        if (msg.value != 0) {
            user.amount = user.amount + msg.value;
        }
    }

////// Equip NFTs
    function depositNFT(uint _nftBoostID, uint _nftLockID, uint _heroID, uint _heroBoostID, uint _heroLockID) external {
        UserInfo storage user = userInfo[msg.sender];
   
    //Player Weapon
        if (_nftBoostID != 0) {
            if (user.nftBoostID != 0) { 
                IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.nftBoostID);
            }
            IERC721(FOGNFT).safeTransferFrom(msg.sender, address(this), _nftBoostID);
            user.nftBoostID = _nftBoostID;
        }
    //Player Shield
        if (_nftLockID != 0) {
            if (user.nftLockID != 0) {
                IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.nftLockID);
            }
            user.nftLockID = _nftLockID;
            IERC721(FOGNFT).safeTransferFrom(msg.sender, address(this), _nftLockID);
        }
    //Hireling Hero
        if (_heroID != 0) {
            if (user.heroID != 0) {
                IERC721(FOGHero).safeTransferFrom(address(this), msg.sender, user.heroID);
            }
            user.heroID = _heroID;
            IERC721(FOGNFT).safeTransferFrom(msg.sender, address(this), _heroID);
        }
    //Hireling Weapon
        if (_heroBoostID != 0) {
            if (user.heroBoostID != 0) {
                IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.heroBoostID);
            }
            user.heroBoostID = _heroBoostID;
            IERC721(FOGNFT).safeTransferFrom(msg.sender, address(this), _heroBoostID);
        }
    //Hireling Shield
        if (_heroLockID != 0) {
            if (user.heroLockID != 0) {
                IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.heroLockID);
            }
            user.heroLockID = _heroLockID;
            IERC721(FOGNFT).safeTransferFrom(msg.sender, address(this), _heroLockID);
        }
    }  

    function withdraw(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];

        if (_amount <= user.amount) {
            user.amount = user.amount - _amount;
            payable(msg.sender).transfer(_amount);
        }
    }

    function withdrawNFT(bool _nftBoostID, bool _nftLockID, bool _heroID, bool _heroBoostID, bool _heroLockID) external {
        UserInfo storage user = userInfo[msg.sender];

        //return player weapon
        if (_nftBoostID == true && user.nftBoostID != 0) {
            IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.nftBoostID);
            user.nftBoostID = 0;
        }
        //return player shield
        if (_nftLockID == true && user.nftLockID != 0) {
            IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.nftLockID);
            user.nftLockID = 0;
        }
        //return hireling
        if (_heroID == true && user.heroID != 0) {
            IERC721(FOGHero).safeTransferFrom(address(this), msg.sender, user.heroID);
            user.heroID = 0;
        }
        //return hireling weapon
        if (_heroBoostID == true && user.heroBoostID != 0) {
            IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.heroBoostID);
            user.heroBoostID = 0;
        }
        //return hireling shield
        if (_heroLockID == true && user.heroLockID != 0) {
            IERC721(FOGNFT).safeTransferFrom(address(this), msg.sender, user.heroLockID);
            user.heroLockID = 0;
        }
    } 
     
    function updateCompletedMaps(address _user, uint256 _mapsCompleted) external {
        require(msg.sender == oracle, "Only the oracle can update map completions");
        require(_mapsCompleted != 0);
        AtlasInfo storage atlas = atlasInfo[_user];
        
        atlas.mapsCompleted = atlas.mapsCompleted + _mapsCompleted;
    }

    function claimMaps(address _user) external {
        require(msg.sender == FOGManager, "Only FOGManager can claim");
        
        AtlasInfo storage atlas = atlasInfo[_user];
        require(atlas.mapsCompleted > atlas.mapsClaimed);
        
        atlas.mapsClaimed = atlas.mapsClaimed + atlas.mapsCompleted;
        atlas.mapsCompleted = 0;
    }

    function saveState(address _user, uint256 _playerState, uint256 _worldState, uint256 _hirelingState, uint256 _fee) external {
        require(msg.sender == oracle, "Only the oracle can save states");
        StateInfo storage state = stateInfo[_user];
        UserInfo storage user = userInfo[_user];

        if (user.amount >= _fee) {
            //nativeTransfer(msg.sender, _fee);
            payable(msg.sender).transfer(_fee);
            user.amount = user.amount - _fee;

            state.playerState = _playerState;
            state.worldState = _worldState;
            state.hirelingState = _hirelingState;

        }
    }

    //function nativeTransfer(address receiver, uint value) internal {
    //(bool success, bytes memory _notUsed) = SEP206Contract.call(
    //    abi.encodeWithSignature("transfer(address,uint256)", receiver, value));
    //require(success, "SEP206_TRANSFER_FAIL");
    //}
}
