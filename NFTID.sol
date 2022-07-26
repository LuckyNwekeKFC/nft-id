//SPDX-License-Identifier: MIT

//NFTID by Lucky Nweke
pragma solidity ^0.8.0;




import "./ERC1155.sol";





contract DecentralizedGlobalIdentity is ERC1155 {

    address public manager;
    mapping(address => bool) public hasMinted;
    mapping(uint256 => bool) public isNFTTaken;
    mapping(address => uint256) public operatorCount;
    mapping(address => mapping(address => bool)) public operators;
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    bool isPaused;
    
    constructor() ERC1155("https://ipfs.io/ipfs/"){
        ///@notice set the base metadata URI
        manager = msg.sender;
        emit OwnershipTransferred({
            _previousOwner: address(0),
            _newOwner: manager
        });
    }


    modifier onlyManager{
        require(manager == msg.sender, "DecentralizedGlobalIdentity#onlyManager: You aren't the manager");
        _;
    }

    function togglePause() onlyManager public {
        isPaused = !isPaused;
    }


    function transferOwnership(address to_) external onlyManager {
        require(to_ != address(0), "DecentralizedGlobalIdentity#transferOwnership: INVALID ADDRESS");
        manager = to_;
        emit OwnershipTransferred(msg.sender, to_);
    }


    function isOperator(address wallet_) public view returns(bool) {
        require(hasMinted[msg.sender], "DecentralizedGlobalIdentity#isOperator: You must have an NFT minted");
        require(wallet_ != address(0), "DecentralizedGlobalIdentity#isOperator: INVALID ADDRESS");
        return operators[msg.sender][wallet_];
    }



    // function linkSubWallet(address owner_, address operator_) public {
    //     require(hasMinted[owner_], "DecentralizedGlobalIdentity#linkSubWallet: No NFT has been minted to this address");
    //     require(operator_ != address(0), "DecentralizedGlobalIdentity#linkSubWallet: INVALID ADDRESS");
    //     require(!hasMinted[operator_], "DecentralizedGlobalIdentity#linkSubWallet: Operator address already a Master Wallet");
    //     require(!operators[owner_][operator_], "DecentralizedGlobalIdentity#linkSubWallet: Already an operator");
    //     require(operatorCount[owner_] < 10, "DecentralizedGlobalIdentity#linkSubWallet: Maximum numbers of operators on one account");
    //     operators[owner_][operator_] = true;
    //     operatorCount[owner_]++;
    // }



    // function unlinkSubWallet(address owner_, address operator_) public {
    //     require(hasMinted[owner_], "DecentralizedGlobalIdentity#linkSubWallet: No NFT has been minted to this address");
    //     require(operator_ != address(0), "DecentralizedGlobalIdentity#linkSubWallet: INVALID ADDRESS");
    //     require(operators[owner_][operator_], "DecentralizedGlobalIdentity#linkSubWallet: Not an operator");
    //     delete operators[owner_][operator_];
    //     operatorCount[owner_]--;
    // }



    function mint(address owner_, uint256 id_, uint256 amount_, bytes memory data_) public {
        ///@notice require that minting hasn't been paused
        require(!isPaused, "DecentralizedGlobalIdentity#mint: Minting has been paused");

        ///@notice check if nft has been minted already
        require(!isNFTTaken[id_], string(abi.encodePacked("DecentralizedGlobalIdentity#mint: NFT #", id_, " has already been minted")));

        ///@notice require that user hasn't minted 
        require(!hasMinted[owner_], "DecentralizedGlobalIdentity#mint: An NFT is already minted to this address");

        ///@notice mint the data
        super._mint(owner_, id_, amount_, data_);

        ///@notice start operator count
        operatorCount[owner_] = 0;

        //@notice register the minter
        hasMinted[owner_] = true;

        ///@notice then we tie the nft to the network
        isNFTTaken[id_] = true;
    }



    function mintBatch(address owner_, uint256[] memory ids_, uint256[] memory amounts_, bytes memory data_) public {
        ///@notice first we check if minting has been paused
        require(!isPaused, "DecentralizedGlobalIdentity#mintBatch: Minting has been paused");

        ///@notice first we check if an nft has been minted to this address
        require(!hasMinted[owner_], "DecentralizedGlobalIdentity#mintBatch: An NFT has already mint to this address");

        ///@notice loop through and check if any nft is takwn
        for(uint256 i=0; i < ids_.length; i++){
            ///@notice check if nft has been minted already
            require(!isNFTTaken[ids_[i]], string(abi.encodePacked("DecentralizedGlobalIdentity#mint: NFT #", ids_[i], " has already been minted")));
        }

        ///@notice call the mintBatch
        super._mintBatch(owner_, ids_, amounts_, data_);

        ///@notice we start
        operatorCount[owner_] = 0;

        ///@notice the we register that the user has minted
        hasMinted[owner_] = true;

        ///@notice loop through and check if any nft is takwn
        for(uint256 i=0; i < ids_.length; i++){
            ///@notice check if nft has been minted already
            isNFTTaken[ids_[i]] = true;
        }
    }





}