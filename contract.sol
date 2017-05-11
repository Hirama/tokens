pragma solidity ^0.4.4;

contract BuildingRegistrator {

    /*/
     *  Contract fields
    /*/
    address private owner;
    mapping (uint => address) private tokenStorageAddress;

    /*/
     *  Events
    /*/
    event LogReleaseTokens(uint token_type, address StorageToken);
    event EventContractAdress(address);
    // constructor
    function BuildingRegistrator() {
        owner = msg.sender;
    }


    /*/
     *  Public functions
    /*/

    /// @dev Returns number of tokens owned by given address.
    /// @param _object_id Object id for presale tokens.
    /// @param _object_price Object price.
    /// @param _object_hash A hash of the document.

    function releaseTokens(uint _object_id, uint _object_price, string _object_hash)
        isOwner returns (address storageTokenAddress) {
        if(isCheckObjectId(_object_id)){
            tokenStorageAddress[_object_id] = new StorageToken(owner, _object_id, _object_price, _object_hash);
            LogReleaseTokens(_object_id,tokenStorageAddress[_object_id]);
        }
        EventContractAdress(tokenStorageAddress[_object_id]);
        return tokenStorageAddress[_object_id];

    }


    /// @dev Returns address of storage of tokens by given object_id.
    /// @param _objectId Id of object.
    function tokensByObjectId(uint _objectId) constant returns (address) {
        return tokenStorageAddress[_objectId];
    }


    /// @dev Check if there is a value in the map
    /// @param _objectId Id of object.
    /// @return false - If the object is in the map
    function isCheckObjectId(uint _objectId) constant returns (bool) {
        if(tokenStorageAddress[_objectId] == address(0x0))
            return true;
        else
            return false;
    }

    // modifiers
    modifier isOwner {
        if (msg.sender == owner)
        _;
    }


}

contract StorageToken {

    /*/
     *  Contract fields
    /*/
    uint public token_id;
    uint public object_price;
    string public object_documet_hash;
    uint public token_price;
    uint public amountOfTokens;
    uint public freeToken;

    // Token manager has exclusive priveleges to call administrative
    // functions on this contract.
    address public tokenManager;

    mapping (address => uint) private assetHolders;


    /*/
     *  Events
    /*/
    event LogBuy(address indexed owner, uint value);
    event LogBool(bool);

    /// @dev Constructor
    /// @param _tokenManager Token manager address.
    function StorageToken(address _tokenManager,
        uint _object_id, uint _object_price, string _object_documet_hash) {
        token_price = 1000;
        tokenManager = _tokenManager;
        token_id = _object_id;
        object_price = _object_price;
        object_documet_hash = _object_documet_hash;
        //TODO Здесь возможно не целое число
        amountOfTokens = object_price / 1000;
        freeToken =  amountOfTokens;
    }

    /*/
     *  Public functions
    /*/

    /// @dev Lets buy you some tokens.
    /// @param _buyer Address of _buyer.
    /// @param _seller Address of seller.
    /// @param _tokenAmount Number of tokens for sale.
    function sell(address _seller,address _buyer, uint _tokenAmount, uint _tokenPriceNow)
                                            public onlyTokenManager returns (bool) {

        //TODO сделать проверку на не пустые поля
        if (assetHolders[_seller] < _tokenAmount) return false;
        if(_tokenAmount == 0) return false;
        assetHolders[_seller]-=_tokenAmount;
        assetHolders[_buyer]+=_tokenAmount;
        LogBool(true);
        return true;
    }

    /// TODO дописать логи
    /// @dev Lets buy you some free  tokens from organisation.
    /// @param _buyer Address of _buyer.
    /// @param _tokenAmount Number of tokens for sale.
    function sellFreeToken(address _buyer, uint _tokenAmount)
    public onlyTokenManager notNullAddress(_buyer) returns (bool){
        if (freeToken < _tokenAmount) return false;
        if(_tokenAmount == 0) return false;
        freeToken-=_tokenAmount;
        assetHolders[_buyer]+=_tokenAmount;
        LogBool(true);
        return true;

    }


    /// @dev Returns number of tokens owned by given address.
    /// @param _user Address of token owner.
    function balanceOf(address _user) constant returns (uint256) {
        return assetHolders[_user];
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _newCost new cost of token.
    function changeCostOfToken(uint _newCost) onlyTokenManager {
        token_price = _newCost;
    }


    function reassessmentObject (uint _object_id,uint new_object_price,string new_object_hash)
    onlyTokenManager returns (bool){
        if(_object_id!=token_id){ throw;}

        object_price = new_object_price;
        object_documet_hash = new_object_hash;
        //calculate new price of Token
        //TODO если будет выходить не целое число
        token_price = new_object_price/amountOfTokens;
        LogBool(true);
        return true;
    }

    modifier onlyTokenManager() { if(msg.sender != tokenManager) throw; _; }
    modifier notNullAddress(address _address) {
        if (_address == 0)
            throw;
        _;
    }

}